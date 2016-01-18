function [p] = ProcessCells(r)

    if ~isfield(r,'cells_p')
        p = struct();
        return
    end

    if iscell(r.cells_p)
        r.top_cells_p = [r.cells_p{1}, r.cells_p{2}];
        r.cells_p = [r.cells_p{3}, r.cells_p{4}];
    end
    
    if isfield(r,'top_p') && ~isfield(r,'border_p')
        r.border_p = r.top_p;
    end
        
    if ~isempty(r.cells_p) 
        cells_x = r.cells_p(:,1);
        cells_y = r.cells_p(:,2);
    else
        cells_x = [];
        cells_y = [];
    end

%{
    im = 255-min(im,[],3);
    im = double(im) / 255;
    mask = im > 0.4;
    
    [X,Y] = meshgrid(1:size(im,2),1:size(im,1));
    
    L = bwlabel(mask);
    

    figure(10);
    imagesc(L);
    hold on;
    plot(cells_x,cells_y,'xr');
    hold off;
    
    
    idx = [];
    for i=1:length(cells_x)
        try %#ok
            x = round(cells_x(i));
            y = round(cells_y(i));
            id = L(y,x);
            if id > 0
                idx(end+1) = id;
            else
                % find nearest cluster
                D = (X-x).^2 + (Y-y).^2;
                D = D(L>0);
                [d,ind] = min(D);
                if d < 10
                    idx(end+1) = L(ind);
                end
            end
        end
    end
    
    u = unique(idx);
    cluster_size = arrayfun(@(el) sum(idx == el), u);
    n_clusters = sum(cluster_size > 1);
    
    total_clustered = sum(cluster_size(cluster_size > 1));
    
    %}

    n_top = length(r.top_cells_p);
    n_cells = length(r.cells_p);

    
    % Get Depth
    [border_x, border_y] = GetSortedBorder(r);
    
    border_c_y = interp1(border_x,border_y,cells_x,'linear','extrap');
    corrected_cells_y = (cells_y - border_c_y) * r.mpp;
    
    d = [0 100 200 300 400 500 Inf];
    h = histcounts(corrected_cells_y,d);
    
    p = struct;
    p.NumInvaded = n_cells;
    p.NumTop = n_top;
    p.InvasionIndex = n_cells / (n_cells + n_top);
    p.MeanInvasionDepth = mean(corrected_cells_y);
    p.WeightedInvasionIndex = p.MeanInvasionDepth * p.InvasionIndex;
    %p.MeanClusterSize = mean(cluster_size);
    %p.NumClusters = n_clusters;
    %p.FractionClustered = total_clustered / n_cells;
    
    for i=1:length(h)
        name = ['NumInvaded_' num2str(d(i)) '_' num2str(d(i+1)) '_um'];
        p.(name) = h(i);
    end

    
end