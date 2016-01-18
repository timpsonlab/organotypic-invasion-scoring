function DeconvolveFolder(folder)

    if (nargin < 1)
        folder = uigetdir('Choose Folder...');
        folder = [folder filesep];
    end
        
    files = dir([folder '*.tif']);
    names = {files.name};
        
    h = waitbar(0,'Processing...');
    for i=1:length(names)
        
        filename = [folder names{i}];
        im = imread(filename);
        [nucleus, DAB] = ColourDeconvolution(im);
        
        out_filename = strrep(filename, '.tif', '-deconv.mat');
        save(out_filename, 'nucleus', 'DAB');
        
        waitbar(i/length(names),h);
    
    end
    delete(h);
    
end