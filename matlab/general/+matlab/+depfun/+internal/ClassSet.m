classdef ClassSet < handle
% ClassSet Maintain a lookup table of all classes encountered during analysis.

    properties(Access = protected)
        Classes    % ClassSymbol
    end

    properties(Dependent)
        NumEntries
    end

    methods(Access = private)

        function cs = findClassByName(obj, name)
        % findClassByName Return the ClassSymbol for the named class.
            cs = [];
            if isKey(obj.Classes, name)
                cs = obj.Classes(name);
            end            
        end
        
        function cs = findClass(obj, sym)
        % findClass Return the ClassSymbol for the class containing SYM.
            cs = [];
            name = className(sym.WhichResult);
            if isKey(obj.Classes, name)
                cs = obj.Classes(name);
            end
        end

    end % Private methods
    
    methods (Static)
        function [name, type] = classNameAndType(pth)
            % Calling the private functions (not methods)
            name = className(pth);
            type = classType(name, pth);
        end
        
        function registerClassFilters(exclude, expect, allow)
            excludeFilter(exclude);
            if nargin > 1
                expectFilter(expect);
            end
            if nargin > 2   
                allowFilter(allow);
            end
        end
    end
    
    methods
        
        function n = get.NumEntries(s)
            n = length(s.Classes);
        end
        
        function obj = ClassSet(obj)
        % ClassSet Constructor for ClassSet objects.
            obj.Classes = containers.Map;
        end

        function pth = constructorFile(obj, sym)
        % constructorFile Return a path to the constructor of class that
        % defines the input symbol.

            % Assume the worst -- that sym does not represent a method
            % or that the class that defines it is unknown.
            pth = '';
            cs = findClass(obj, sym);
            if ~isempty(cs)
                pth = cs.ConstructorFile;
            end
        end

        function [name, type, ctor] = classInfo(obj, sym)
        % classInfo Return class name, type, constructor file.

            % Assume the worst -- that sym does not represent a method
            % or that the class that defines it is unknown.
            name = '';
            type = matlab.depfun.internal.MatlabType.NotYetKnown;
            ctor = '';
            cs = findClass(obj, sym);
            if ~isempty(cs)
                name = cs.ClassName;
                type = cs.ClassType;
                ctor = cs.ConstructorFile;
            end
        end

        function pth = classDir(obj, qName)
        % classDir Return the full path to the class directory.
            pth = '';
            cs = findClassByName(obj, qName);
            if ~isempty(cs)
                pth = cs.ClassDir;
            end
        end
        
        function [fileList, fileType, classType] = classFiles(obj, sym)
        % classFiles Return a list of all the files owned by the class that
        % defines SYM.
            fileList = {};
            fileType = matlab.depfun.internal.MatlabType.NotYetKnown;
            classType = matlab.depfun.internal.MatlabType.NotYetKnown;
            cs = findClass(obj, sym);
            if ~isempty(cs)
                % TODO: Include constructor file?
                [fileList, fileType] = cs.classFilesAndTypes();
                classType = cs.ClassType;
            end
        end
        
        function add(s, sym)
        % ADD Insert a class into the set of known classes.
        % s: The ClassSet object.
        % sym: A MatlabSymbol representing the class.
        
            import matlab.depfun.internal.ClassSet;
            import matlab.depfun.internal.ClassSymbol;
            
            % If sym not a class, don't add it.
            if ~isClass(sym.Type) && ~isMethod(sym.Type)
                error(message('MATLAB:Completion:InvalidClassInfo', ...
                              sym.Symbol, sym.WhichResult));
            end
            
            % Don't include classes that users have filtered out, or that
            % we expect to exist on the target.
            isExcluded = excludeFilter();
            isExpected = expectFilter();
            isAllowed = allowFilter();
            
            if ((~isempty(isExpected) && isExpected(sym.WhichResult)) && ...
                (isempty(isAllowed) || ~isAllowed(sym.WhichResult))) || ...
                (~isempty(isExcluded) && isExcluded(sym.WhichResult))
                return;
            end
            
            % Extract the class name from the full path to the file
            % identifying the class. This file may be any method of the 
            % class, a schema file, the constructor function or the 
            % classdef file.
            c = className(sym.WhichResult);
            
            if isempty(c)
                c = sym.Symbol;
            end
           
            % If we've got a class name, make an entry in the table.
            if ischar(c) && ~isempty(c)
                if ~isKey(s.Classes, c)
                    cls = ClassSymbol(c, sym.WhichResult, sym.Type);
                    if ~isempty(cls)
                        s.Classes(c) = cls;
                    end
                end
            else
                error(message('MATLAB:Completion:InvalidClassInfo', ...
                              sym.Symbol, sym.WhichResult));
            end
        end
        
        function type = classType(s, name)
            import matlab.depfun.internal.MatlabType;
            type = MatlabType.NotYetKnown;
            cs = findClassByName(s, name);
            if ~isempty(cs)
                type = cs.ClassType;
            end            
        end
                
        function clear(s)
        % CLEAR Clear the Class Set -- forget all the classes you've seen. 
            remove(s.Classes, keys(s.Classes));
        end
        
        function remove(s, c)
            remove(s.Classes, c);
        end
        
        function tf = isempty(s)
        % ISEMPTY The ClassSet is empty if it has no key/value pairs.
            tf = length(s.Classes) == 0;
        end
        
        function cList = knownClasses(s)
            cList = keys(s.Classes);
        end
        
        function tf = isKnownClass(s, c)
            tf = false;
            if isKey(s.Classes, c)
                tf = true;
            end
        end        
    end            
end

%------------------------------------------------------------------------
% Class static variables, implemented via local functions and persistent
% variables.

function f = excludeFilter(f)
    persistent filter
    if nargin == 1
        filter = f;
    else
        f = filter;
    end
end

function f = expectFilter(f)
    persistent filter
    if nargin == 1
        filter = f;
    else
        f = filter;
    end
end

function f = allowFilter(f)
    persistent filter
    if nargin == 1
        filter = f;
    else
        f = filter;
    end
end
