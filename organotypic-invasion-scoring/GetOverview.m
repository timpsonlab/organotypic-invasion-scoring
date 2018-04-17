function [im, ratio, microns_per_px] = GetOverview(filename)

    
    reader = bfGetReader(filename);
    meta = reader.getMetadataStore();
    n_pages = meta.getImageCount();
    index = n_pages - 4;

    reader.setSeries(index);
    im = uint8.empty();
    for i=1:3
        im(:,:,i) = bfGetPlane(reader, i); 
    end  
    
    ratio = double(meta.getPixelsSizeX(0).getNumberValue()) / double(meta.getPixelsSizeX(index).getNumberValue());
    
    microns_per_px = double(meta.getPixelsPhysicalSizeX(0).value());
    
end

