function out = uninstall(mlappfile, appinstalldir)
%   This method will allow to uninstall a MATLAB App. 
%   Usage: uninstall(mlappfile, appinstalldir)
%
%   Copyright 2012 The MathWorks, Inc.
%
%     mlappfileloc = [appinstalldir filesep mlappfile];      
    if(~exist(appinstalldir, 'dir'))
        error(message('MATLAB:apps:uninstall:DirectoryNotFound', appinstalldir));
    end
    if(~exist(mlappfile,'file'))            
        error(message('MATLAB:apps:uninstall:MLAPPFileNotFound',mlappfile));
    end
    [~, allmexinmem] = inmem('-completenames');
    tbxmexfiles = strfind(allmexinmem, [matlabroot filesep 'toolbox']);
    tbfiles = cellfun(@(x)isempty(x),tbxmexfiles);
    usermexfile = allmexinmem(tbfiles);        
    [~, mexfilenames, ~] = cellfun(@(x) fileparts(x), usermexfile, 'UniformOutput',false);
    if(numel(mexfilenames))
        clear mex;
    end                            
    appmetadata = appinstall.internal.getappmetadata(mlappfile);
    entryPointPath = cellfun(@(x) strcmp(appmetadata.entryPoint, x), appmetadata.appEntries);
    allpaths = appmetadata.appEntries(~entryPointPath);
    cellfun(@(x) delete([appinstalldir filesep x]), appmetadata.appEntries, 'UniformOutput', false);
    [~, appdir, ~] = fileparts(appinstalldir);
    wrapperfile = genvarname(appdir);
    if(exist([appinstalldir filesep wrapperfile 'App.m'], 'file') == 2)
        delete([appinstalldir filesep wrapperfile 'App.m']);
    end
    if (exist([appinstalldir filesep 'metadata'], 'dir') == 7)
        rmdir([appinstalldir filesep 'metadata'], 's');
    end
    if (exist(mlappfile, 'file') == 2)       
        delete(mlappfile);
    end
    trulyallpaths = cell(0);
    for i = 1:numel(allpaths)
        trulyallpaths = fileancestors(allpaths{i}, trulyallpaths);
    end
    trulyallpaths = unique(trulyallpaths, 'sorted');
    dirstoremove = trulyallpaths(end:-1:1);
    for i = 1:numel(dirstoremove)        
        if numel(dir([appinstalldir dirstoremove{i}])) > 2
            folders = dir([appinstalldir dirstoremove{i}]);                  
            warning(message('MATLAB:apps:uninstall:UnknownDirFound', folders(numel(dir([appinstalldir dirstoremove{i}]))).name));
        else
            if(exist([appinstalldir dirstoremove{i}], 'dir') == 7)
                rmdir([appinstalldir dirstoremove{i}], 's');
            end
        end
    end       
    if numel(dir(appinstalldir)) > 2
        folders = dir(appinstalldir);       
        warning((message('MATLAB:apps:uninstall:UnknownDirFound',folders(numel(dir(appinstalldir))).name)));
        status = 2;
    else
        if(exist(appinstalldir, 'dir') == 7)
            [status, msg, messageid] = rmdir(appinstalldir, 's');
        else
            status = 1;
        end
    end    
    if(status)
        out = status;
    else
        exception = MException(messageid, msg);
        throw(exception);
    end                    
end
function ancestors = fileancestors( file, ancestors )
% FILEANCESTORS enumerates all directory ancestors for given input file 
% parameter and adds them to the input/output ancestors parameter 
    assert(file(1) == filesep, '<appFile> must start with filesep');
    while 1
        [pathstr, ~, ~] = fileparts(file);
        if pathstr == filesep
            break;
        end
        ancestors = [ancestors pathstr];
        file = pathstr;
    end 
end