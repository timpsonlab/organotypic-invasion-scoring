folder = '/Volumes/Seagate Backup Plus Drive/Histology Data/Primed Invasions PF562271/TIF Invasion 3/MultiCK Extracted Images/';

items = dir(folder);
items = items(3:end);

for i=1:length(items)
    if (items(i).isdir)
        subfolder = [folder filesep items(i).name filesep]
        CountDAB(@ProcessDAB,subfolder,1);
    end
end

%%
m = []; a = [];
for i=1:length(items)
    if (items(i).isdir)
        subfolder = [folder filesep items(i).name filesep];
        
        files = dir([subfolder '*-avg-quantification.csv']);
        manual = csvread([subfolder files(1).name],1,0);
        manual = manual(:,3);
        
        files = dir([subfolder '*-DAB-quantification.csv']);
        auto = csvread([subfolder files(1).name],1,1);
        auto = auto(:,3);
        
        m = [m; manual];
        a = [a; auto];
    end
end
