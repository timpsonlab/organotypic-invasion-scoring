function im =  AddScaleBar(im, microns_per_pixel, bar_width_microns, bar_height_pixels)

    imw = size(im,2);
    imh = size(im,1);

    w = bar_width_microns / microns_per_pixel;
    h = bar_height_pixels;

    pos = [imw - w - h, imh - 2*h, w, h];
    pos_text = [imw - 0.5*w - h, imh - 2*h - 5];
    im = insertShape(im, 'FilledRectangle', pos, 'Color', 'black', 'Opacity', 1);
    im = insertText(im, pos_text, '50um','AnchorPoint','CenterBottom','BoxOpacity',0,'FontSize',int32(w*0.2));