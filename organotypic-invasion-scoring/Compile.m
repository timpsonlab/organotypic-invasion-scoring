function Compile
    
    % Get version
    [~,ver] = system('git describe','-echo');
    
    % Build App
    mkdir('build');
    delete(['build' filesep '*']);
    mcc('-m','Interface.m', ...
        '-C', '-v', '-m', '-d', 'build', '-o', 'Organotypic_Invasion_Scoring');
        
    if ispc
        ext = '.exe';
    else
        ext = '.app';
    end
   
    movefile(['build' filesep 'Organotypic_Invasion_Scoring' ext], ['build' filesep 'Organotypic Invasion Scoring ' ver ext]);
        