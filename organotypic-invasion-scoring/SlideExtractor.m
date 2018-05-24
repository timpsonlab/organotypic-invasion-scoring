function SlideExtractor()

    file = '';

    im = [];
    ratio = 1;   
    mpp = 1;
    options = struct();
    path = '';
    
    regions = struct('lh',{},'x',{},'y',{});
    button_down = false;
            
    [fh,ax] = SetupPanel({'Width_um', 'Height_um'}, [500 600], @OptionCallback, {'Open...','Export'}, @ButtonCallback);
    set(fh,'Name','Slide Extractor','NumberTitle','off');
    
    lh = []; x0 = 0; y0 = 0;
    set(fh, 'WindowButtonDownFcn', @MouseDown);
    set(fh, 'WindowButtonUpFcn', @MouseUp);
    set(fh, 'WindowButtonMotionFcn', @MouseMove);
    set(fh, 'Pointer', 'crosshair')
    
    OpenFile();
    

    function RegionClicked(~,evt)
        lh_click = evt.Source;
        regions = regions([regions.lh] ~= lh_click);
        delete(lh_click);
    end

    function ButtonCallback(button)
        switch button
            case 'Open...'
                OpenFile();
            case 'Export'
                ExtractRegions();
        end
    end

    function OptionCallback(new_options)
        options = new_options;
        
        for i=1:length(regions)
            xs = regions(i).x;
            ys = regions(i).y;
            [X,Y] = RegionBounds(xs(2),ys(2),xs(1),ys(1));
            set(regions(i).lh,'XData',X,'YData',Y);
        end
        
    end

    function OpenFile()
        
        if ~isempty(file)
            SaveCoordinates();
        end
        
        [new_file,path] = uigetfile('*.svs','Choose File',path);
        if new_file == 0
            return;
        end
        
        file = [path new_file];
        [im,ratio,mpp] = GetOverview(file);

        imshow(im,'Parent',ax);
        set(fh,'Name',file);
        
        
        for i=1:length(regions)
            delete(regions(i).lh)
        end

        regions = struct('lh',{},'x',{},'y',{});

        % Try and load coordinates
        coords_file = strrep(file, '.svs', '-coords.mat');        
        if exist(coords_file,'file')
            r = load(coords_file);
            for i=1:length(r.x_coords)

                regions(i).x = r.x_coords{i};
                regions(i).y = r.y_coords{i};
                xs = regions(i).x;
                ys = regions(i).y;
                [X,Y] = RegionBounds(xs(2),ys(2),xs(1),ys(1));
                regions(i).lh = patch(X,Y,'r','FaceColor','b','FaceAlpha',0.05,...
                               'EdgeColor','b','ButtonDownFcn',@RegionClicked);

            end
        end
        
    end

    function SaveCoordinates()
        x_coords = {regions(:).x};
        y_coords = {regions(:).y};
        save(strrep(file, '.svs', '-coords.mat'),'x_coords','y_coords','options');
    end

    function ExtractRegions()

        SaveCoordinates();
        
        idx = 1;
        wh = waitbar(0,'Extracting Regions...');
        for i=1:length(regions)
            try
                im = GetImage(regions(i).x,regions(i).y);
                im = AddScaleBar(im, mpp, 50, 10);
                file_name = strrep(file, '.svs', ['-' num2str(idx, 3) '.tif']);
                idx = idx + 1;
                imwrite(im, file_name, 'Resolution', 1/(mpp*1e-4)); % write resolution in px per cm
            catch e
                disp(['Could not read region: ' num2str(i)]);
            end
                
            waitbar(i/length(regions),wh);
        end
        delete(wh);
    end

    function MouseDown(~,~)
        button_down = true;
        [x0,y0] = GetCurrentPoint();
        [X,Y] = RegionBounds(x0,y0,x0,y0);
        lh = patch(X,Y,'r','FaceColor','b','FaceAlpha',0.05,...
                           'EdgeColor','b','ButtonDownFcn',@RegionClicked);
    end

    function MouseUp(~,~)
        button_down = false;
        [x,y] = GetCurrentPoint();
        regions(end+1) = struct('lh',lh,'x',[x0, x],'y',[y0 y]);
    end

    function MouseMove(~,~)
        if button_down
            [x,y] = GetCurrentPoint();
            [X,Y] = RegionBounds(x,y,x0,y0);
            set(lh, 'XData', X, 'YData', Y);
        end
    end

    function [x,y] = GetCurrentPoint()
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2); 
    end

    function [X,Y,v] = RegionBounds(x,y,x0,y0)
      
        h = options.Height_um * 0.8 / mpp / ratio;
        ht = options.Height_um * 0.2 / mpp / ratio;
        w = options.Width_um / mpp / ratio;
        
        p0 = [x0 y0];
        p1 = [x y];
        
        u = [x-x0, y-y0];
        u = u / norm(u);
        
        v = [y-y0, -(x-x0)];
        v = v/norm(v);
        
        if (w > 0)  
            p1 = p0 + u * w;
        end
        
        p2 = p0 + v .* h;
        p3 = p1 + v .* h;
        
        p0 = p0 - v .* ht;
        p1 = p1 - v .* ht;
        
        X = [p0(1) p2(1) p3(1) p1(1)];
        Y = [p0(2) p2(2) p3(2) p1(2)];
        
    end

    function im = GetImage(xs,ys)
       
        [X,Y,v] = RegionBounds(xs(2),ys(2),xs(1),ys(1));

        p2 = [X(2), Y(2)];
        p1 = [X(4), Y(4)];

        minx = min(X); maxx = max(X);
        miny = min(Y); maxy = max(Y);
        
        rows=[miny maxy] * ratio;
        cols=[minx maxx] * ratio;
        
        reader = bfGetReader(file);
        reader.setSeries(0);
        roi = uint8.empty();
        [ round(minx), round(miny), round(maxx-minx), round(maxy-miny)]
        for i=1:3
            roi(:,:,i) = bfGetPlane(reader, i, round(minx*ratio), round(miny*ratio), round((maxx-minx)*ratio), round((maxy-miny)*ratio)); 
        end  

        
%        roi=imread(file,'Index',1,'PixelRegion',{rows,cols});

        angle = atan2(v(2), v(1)) * 180/pi - 90;
        
        im = imrotate(roi, angle,'nearest','crop');
        
        angle = - angle * pi/180;
        tr = [cos(angle) -sin(angle); ... 
              sin(angle) cos(angle)];

        diff = [maxx-minx maxy-miny];
          
        p1 = transform(p1);
        p2 = transform(p2);
       
        xl = round([p1(1) p2(1)]);
        yl = round([p1(2) p2(2)]);
        
        xl(xl<1) = 1;
        yl(yl<1) = 1;
        xl(xl>size(im,2)) = size(im,2);
        yl(yl>size(im,1)) = size(im,1);
        
        im = im(yl(1):yl(2),xl(1):xl(2),:);
        
        function p = transform(p)
            p = p - [minx miny] - 0.5 * diff;
            p = (tr * p')';
            p = p + 0.5 * diff;
            p = p * ratio;
        end
            
    end

end