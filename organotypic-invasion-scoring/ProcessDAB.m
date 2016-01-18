function [p,yN,yD] = ProcessDAB(r, im)

    if isfield(r,'top_p') & ~isfield(r,'border_p')
        r.border_p = r.top_p;
    end

    sz = size(im);

    x = 1:sz(2);
    y = 1:sz(1);
        
    top_thickness = 30;
    
    
    % Get Depth
    [border_x, border_y] = GetSortedBorder(r);
    
    border_c_y = interp1(border_x,border_y,x,'linear','extrap');
    
    [border_c_Y,Y] = meshgrid(border_c_y,y);
    Y = Y - border_c_Y;
    
    
    [nucleus, DAB, nucleus_I, DAB_I] = ColourDeconvolution(im);
    
    top = Y < 0;
    
    nucleus_top = nucleus;
    nucleus_top(~top) = 0;
    
    DAB_top = DAB;
    DAB_top(~top) = 0;
    
    nucleus_plug = nucleus;
    nucleus_plug(top) = 0;
    
    DAB_plug = DAB;
    DAB_plug(top) = 0;
   
    DAB_top_x = sum(DAB_top,1);
    DAB_top_x = min(DAB_top_x, top_thickness);
    
    
    p = struct;
    p.DabAreaTop = sum(DAB_top_x);
    p.DabAreaPlug = sum(DAB_plug(:));
    p.InvasiveIndex = p.DabAreaPlug / (p.DabAreaPlug + p.DabAreaTop);
    
    yD = Y(DAB);
    yN = Y(nucleus);
        
    subplot(1,3,1)
    imagesc(im);
    hold on;
    plot(border_x,border_y,'r-');
    hold off;
    daspect([1 1 1]);
    set(gca,'XTickLabel',[],'YTickLabel',[])
    
    subplot(1,3,2);
    nucleus_I(nucleus_I > 3) = 3;
    DAB_I(DAB_I > 3) = 3;
    imagesc(imfuse(nucleus_I,DAB_I));
    hold on;
    plot(border_x,border_y,'r-');
    hold off;
    daspect([1 1 1]);
    set(gca,'XTickLabel',[],'YTickLabel',[])
    caxis([0 5])
    
    subplot(1,3,3)
    imagesc(imfuse(nucleus,DAB));
    hold on;
    plot(border_x,border_y,'r-');
    hold off;
    daspect([1 1 1]);
    set(gca,'XTickLabel',[],'YTickLabel',[])
    caxis([0 5])
    drawnow;
end