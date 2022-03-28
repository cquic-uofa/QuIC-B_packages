function POVM = get_MUB_POVM(options)
    arguments
        options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
        % leave template as required argument for now
        options.template (1,1) string = "";
        options.conjugate (1,1) logical = true;
    end

    if options.template == ""
        root = getenv("QuICMATROOT");
        MUB_root = fullfile(root,"QuIC-B_packages","MUB");
        % this allows basis files to have different names
        options.template = fullfile(MUB_root,"*basis_%d.mat");

    end
    
    dim = 2*options.J+1;
    POVM = zeros(dim*(dim+1),dim^2); % superoperator for use in reconstruction
    
    for ii = 1:(dim+1)

        [path,name,ext] = fileparts(options.template);
        % sprintf can't deal with slashes in a string, fileparts removes the slash so the next line works
        MUB_file = dir(fullfile(path,strcat(sprintf(name,ii),ext)));
        data = load(fullfile(MUB_file.folder,MUB_file.name));
        basis = data.opt_params.target_uni;
        for jj = 1:dim
            if options.conjugate
                state = basis(jj,:); % target is already conjugated
                POVM((ii-1)*dim+jj,:) = super_operators.Op2DVec(state'*state);
            else
                state = basis(:,jj); % target is not conjugated
                POVM((ii-1)*dim+jj,:) = super_operators.Op2DVec(state*state');
            end
        end
        
    end
    POVM = POVM/(dim+1); % Σ(POVM) = I
end