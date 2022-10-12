function set_active(options)
    arguments
        options.root (1,1) string = './';
        options.suffix (1,1) string = '';
    end

    setenv("PROJECT_ROOT",options.root)
    setenv("PROJECT_WORKSPACE",options.suffix)

end