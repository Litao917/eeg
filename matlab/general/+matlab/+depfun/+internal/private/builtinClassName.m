function [name, clsFile] = builtinClassName(whichResult)
% builtinClassName Return class name and class file assuming whichResult 
% indicates a built-in class. Results unpredictable and likely wrong if
% called with a non-built-in whichResult.
    name = '';
    space = strfind(whichResult, ' ');
    if isempty(space)
        error(message('MATLAB:Completion:InvalidClassInfo', ...
            '<unknown>', whichResult));
    else
        space = space(1);  % You can have too much space.
    end
    
    % Get the first "word" from the whichResult -- everything up to the
    % first space. This is either a function name or the word "built-in".
    nm = whichResult(1:space(1)-1);
    
    [type, clsFile] = classUsingBuiltinCTOR(whichResult);
    if type == matlab.depfun.internal.MatlabType.NotYetKnown
        % Try hard to do better than <X is a built-in method>. But if the
        % WHAT result directory has no @-sign in it, it isn't a class
        % directory.
        partialClassDir = strrep(nm,'.','/');
        w = what(partialClassDir);
        if ~isempty(w)
            keep = ~cellfun('isempty',strfind({w.path},'@'));
            w = w(keep);
            if ~isempty(w)

                % TODO: Decide between the first directory on the path or
                % the directory returned by which.
                if numel(w.path) > 1
                    w = w(1);
                end
                
                dotIdx = strfind(nm,'.');
                cls = nm;
                if ~isempty(dotIdx)
                    dotIdx = dotIdx(end);
                    cls = nm(dotIdx+1:end);
                end
                % Need path information in the file-spec so that exclude
                % and expect rules can operate on built-in class
                % constructors.
                clsFile = ['built-in (' w.path filesep cls ')'];
                %clsFile = matlab.depfun.internal.cacheWhich(cls);
                name = nm;
            end
        end
        if isempty(clsFile)
            clsFile = whichResult;
            if existClass(nm)
                name = nm;
            end
        end
    else
        name = nm;
    end
    
    % MATLAB intrinsic built-in types (@cell, etc.) are ill-treated by the
    % tests above. Look for them here.
    if isempty(name) || isempty(clsFile)
        % Look for methods of the form:
        %   'built-in (....@class/method)'

        %prefix = [nm ' built-in ('];
        prefix = 'built-in (';
        prefixSize = numel(prefix);
        if strncmp(prefix, whichResult, prefixSize)
            mth = whichResult(prefixSize+1:end-1);
            [name, clsFile] = className(mth); % Recursive call, perhaps
            if ~isempty(name) && ~isempty(strfind(clsFile,mth))
                % Don't change whichResult for class constructor.
                clsFile = whichResult; 
            else
                % Find the first @ or +, either of which can begin a
                % qualified name.
                plusIdx = strfind(mth,'+');
                atIdx = strfind(mth, '@');
                qStart = 1;
                if ~isempty(atIdx)
                    atIdx = atIdx(1);
                    qStart = atIdx;
                end
                if ~isempty(plusIdx)
                    plusIdx = plusIdx(1);
                    if plusIdx < atIdx
                        qStart = plusIdx;
                    end
                end
                % Require an @ for this file to have a class name.
                if ~isempty(atIdx)
                    fsIdx = strfind(mth, filesep);
                    if ~isempty(fsIdx)
                        fsIdx = fsIdx(end);
                        name = mth(qStart+1:fsIdx-1);
                        clsFile = matlab.depfun.internal.cacheWhich(name);
                    end
                end
            end
        end
    end

end