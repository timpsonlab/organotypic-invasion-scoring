function GenerateMontage()

folder = GetFolderWithMemory();
folder = [folder filesep];

image_names = dir([folder '*.tif']);
image_names = {image_names.name};

sel = cellfun(@(n) ~strcmp(n(1:7),'Montage'), image_names);
image_names = image_names(sel);

im = cellfun(@(f) imread([folder f]),image_names,'UniformOutput',false);

%%
names = image_names;
tokens = regexp(names,'(.+)-(\d+).tif', 'tokens');
for i=1:length(names)
    if ~isempty(tokens{i})
        group{i} = tokens{i}{1}{1};
        id{i} = tokens{i}{1}{2};
    else
        group{i} = names{i};
        id{i} = '';
    end
end
    
groups = unique(group)'

%%

ims = cellfun(@(im) imresize(im,1/2), im, 'UniformOutput', false);

sz1 = cellfun(@(im) size(im,1),ims);
sz2 = cellfun(@(im) size(im,2),ims);
sz1 = min(sz1);
sz2 = min(sz2);

h = waitbar(0, 'Generating Montages');
for i=1:length(groups)
    sel = strcmp(groups{i},group);
    imi = ims(sel);
    imi = cellfun(@(im) im(1:sz1,1:sz2,:), imi, 'UniformOutput', false);
    
    imz = zeros(sz1,sz2*length(imi),3,'uint8');
    for j=1:length(imi)
        imz(:,(1:sz2) + (j-1)*sz2,:) = imi{j};
        imz(:,j*sz2,:) = 0;
    end
    imz(:,1,:) = 0;
    imz(1,:,:) = 0;
    imz(sz1,:,:) = 0;
    
    imwrite(imz,[folder 'Montage ' groups{i} '.tif']);
    waitbar(i/length(groups),h);
end
delete(h);