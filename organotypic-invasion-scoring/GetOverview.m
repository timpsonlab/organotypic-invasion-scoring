function [im, ratio, microns_per_px] = GetOverview(filename)
    info = imfinfo(filename);
    n_pages = length(info);
    
    im = imread(filename, n_pages-3); % get 2nd smallest
    
    ratio = info(1).Width / info(n_pages-3).Width;
    
    info = info(1).ImageDescription;
    metadata = strsplit(info,'|');  
    a = regexp(metadata,'MPP = (.+)','tokens');
    sel = cellfun(@(a) ~isempty(a), a);
    a = a(sel);
    microns_per_px = str2double(a{1}{1});
    
end

