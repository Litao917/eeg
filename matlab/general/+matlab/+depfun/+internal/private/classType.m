function type = classType(qName, whichResult)
% classType Given a qualified name and the result of calling WHICH on 
% that name determine if the name represents a class, and if so, what kind
% of class (UDD, MCOS, OOPS).
%
% The reported class type (for the same qName) may differ depending on the
% input whichResult. If qName identifies a UDD class with a built-in
% constructor, a whichResult containing @s will result in a class type of
% UDDClass, while a whichResult containing the string 'built-in' will
% result in a class type of BuiltinClass. 
%
    import matlab.depfun.internal.MatlabType;
    type = MatlabType.NotYetKnown;
    fs = filesep; % Surprisingly expensive, when called thousands of times
    
    % Have we seen this class already?
    type = matlab.depfun.internal.MatlabSymbol.classType(qName);
    if type ~= MatlabType.NotYetKnown
        return;
    end
    
    % Is qName a built-in class? Check the class file text.
    % It's built-in if both of these conditions are true:
    %   * The word built-in appears in the which result 
    %   * The word 'method' or the @-sign appears in the which result OR
    %     EXIST thinks it is a class.
    if ~isempty(strfind(whichResult, 'built-in')) && ...
       ((~isempty(strfind(whichResult, 'method')) || ...
        ~isempty(strfind(whichResult,'@'))) || existClass(qName))

        % UDD classes may look like built-ins.
        type = classUsingBuiltinCTOR(whichResult);
        if type == MatlabType.NotYetKnown
            type = MatlabType.BuiltinClass;
        end
        return;
    end
    
    % Single dot-qualified name: mathematical.thing. Use existence tests to
    % determine name's type.
    %
    %       If this exists                    The name is
    % -------------------------------------------------------------
    %   @mathematical/@thing/thing.m     UDD class
    %   @mathematical/thing.m            UDD package-scoped function
    %   +mathematical/@thing/thing.m     MCOS class
    %   +mathematical/thing.m            MCOS package-scoped fcn or class

    dotIdx = strfind(qName, '.');

    if ~isempty(dotIdx)
        nameParts = strsplit(qName,'.');

        if length(dotIdx) == 1
            atIdx = strfind(whichResult,'@');

            % @mathematical/@thing/thing.m => UDD class. Can't use
            % exist, because it always reports non-existence.
            if matlabFileExists(['@' nameParts{1} fs '@' nameParts{2} ...
                           fs nameParts{2}])
                type = MatlabType.UDDClass;
            
            
                
            % Class file doesn't exist, but has two @s. Should be UDD.
            % Check for builtin UDD -- call WHICH on class name. (Sometimes
            % the input whichResult is not the result of calling WHICH on
            % the qualified name.) This condition catches built-in UDD
            % classes specified by a help-only method file.
            elseif numel(atIdx) == 2
                clsWhich = matlab.depfun.internal.cacheWhich(qName);
                if ~isempty(strfind(clsWhich, 'built-in')) && ...
                    (~isempty(strfind(whichResult, 'method')) || ...
                    existClass(qName))
                        type = MatlabType.UDDClass;
                % Check for a schema.m file. UDD for sure, then.
                elseif matlabFileExists(['@' nameParts{1} fs '@' ...
                                         nameParts{2} fs 'schema.m'])
                    type = MatlabType.UDDClass;
                end              
              
            % +mathematical/@thing/thing.m => MCOS class
            elseif matlabFileExists(...
                    ['+' nameParts{1} fs '@' nameParts{2} ...
                               fs nameParts{2}])
                type = MatlabType.MCOSClass;

            % +mathematical/thing.m => MCOS class if file has classdef
            elseif matlabFileExists(...
                    ['+' nameParts{1} fs nameParts{2}])
                if isClassdef(['+' nameParts{1} fs nameParts{2} '.m']);
                    type = MatlabType.MCOSClass;
                else
                    type = MatlabType.OOPSClass;
                end
            end
        else
            % Multiple dots.
            %   +my/+amazing/+mathematical/@thing/thing.m => MCOS class
            %   +my/+amazing/+mathematical/thing.m => MCOS fcn or class

            if length(nameParts) > 2
                delim = [fs '+'];
                if fs == '\'
                    delim = ['\' delim];  % Escape \ for strjoin
                end
                pkgPrefix = ['+' strjoin(nameParts(1:end-1),delim)];
            end
            
            if matlabFileExists(...
                    [pkgPrefix fs '@' nameParts{end} ...
                           fs nameParts{end}])
                type = MatlabType.MCOSClass;
            else
                file = [pkgPrefix fs nameParts{end}];
                if matlabFileExists(file) 
                    if isClassdef(file)
                        type = MatlabType.MCOSClass;
                    else
                        type = MatlabType.OOPSClass;
                    end
                end
            end
        end
    else
        % No dots. An undecorated name.
        %
        % If the parent of @thing exists on the path:
        %   if thing.m is a classdef file, qName is an MCOS class.
        %   otherwise, qName is an OOPS class.
        %
        % If thing.m exists on the path and it contains CLASSDEF, qName is
        % an MCOS class.
        %
        % But! UDD package functions may have the same name as the package
        % that contains them: @collatz/collatz.m, for example, might be a 
        % UDD package function. Don't identify these functions as OOPS class
        % constructors.
        
        if ~isempty(whichResult) && matlabFileExists(whichResult) && ...
                isClassdef(whichResult)
            classDir = fileparts(whichResult);
            if isDirOnPath(classDir)
                type = MatlabType.MCOSClass;
            else
                sepIdx = strfind(classDir,fs);
                if ~isempty(sepIdx)
                    classDir = classDir(1:sepIdx(end)-1);
                    if isDirOnPath(classDir)
                        type = MatlabType.MCOSClass;
                    end
                end
            end
        end
        if type == MatlabType.NotYetKnown
            classDir = findAtDirOnPath(qName);
            if ~isempty(classDir)
                if iscell(classDir)
                    k = 1;
                    while (type == MatlabType.NotYetKnown && ...
                           k <= numel(classDir))
                        type = classTypeFromClassDir(classDir{k}, qName);
                        k = k + 1;
                    end
                else
                    type = classTypeFromClassDir(classDir, qName);
                end
            elseif matlabFileExists(qName) && isClassdef([qName '.m'])
                type = MatlabType.MCOSClass;
            end
        end
    end
end

function type = classTypeFromClassDir(classDir, cName)
    import matlab.depfun.internal.MatlabType;
    
    type = MatlabType.NotYetKnown;
    cdf = [classDir filesep cName];
    if matlabFileExists(cdf)
        if isClassdef([cdf '.m'])
            type = MatlabType.MCOSClass;
        elseif ~matlabFileExists([classDir filesep 'schema.m'])
            type = MatlabType.OOPSClass;
        end
    end
end
