function cfg = load_config()

    cfg = default_config();

    if exist('local_config', 'file')
        local = local_config();
        cfg.paths = local.paths;
        disp('USING LOCAL PATHS')
        disp(cfg.paths.rawData)
    else
        disp('USING DEFAULT PATHS')
    end

end
