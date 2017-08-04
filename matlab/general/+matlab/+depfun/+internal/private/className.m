function [name, clsFile] = className(whichResult)
% className Given a path to a file, determine if the file belongs to a class.
% If so, return the name of the class and the path to the class
% constructor.

    fs = filesep;  % Expensive when called a bazillion times.
    
    % Check to see if the whichResult is the constructor for a built-in
    % class. There are two kinds of built-in constructors: those inherent
    % to MATLAB (like cell arrays) and those added by toolboxes (like
    % gpuArray).
    [name, clsFile] = builtinClassCTOR(whichResult);
 
    if isempty(name)
        clsFile = '';
        [pth,fcnName] = fileparts(whichResult);
        atIdx = strfind(whichResult,'@');
        
        % Does the whichResult specify a file in an @-directory?
        % Make sure to check for no-constructor cases:
        %    
        %  * UDD class specified by schema.m
        %  * OOPS class with no constructor.
        %  * All-builtin MCOS class.

        if ~isempty(atIdx)
            % Files in private directories under the class directory "belong" 
            % to the class. Chop /private off of pth if pth ends with
            % /private.
            private = [fs 'private'];
            privateDir = max(strfind(pth, private));

            if privateDir == numel(pth) - numel(private) + 1
                pth = pth(1:end-numel(private));
            end

            dirName = pth(atIdx(end)+1:end);

            if matlabFileExists([ pth fs dirName]) || ...
               matlabFileExists([ pth fs 'schema' ]) 

                % Find the first (leftmost) + or @ in the path part of the name.
                qStart = atIdx(1);
                plusIdx = strfind(pth, '+');
                if ~isempty(plusIdx)
                    qStart = min(qStart, plusIdx(1));
                end
                % Change the path specification into a qualified name
                name = qualifyName( pth(qStart:end) );
                clsFile = fullfile(pth, [dirName '.m']);

            elseif matlab.depfun.internal.cacheExist(pth,'dir')
                % An @-directory exists, but it does not contain a constructor
                % or schema. This is an extension method directory. Two
                % scenarios, neither pretty.
                %   * The class is built-in, like gpuArray.
                %   * The class has a classdef file somewhere else.
                
                % Find the first (leftmost) + or @ in the path part of the name.
                qStart = atIdx(1);
                plusIdx = strfind(pth, '+');
                if ~isempty(plusIdx)
                    qStart = min(qStart, plusIdx(1));
                end
                % Get the class name from the path.
                qName = qualifyName( pth(qStart:end) );
                qWhich = matlab.depfun.internal.cacheWhich(qName);
                
                % Is it a built-in?
                [name, clsFile] = builtinClassCTOR(whichResult);
                if isempty(name)
                    % Class directory must contain an '@'. If qWhich
                    % doesn't, then perhaps we have a shadowed constructor.
                    % Look for class directories using WHAT.
                    if isempty(strfind(qWhich, '@'))
                        w = what(pth(qStart:end));
                        if numel(w) == 1
                            name = qName;
                            clsFile = fullfile(w(1).path, ...
                                               pth(atIdx(end)+1:end));
                            % At this point, if the constructor doesn't
                            % exist, the constructor must be a built-in.
                            if ~matlabFileExists(clsFile)
                                clsFile = ['built-in (' clsFile ')'];
                            end
                        end
                    end
                    if isempty(name)
                        name = qName;
                        clsFile = qWhich;
                    end
                end         
            end

        % Does the whichResult specify a CLASSDEF file?
        elseif isClassdef(whichResult)
            name = fcnName;
            clsFile = whichResult;
            plusIdx = strfind(pth, '+');
            if ~isempty(plusIdx)
                name = qualifyName([pth(plusIdx(1):end) fs fcnName]);
            end
        end
    end
end






