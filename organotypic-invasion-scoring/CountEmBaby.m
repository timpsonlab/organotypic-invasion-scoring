function CountEmBaby(process_function)

    if nargin < 1
        process_function = @ProcessCells;
    end

    folder = GetFolderWithMemory();
    folder = [folder filesep];
    
    files = dir([folder '*-seg.mat']);
    names = {files.name};
    names = sort_nat(names);
    block_id = cellfun(@(n) n(1:4), names, 'UniformOutput', false);

    a = inputdlg('Number of images per plug:','Averaging',1,{'3'});
    n_avg = str2double(a);
    
    blocks = unique(block_id);
    
    for i=1:length(blocks)
        
        disp(blocks{i})
        sel = strcmp(block_id, blocks{i});
        sel_names = names(sel);

        for j=1:length(sel_names)
            disp([folder sel_names{j}]);
            r = load([folder sel_names{j}]);
            
            if ~isfield(r,'mpp') || r.mpp < 1e-5
                r.mpp = 0.4971; % old file without resolution - assume 20X
            end
            
            r.name = sel_names{j};
            p(j) = process_function(r);
        end

        fields = fieldnames(p);
        q = table();
        for k=1:length(fields)
            f = [p.(fields{k})];
            
            if mod(length(f),n_avg) ~= 0
                n_pad = n_avg - mod(length(f),n_avg);
                f = [f nan(1,n_pad)];
            end
            
            f = reshape(f, [n_avg, length(f)/n_avg]);
            f = mean(f,1);
            q.(fields{k}) = f';
        end
        
        t = struct2table(p);
        writetable(t, [folder blocks{i} '-quantification.csv']);
        writetable(q, [folder blocks{i} '-avg-quantification.csv']);
    end

    msgbox('Done!');
    
end