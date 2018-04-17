function QuantifyPicro()

    persistent last_root
    
    if isempty(last_root) || last_root == 0
        last_root = '';
    end
    root = uigetdir(last_root);
    
    if (root == 0)
        return
    end
    
    last_root = root;
    
    
    folders = dir(root);
    sel = [folders.isdir];
    folders = {folders.name};
    folders = folders(sel);
    folders = folders(3:end);
    
    h = waitbar(0,'Processing...');
    for j=1:length(folders)
    
        folder = [root filesep folders{j} filesep];
        
        files = dir([folder '*.tif']);
        files = {files.name};
        files = sort_nat(files)';

        out_file = [folder 'picro-analysis.csv'];
        fid = fopen(out_file,'w');

        for i=1:length(files)
            imi = imread([folder files{i}]);
            imi = double(imi) /255;
            logim = -log10(imi(:,:,3));
            sel = isfinite(logim) & logim > 0.03;
            p = mean(logim(sel));
            fprintf(fid,[files{i} ', ' num2str(p) '\n']);
        end 

        fclose(fid);
        
        waitbar(j/length(folders),h);

    end
    
    close(h);