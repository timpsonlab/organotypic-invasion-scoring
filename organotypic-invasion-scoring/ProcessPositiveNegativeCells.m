function [p] = ProcessPositiveNegativeCells(r)

    if isempty(r.cells_p)
        p = struct();
        return
    end

    if ~iscell(r.cells_p)
        disp('Old format detected!');
        return
    end

    for i=1:4
        if isempty(r.cells_p{i})
            r.cells_p{i} = zeros(0,2);
        end
    end
    
    top_cells_pos_x = r.cells_p{1}(:,1);
    top_cells_pos_y = r.cells_p{1}(:,2);

    top_cells_neg_x = r.cells_p{2}(:,1);
    top_cells_neg_y = r.cells_p{2}(:,2);
    
    inv_cells_pos_x = r.cells_p{3}(:,1);
    inv_cells_pos_y = r.cells_p{3}(:,2);

    inv_cells_neg_x = r.cells_p{4}(:,1);
    inv_cells_neg_y = r.cells_p{4}(:,2);

    % Get Depth
    [border_x, border_y] = GetSortedBorder(r);
    
    if isempty(border_x)
        inv_cells_pos_y = (inv_cells_pos_y) * r.mpp;
        inv_cells_neg_y = (inv_cells_neg_y) * r.mpp;

        msgbox(['Warning: Image "' r.name '" does not have border, not correcting depth']);
    else
        border_c_y = interp1(border_x,border_y,inv_cells_pos_x,'linear','extrap');
        inv_cells_pos_y = (inv_cells_pos_y - border_c_y) * r.mpp;

        border_c_y = interp1(border_x,border_y,inv_cells_neg_x,'linear','extrap');
        inv_cells_neg_y = (inv_cells_neg_y - border_c_y) * r.mpp;
    end

    
    
    
    n_top_pos = length(top_cells_pos_x);
    n_top_neg = length(top_cells_neg_x);
    n_inv_pos = length(inv_cells_pos_x);
    n_inv_neg = length(inv_cells_neg_x);

    d = [0 100 200 300 400 500 Inf];
    h_pos = histcounts(inv_cells_pos_y,d);
    h_neg = histcounts(inv_cells_neg_y,d);
    
    
    p = struct;
    p.InvadedNumPositive = n_inv_pos;
    p.InvadedNumNegative = n_inv_neg;
    p.InvadedFractionPositive = n_inv_pos / (n_inv_pos + n_inv_neg);
    p.TopNumPositive = n_top_pos;
    p.TopNumNegative = n_top_neg;
    p.TopFractionPositive = n_top_pos / (n_top_pos + n_top_neg);
    p.MeanInvasionDepthPositive = mean(inv_cells_pos_y);
    p.MeanInvasionDepthNegative = mean(inv_cells_neg_y);
    
    for i=1:length(h_pos)
        name = ['NumInvadedPositive_' num2str(d(i)) '_' num2str(d(i+1)) '_um'];
        p.(name) = h_pos(i);
    end
    for i=1:length(h_neg)
        name = ['NumInvadedNegative_' num2str(d(i)) '_' num2str(d(i+1)) '_um'];
        p.(name) = h_neg(i);
    end
    
end