function [depfileslist, depsupportpackagelist] = filesAndSupportPackages(varargin)
% dependencyCompilerProject takes a function and returns the list of
% dependent files and support packages
            warnstatus = warning('OFF','MATLAB:Completion:AllInputsExcluded');
            restoreWarnState = onCleanup(@()warning(warnstatus));
            
            [depfileslist, depproducts] = matlab.codetools.requiredFilesAndProducts(varargin);   
           
             if(~isempty(depproducts))
                 depproductname = cellfun(@(x) char(x), {depproducts(:).Name}, 'UniformOutput',false);
                              
             else                           
                depproductname = {};
               
             end
            
             depsupportpackagelist = matlab.depfun.internal.requiredSupportPackages(depfileslist, depproductname);
             
            
        end

         