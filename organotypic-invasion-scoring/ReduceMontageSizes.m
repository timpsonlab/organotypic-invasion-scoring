folder = '/Volumes/Seagate Backup Plus Drive/Histology Data/TMAs/Montages/';
sub = {'anti-Lox', 'pSrc', 'Src'};

h = waitbar(0,'processing')

for i=1:length(sub)
    files = dir([folder sub{i} '/*.tif']);
   
    for j=1:length(files)
        im = imread([folder sub{i} filesep files(j).name]);
        im = imresize(im, 1/4);
        
        imwrite(im,[folder sub{i} filesep 'Small ' files(j).name]);
        waitbar(j/length(files),h);
    end
    
end

delete(h)