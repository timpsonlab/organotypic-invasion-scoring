function TMAExtractor()
    %folder = '/Volumes/Seagate Backup Plus Drive/Histology Data/TMAs/anti-Lox/';
    %file = 'anti-Lox TMA#3.svs';

    [file,folder] = uigetfile('*.svs');
    
    [im,ratio] = GetOverview([folder file]);
    
    fh = figure(22);
    ax = gca;
    
    core_x = [];
    core_y = [];
    
    imss = [];
    IdentifyCores()
        
    set(fh, 'WindowButtonDownFcn', @MouseDown);
    set(fh, 'WindowKeyPressFcn', @KeyPress);

    core_line = line(core_x,core_y,'Marker','o','MarkerSize',7,'Color','r','LineStyle','none');
        


    
    
     function MouseDown(~,evt)
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

    function [x,y] = GetCurrentPoint()
        pt = get(ax, 'CurrentPoint');
        x = pt(1,1);
        y = pt(1,2); 
    end

    function KeyPress(~,evt)
       
        if strcmp(evt.Key,'e')
            Process();
        end
        
    end


    function IdentifyCores()

        imss = imresize(im,1/32);
    
        OD = -log(double(imss)/255);

        maxel = max(OD(isfinite(OD)));
        OD(~isfinite(OD)) = maxel;
        OD = min(OD,[],3);
        OD = OD > 0.12;
        
        kern = fspecial('disk',9);

        ODc = conv2(double(OD),kern,'same');

        thresh = graythresh(ODc) * 0.5;
        ODc(ODc < thresh) = 0;
        
        bw = imregionalmax(ODc);
        
        idx = find(bw(:));
        [y,x] = ind2sub(size(bw),idx);
        m = ODc(idx);
        
        X = repmat(x,[1, length(x)]);
        Y = repmat(y',[length(x) 1]);
        
        R = sqrt((X-X').^2 + (Y-Y').^2);
        R = R < 10 & R > 0;
        R = triu(R);
        
        [M1,M2] = find(R);
        t = m(M1) > m(M2);
        
        sel = true(size(x));
        sel(M1(~t)) = false;
        sel(M2(t)) = false;
        
        x = x(sel);
        y = y(sel);
        
        
        imagesc(imss);

        core_x = x;
        core_y = y;
    
    end
            


    function Process()
         
        if mod(length(core_x),8) ~= 0
            msgbox([num2str(length(core_x)) ' cores selected, need a multiple of 8!'])
        end
        
        x = core_x;
        y = core_y;

        [~, siy] = sort(y);

        sz = [length(y)/8 8];

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

        colors = jet(length(core_x));
        imagesc(imss);
        hold on;
        for i=1:length(core_x)
            plot(core_x(i),core_y(i),'o','Color',colors(i,:),'MarkerFaceColor',colors(i,:),'MarkerSize',10);
        end
        hold off;
            
        
        r = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'};    
        c = (1:sz(1));
        
        r = repmat({'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'},[sz(1),1]);
        c = repmat(c,[sz(2),1])';
               
        r = r(:);
        c = c(:);        
        
        names = cellfun(@(r,c) [r num2str(c,2)], r, num2cell(c), 'UniformOutput', false);
        
        out_folder = [folder '..' filesep 'Extracted Images' filesep];
        mkdir(out_folder);
        
        for i=1:length(core_x)

            w = 1500;
            
            rows= (core_y(i)-1) * 32 * ratio + [-w, w];
            cols= (core_x(i)-1) * 32 * ratio + [-w, w];

            rows = max(rows,1);
            cols = max(cols,1);

            rows = min(rows,size(im,1)*ratio)
            cols = min(cols,size(im,2)*ratio)


            roi=imread([folder file],'Index',1,'PixelRegion',{rows,cols});
            
            figure(20);
            imagesc(roi);
            drawnow
            
            output_file = [out_folder file];
            output_file = strrep(output_file,'.svs',['_' names{i} '.tif']);
            
            imwrite(roi, output_file);

            
        end

        beep
        
     end
        
end