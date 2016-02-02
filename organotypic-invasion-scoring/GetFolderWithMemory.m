function folder = GetFolderWithMemory()
    persistent last_folder__
    
    if isempty(last_folder__) || (numel(last_folder__)==1 && last_folder__ == 0)
        last_folder__ = '';
    end

    folder = uigetdir(last_folder__);
    if (folder ~= 0)
        last_folder__ = folder;
    end
end