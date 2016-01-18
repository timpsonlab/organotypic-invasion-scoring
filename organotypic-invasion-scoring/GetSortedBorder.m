function [border_x,border_y] = GetSortedBorder(r)

    border_x = r.border_p(:,1);
    border_y = r.border_p(:,2);
    
    [border_x,sort_idx] = sort(border_x);
    border_y = border_y(sort_idx);
    
    [border_x,sort_idx] = unique(border_x);
    border_y = border_y(sort_idx);