function QuantifyPicro()

    folder = uigetdir();
    files = dir([folder '*.tif']);
    files = {files.name};
    files = sort_nat(files)';

    out_file = [folder 'picro-analysis.csv'];
    fid = fopen(out_file,'w');
    
    for i=1:length(im)
        imi = imread([folder files{i}]);
        imi = double(imi) /255;
        logim = -log10(imi(:,:,3));
        sel = isfinite(logim) & logim > 0.03;
        p = mean(logim(sel));
        fwrite(fid,[files{i} ', ' p(i)]);
    end 

    fclose(fid);

