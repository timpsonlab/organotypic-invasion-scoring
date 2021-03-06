function Compile
    
    GetBioformats();

    % Get version
    [~,ver] = system('git describe','-echo');
    ver = ver(1:end-1);
    is_release = isempty(regexp(ver,'-\d-+[a-z0-9]+','ONCE'));

    % Get GUI extras
    if ~exist('uiextras.VBox','class')
        websave('guilayout.zip','http://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/47982/versions/6/download/zip')
        unzip('guilayout.zip');
        addpath('layout');
    end
    
    % Build App
    try
    rmdir('build','s');
    catch
    end

    mkdir('build');
    delete(['build' filesep '*']);
    mcc('-m','Interface.m', ...
        '-a','bfmatlab', ...
        '-v', '-d', 'build', '-o', 'Organotypic_Invasion_Scoring');
        
    if ispc
        ext = '.exe';
    else
        ext = '.app';
    end
   
    new_file = ['Organotypic Invasion Scoring ' ver ' ' computer('arch')];
    movefile(['build' filesep 'Organotypic_Invasion_Scoring' ext], ['build' filesep new_file ext]);
    
    if ismac
        mkdir(['build' filesep 'dist']);
        movefile(['build' filesep new_file ext], ['build' filesep 'dist' filesep new_file ext]);
        cmd = ['hdiutil create "./build/' new_file '.dmg" -srcfolder ./build/dist/ -volname "' new_file '" -ov'];
        system(cmd)
        final_file = ['build/' new_file '.dmg'];
    else
        final_file = ['build' filesep new_file ext];
    end
    
    if is_release
        dir1 = 'release';
    else 
        dir1 = 'latest';
    end
    mkdir(['build' filesep dir1]);
    mkdir(['build' filesep dir1 filesep ver]);
    
    movefile(final_file, ['build' filesep dir1 filesep ver]);
end