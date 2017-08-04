function files = existing(files)
    e = cellfun(@(f)exist(f,'file') == 2, files);
    files = files(e);
    
