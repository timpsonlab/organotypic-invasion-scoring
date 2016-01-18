function [nucleus, DAB, H, D] = ColourDeconvolution(sampleRGB)

    [height, width, channel] = size(sampleRGB);

    % Convert RGB intensity to optical density (absorbance)
    sampleRGB_OD = -log((double(sampleRGB)+1)./256);

    He = [0.650 0.704 0.286]';
    Eo = [0.072 0.990 0.105]';
    Da = [0.268 0.570 0.776]';

    % Create Deconvolution matrix
    M = [He/norm(He) Eo/norm(Eo) Da/norm(Da)];

    % Apply Color Deconvolution
    sampleRGB_OD = reshape(sampleRGB_OD, [height*width channel])';
    sampleHEB_OD = M \ sampleRGB_OD;
    sampleHEB_OD = sampleHEB_OD';
    sampleHEB_OD = reshape(sampleHEB_OD, [height, width, channel]);
    
    H = sampleHEB_OD(:,:,1);
    D = sampleHEB_OD(:,:,3);

    % Remove scale bar from image (!)
    scale = H > 6;
    scale = imdilate(scale,strel('disk',5));
    H(scale) = 0;

    Hthresh = graythresh(H);
    Dthresh = graythresh(D);

    nucleus = H>Hthresh;
    DAB = D>Dthresh;

    % remove some of the salt and pepper noise
    nucleusf = medfilt2(nucleus,[5 5]);
    nucleus = nucleus & nucleusf;

    % only look for stain in nucleus
    DAB(~nucleus) = 0;

    nuclear_area = sum(nucleus(:));
    DAB_area = sum(DAB(:));

    DAB_fraction = DAB_area / nuclear_area
