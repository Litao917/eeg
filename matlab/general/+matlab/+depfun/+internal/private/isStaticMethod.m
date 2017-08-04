function tf = isStaticMethod(symbolName, clsFile)
% isStaticMethod Is the symbol a static function of the given class?

    tf = false;

    % Non-existent files can't contain static methods.
    if isempty(clsFile)
        return;
    end
    
    % Retrieve or create the parse tree for this file.
    mt = matlab.depfun.internal.cacheMtree(clsFile);
    if isempty(mt)
        return;
    end
    
    % Don't anaylze files with syntax errors
    mterr = mtfind(mt, 'Kind', 'ERR');
    if ~isempty(mterr)
        error(message('MATLAB:Completion:BadSyntax', clsFile, string(mterr))); 
    end
    
    % If this is a classdef file, look for the methods sections with a
    % Static attribute.
    
    clsdef = mtfind(mt, 'Kind', 'CLASSDEF');
    if ~isempty(clsdef)
        % Get the class name
        cnameNode = Cexpr(clsdef);
        ltNode = mtfind(cnameNode,'Kind','LT');
        if ~isempty(ltNode)
            cnameNode = Left(ltNode);
        end
        className = string(cnameNode);
        
        % Find all the static attributes.
        staticAttr = mtfind(mt,'Kind','ATTR', 'Left.String', 'Static');
        
        % from the set of staticAttr find the subset where Static is flase
        staticFalseAttr = mtfind(staticAttr, 'Kind','ATTR', 'Right.String', 'false');
        
        % remove the Static = false nodes from the set
        trueStaticAttr = staticAttr - staticFalseAttr;
        
        % get the method nodes 
        methodSections = mtfind(trueparent(trueparent(trueStaticAttr)), ...
                                'Kind', 'METHODS');
                            
        % the call to body doesn't return all the nodes in the body just the first one                    
        methodNodes = Body(methodSections);
        
        % need to loop over the nodes in the body with subsequent calls to
        % next (at the end of this while loop
        while (tf == false && ~isempty(methodNodes))
        
            % get the function names
            % mtfind with 'Kind' 'FUNCTION' wasn't getting all of them  since some are listed as PROTO
            
            names = Fname(methodNodes);
            nameIDs = indices(names);
            nameCount = numel(nameIDs);
            k = 1;
            while tf == false && k <= nameCount
                % Function name nodes
                name = string(select(mt,nameIDs(k)));

                % Match symbolName exactly, or <class name>.symbolName
                % TODO: Allow match to be proper suffix of longer string?

                tf = strcmp(name, symbolName) || ...
                     strcmp([className '.' name], symbolName);

                % it's possible for static functions to be qualified with the
                % package name
                if(~tf)
                    lSymbolName = length(symbolName);
                    lClassName = length([className '.' name]);
                    if(lSymbolName > lClassName )
                        unQualifiedSymbolName = symbolName(lSymbolName - lClassName +1 : lSymbolName);
                        tf = strcmp([className '.' name], unQualifiedSymbolName);
                    end
                end

                k = k + 1;
            end
            methodNodes = methodNodes.Next;
        end
    end   
end
