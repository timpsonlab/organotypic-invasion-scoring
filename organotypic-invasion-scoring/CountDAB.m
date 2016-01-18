function [depth_N,depth_F,xx] = CountDAB(process_function, folder, n_avg)

    if (nargin < 2)
        folder = uigetdir('Choose Folder...');
        folder = [folder filesep];
    end
    
    if nargin < 3
        a = inputdlg('Number of images per plug:','Averaging',1,{'3'});
        n_avg = str2double(a);
    end
    
    files = dir([folder '*-seg.mat']);
    names = {files.name};
    block_id = cellfun(@(n) n(1:4), names, 'UniformOutput', false);

    
    blocks = unique(block_id);
    p_all = [];
    q_all = [];
    
    h = waitbar(0,'Processing...');
    for i=1:length(blocks)
        
        disp(blocks{i})
        sel = strcmp(block_id, blocks{i});
        sel_names = names(sel);
        
        %cluster_size = [];
        
        yN = []; yD = [];
        
        for j=1:length(sel_names)
            filename = [folder sel_names{j}];
            im_filename = strrep(filename,'-seg.mat','.tif');
            im = imread(im_filename);
            
            r = load([folder sel_names{j}]);
            [p(j), yNj, yDj] = process_function(r,im);
            
            yD = [yD; yDj];
            yN = [yN; yNj];
        end
        p_all = [p_all p];

        xx = linspace(-400, 1000, 25);
        depth_N(:,i) = hist(yN,xx);
        depth_F(:,i) = hist(yD,xx) ./ hist(yN,xx);
        
        fields = fieldnames(p);
        q = struct();
        for k=1:length(fields)
            f = [p.(fields{k})];
            f = reshape(f, [n_avg, length(f)/n_avg]);
            f = mean(f,1);
            q.(fields{k}) = f';
        end
        
        q_all = [q_all q];
        
        t = struct2table(p);
        t.Properties.RowNames = sel_names;
        
        qt = struct2table(q);
        
        writetable(t, [folder blocks{i} '-DAB-quantification.csv'],'WriteRowNames', true);
        writetable(qt, [folder blocks{i} '-avg-DAB-quantification.csv']);

        waitbar(i/length(blocks),h);
    end

    delete(h);
    
    tt = struct2table(q_all);
    tt.Properties.RowNames = names;
    writetable(tt, [folder 'DAB-all-quantification.csv'], 'WriteRowNames', true);
        
    
end