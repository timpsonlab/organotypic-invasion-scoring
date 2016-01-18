function Compile
    
    % Get version
    [~,ver] = system('git describe','-echo');
    ver = ver(1:end-1);
    
    % Build App
    try
    rmdir('build','s');
    catch
    end

    mkdir('build');
    delete(['build' filesep '*']);
    mcc('-m','Interface.m', ...
        '-v', '-m', '-d', 'build', '-o', 'Organotypic_Invasion_Scoring');
        
    if ispc
        ext = '.exe';
    else
        ext = '.app';
    end
   
    new_file = ['Organotypic Invasion Scoring ' ver];
    movefile(['build' filesep 'Organotypic_Invasion_Scoring' ext], ['build' filesep new_file ext]);
    
    if ismac
        mkdir(['build' filesep 'dist']);
        movefile(['build' filesep new_file ext], ['build' filesep 'dist' filesep new_file ext]);
        cmd = ['hdiutil create "./build/' new_file '.dmg" -srcfolder ./build/dist/ -volname "' new_file '" -ov'];
        disp(cmd)
        system(cmd)
    end

    