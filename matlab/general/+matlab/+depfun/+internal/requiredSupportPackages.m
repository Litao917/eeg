function [ supportpackagelist ] = requiredSupportPackages( depfilelist, depproductlist )
%dependencySupportPackageList returns a list of all installed support
%packages, their base product and a flag indicating if the files or
%products provided as input depend on them
   

    % For dependencies based on products 
    % Only care about non-MATLAB support packages
    
    topOnlyResults = {};
    
    productsToIgnore = {'MATLAB'};

    supportpackagelist = {};
    
    % get the list of installed support packages
    pkgInstaller = hwconnectinstaller.PackageInstaller;
    pkgs = pkgInstaller.getInstalledPackages;

    

    pkgCnt = length(pkgs);
    includedPkg = 1;
     
    for pkgItr=1:pkgCnt
        dependentFlag = 'false';
        % check if there is a dependency on the path
        % go through the list of Paths in pkg.path and see if any of the files in depfilelist begin with that path 
        pathCnt = length(pkgs(pkgItr).Path); % there can be more than one path for a package
        for pathItr=1:pathCnt
           if( any (strncmp(pkgs(pkgItr).Path(pathItr), depfilelist, length(char(pkgs(pkgItr).Path(pathItr))))))
               dependentFlag = 'true';
           end
        end
        
        % if dependentFlag is still false check for product dependencies
        if (strcmp(dependentFlag, 'false'))
            if( ~ any (strcmp(pkgs(pkgItr).BaseProduct , productsToIgnore)))
                % check the baseproduct for the package against the
                % provided depproductlist
                if( any (strcmp(pkgs(pkgItr).BaseProduct, depproductlist)))
                    dependentFlag = 'true';
                end
            end
        end
        
        % If dependentFlag is STILL false check for mcc.xml depencies
        % This is a special case added for webcam which is a MATLAB Support
        % Package. There may be other MATLAB support packages that do this
        % so we aren't hard coding this check just for webcam. We are
        % limiting it to just MATLAB support packages. Non-MATLAB support
        % packs should get included based on the product dependency test
        % above
        if (strcmp(dependentFlag, 'false') && strcmp(pkgs(pkgItr).BaseProduct, 'MATLAB'))
            if(isempty(topOnlyResults))
                topOnlyResults = getTopOnlyResults(depfilelist);
            end
            
             if(checkApiDependencies(pkgs(pkgItr), topOnlyResults))
                 dependentFlag = 'true';
             end
            
            
        end
        
        
              
        % additions to check for 3rd party dependencies
        tpInstalls = length(pkgs(pkgItr).TpPkg);
        
        tpData = {};
        % if there are find the name, url and download url for each one
        for tpI = 1:tpInstalls
          tpData(tpI, :) = {pkgs(pkgItr).TpPkg(tpI).Name pkgs(pkgItr).TpPkg(tpI).Url [pkgs(pkgItr).TpPkg(tpI).DownloadUrl '/' pkgs(pkgItr).TpPkg(tpI).FileName]};
         
        end
        
       
        % only return the support package if the flag is set to true
        if(strcmp(dependentFlag, 'true'))
            supportpackagelist(includedPkg,:) = { pkgs(pkgItr).Name pkgs(pkgItr).DisplayName pkgs(pkgItr).BaseProduct dependentFlag tpInstalls tpData};
            includedPkg = includedPkg + 1;
        end
    end
    

end


function topOnlyResults = getTopOnlyResults(depfilelist)
    
    

    p = matlab.depfun.internal.Completion(depfilelist, matlab.depfun.internal.Target.All, true);
   
    pParts = p.parts;
    
    fileCnt = length(pParts);
    topOnlyResults = cell(1, fileCnt);
    for fileItr = 1:fileCnt
        topOnlyResults{fileItr} = pParts(fileItr).path;
    end

end

function  isDependent = checkApiDependencies(pkg, topOnlyResults)
    % function to read the mcc.xml file for the support package (if it
    % exists) and check to see if this app uses any of the api calls listed
    % as dependencies for the support package.
    isDependent = 0;
    
    % copied from prune and copy.
    % should refactor this at some point
    
    
    % for changing where the java error reporting is sent
    oldJavaError = java.lang.System.err;
    newJavaError = java.io.PrintStream(java.io.ByteArrayOutputStream());
    
    
     % check for the registry/mcc.xml file
        mccxmlFile = fullfile(pkg.RootDir, 'registry', 'mcc.xml');
        if(~isempty(dir(mccxmlFile)))
            
            % don't want the java aml read errors being printed out
             java.lang.System.setErr(newJavaError);
            
            try
                % check the mcc.xml file has a dependency section
                %   and that there is at least one file listed there
                % read the mcc.xml file
                mccxml = xmlread(mccxmlFile);
                dependencyNode = mccxml.getElementsByTagName('dependency');

                if(dependencyNode.getLength() > 0 )
                    fileNodes = dependencyNode.item(0).getElementsByTagName('file');
                end
                
                % get the count of files
                fileCnt = fileNodes.getLength();
                
                for fileItr = 0:fileCnt -1 % 0 based arrays
                    
                    nFile = char(fileNodes.item(fileItr).getAttribute('path'));
                    filePath = fullfile(matlabroot, 'toolbox', nFile);
        
                    %check if the file is in the dependent file list
                    if (any (strcmp(filePath, topOnlyResults)))
                        isDependent = 1;
                        break
                    end
                    
                end
                
                
            catch 
                % bad mcc.xml file
                % for now we are ignoring this
            end
             java.lang.System.setErr(oldJavaError);
        end
    

end

