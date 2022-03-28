function recursive_fit(root)

    dir_struct = dir(root);
    
    files = dir_struct(~[dir_struct.isdir]);
    folders = dir_struct([dir_struct.isdir]);
    
    for ii = 1:numel(folders)
        % 
        if strcmp(folders(ii).name,".")||strcmp(folders(ii).name,"..")
            continue % these are always present
        end
        nroot = fullfile(folders(ii).folder,folders(ii).name);
        quic_fits.recursive_fit(nroot);
    
    end
    
    key = strcmp("background.mat",{files.name});
    background_file = files(key);
    data_files = files(~key);
    if ~isempty(background_file)
        % do the stuff
        background = load(fullfile(background_file(1).folder,background_file(1).name));
        ndir = strcat(background_file.folder,"_fits");
        if ~exist(ndir,'dir')
            mkdir(ndir);
        end
        for ii = 1:numel(data_files)
            fin = fullfile(data_files(ii).folder,data_files(ii).name);
            % make parallel folder %(name)_fits with same file names suffixed with fit
            data = load(fin);
            if (~isfield(data,"SG_tof_3"))||(~isfield(data,"SG_tof_4"))
                continue
            end
            [~,fname,fext] = fileparts(data_files(ii).name);
    
            fout = fullfile(ndir,strcat(fname,"_fit",fext));
    
            solution = quic_fits.fit_SG(data,background);
            
            save(fout,"-struct","solution")
        end
    end
    
end