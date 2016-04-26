function [HED] = HEDDeconvolution(sampleRGB)

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
    E = sampleHEB_OD(:,:,2);
    D = sampleHEB_OD(:,:,3);
    
    lim = 2;
    
    H(H>lim) = lim;
    D(D>lim) = lim;
    
    H = H / lim * 255;
    D = D / lim * 255;
    
    HED = imfuse(uint8(H),uint8(D));