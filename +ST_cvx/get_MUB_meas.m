function r = get_MUB_meas(options)
    arguments
        options.J (1,1) double {mustBeHalfInteger,mustBeNonnegative} = 7.5;
        options.template (1,1) string;
    end
    dim = 2*options.J+1;

    r = zeros(dim*(dim+1),1);
    for ii = 1:(dim+1)
        [path,name,ext] = fileparts(options.template);
        fname = fullfile(path,strcat(sprintf(name,ii),ext));
        solution = load(fname);
        r(  (1:dim) + (ii-1)*dim ) = solution.populations;
    end
    r = r/(dim+1); % to be consistent with POVM definition

end