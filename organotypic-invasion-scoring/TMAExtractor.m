function TMAExtractor()
    %folder = '/Volumes/Sean ExFAT/Histology Data/ICGC TMA Picro/Slides/';
    %file = 'ICGC TMA2.svs';

    file = [];
    folder = [];

    core_x = [];
    core_y = [];

    imss = [];
    im = [];
    ratio = 1;
    options = struct();
    cores_identified = false;
    names = {};
    
    [fh,ax] = SetupPanel({'Num_Rows','Flip_Vert','Flip_Horz','Size'}, {8, false, false, 3000}, @OptionCallback, {'Open...','Identify','Extract'}, @ButtonCallback);
    set(fh,'Name','TMA Extractor','NumberTitle','off');
        
    set(fh, 'WindowButtonDownFcn', @MouseDown);
   
    core_line = line(core_x,core_y,'Marker','o','MarkerSize',7,'Color','k','MarkerFaceColor','w','LineStyle','none');
       
    function ButtonCallback(button)
        switch button
            case 'Open...'
                OpenFile();
            case 'Identify'
                IdentifyCores();
            case 'Extract'
                Extract();
        end
    end

    function OptionCallback(new_options)
        options = new_options;        
    end
    
    function OpenFile()

        [file,folder] = uigetfile('*.svs');    
        [im,ratio] = GetOverview([folder file]);
        FindCores();        
        cores_identified = false;
        
    end
    
    
     function MouseDown(~,evt)
        
        if ~cores_identified
            [x0,y0] = GetCurrentPoint();

            if strcmp(get(fh,'SelectionType'),'alt')
                R = (core_x - x0).^2 + (core_y - y0).^2;
                [~,idx] = min(R);
                sel = true(size(core_x));
                sel(idx) = false;
                core_x = core_x(sel);
                core_y = core_y(sel);
            else
                core_x = [core_x; x0];
                core_y = [core_y; y0];
            end

            set(core_line,'XData',core_x,'YData',core_y);
        end
     end

    function [x,y] = GetCurrentPoint()
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2); 
    end

    function FindCores()

        imss = imresize(im,1/32);
    
        imsum = max(double(imss)/255,[],3);
        
        OD = -log(imsum);

        maxel = max(OD(isfinite(OD)));
        OD(~isfinite(OD)) = maxel;
        OD = medfilt2(OD,[5 5]);
        OD = OD > 1.5*mode(OD(:));
        
        SE = strel('disk',2);
        OD = imdilate(OD,SE);
        
        regions = regionprops(OD,'Centroid','Area');
        
        area_thresh = 200;
        areas = [regions.Area];
        regions = regions(areas>area_thresh);
        locs = [regions.Centroid];
        locs = reshape(locs,[2 length(regions)])';
        x = locs(:,1);
        y = locs(:,2);

        
        imagesc(imss,'Parent',ax);
        daspect(ax,[1 1 1]);
        set(ax,'XTick',[],'YTick',[]);

        core_x = x;
        core_y = y;
        
        core_line = line(core_x,core_y,'Marker','o','MarkerSize',10,'Color','k','MarkerFaceColor','r','LineStyle','none');

    end
            


    function IdentifyCores()
                 
        if mod(length(core_x),options.Num_Rows) ~= 0
            msgbox([num2str(length(core_x)) ' cores selected, need a multiple of ' num2str(options.Num_Rows) '!'])
            return;
        end
        
        cores_identified = true;

        
        x = core_x;
        y = core_y;

        [~, siy] = sort(y);

        sz = [length(y)/options.Num_Rows options.Num_Rows];

        siy = reshape(siy,sz);

        idx = [];
        for j=1:size(siy,2)

            siyj = siy(:,j);

            xx = x(siyj);
            [~,six] = sort(xx);

            idx = [idx; siyj(six)];

        end
            
        core_x = core_x(idx);
        core_y = core_y(idx);
        
        r = char(64+(1:options.Num_Rows));    
        c = (1:sz(1));
        
        if options.Flip_Vert 
            r = fliplr(r);
        end
        if options.Flip_Horz
            c = fliplr(c);
        end
        
        r = repmat(r,[sz(1),1]);
        c = repmat(c,[sz(2),1])';
               
        r = r(:);
        c = c(:);        
        
        names = arrayfun(@(r,c) [r num2str(c,2)], r, c, 'UniformOutput', false);

        imagesc(imss,'Parent',ax);            
        hold(ax,'on');
        daspect(ax,[1 1 1]);
        
        for i=1:length(core_x)

            w = options.Size / 2 / 32 / ratio;
            
            x = (core_x(i)-1) + [-w, w];
            y = (core_y(i)-1) + [-w, w];
            
            plot(ax,[x(1) x(2) x(2) x(1) x(1)],[y(1) y(1) y(2) y(2) y(1)],'k');
            
            text(core_x(i),core_y(i),names{i},'HorizontalAlignment','center',...
                'FontSize',12,'BackgroundColor','k','Color','w')
        end
        
    end

    function Extract()

        if ~cores_identified
            return;
        end
        
        out_folder = [folder '..' filesep 'Extracted Images' filesep];
        mkdir(out_folder);
        
        h = waitbar(0);
        
        for i=1:length(core_x)

            w = options.Size / 2;
            
            rows= (core_y(i)-1) * 32 * ratio + [-w, w];
            cols= (core_x(i)-1) * 32 * ratio + [-w, w];

            rows = max(rows,1);
            cols = max(cols,1);

            rows = min(rows,size(im,1)*ratio);
            cols = min(cols,size(im,2)*ratio);


            roi=imread([folder file],'Index',1,'PixelRegion',{rows,cols});
            
            figure(20);
            imagesc(roi);
            drawnow
            
            output_file = [out_folder file];
            output_file = strrep(output_file,'.svs',['_' names{i} '.tif']);
            
            imwrite(roi, output_file);

            waitbar(i/length(core_x),h);
            
        end

        close(h)
        beep
        
     end
        
end