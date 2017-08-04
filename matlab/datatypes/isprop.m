function valid = isprop(varargin)
%ISPROP Returns true if the property exists.
%   V = ISPROP(H, PROP) Returns true if PROP is a property of H.
%   V is a logical array of the same size as H.  Each true element of V
%   corresponds to an element of H that has the property PROP.

%   Copyright 1988-2013 The MathWorks, Inc.

narginchk(2,3);

switch nargin
    case 2
        try % size may be overloaded by the object and lead to error here
            valid = false(size(varargin{1}));
        catch % return FALSE when SIZE is overloaded to not return numbers
            valid = false;
            return;
        end
        
        if(isobject(varargin{1}) && ~isa(varargin{1}, 'handle'))
            hasPropFcn = @hasProp;
        else
            if isa(varargin{1}, 'double')
                varargin{1} = handle(varargin{1});
            end
            hasPropFcn = @hasPropI;
        end
        if numel(varargin{1}) == 1
            valid = hasPropFcn(varargin{1}, varargin{2});
        else
            for i = 1:numel(varargin{1})
                valid(i) = hasPropFcn(varargin{1}(i), varargin{2});
            end
        end
    case 3
        % ISPROP for class - package and class name
        try
            p=findprop(findclass(findpackage(varargin{1}),varargin{2}),varargin{3});
            valid = ~isempty(p) && strcmpi(p.Name,varargin{3});
        catch % return FALSE when FINDPROP fails above
            valid = false;
        end
    otherwise
        % Number of inputs should only be the above values
        assert(false);
end
end

function tf = hasProp( obj, propName)
    try
        mc = metaclass(obj);
        if isempty(mc)
            % no properties
            tf = false;
        else
            prop = findobj(mc.PropertyList, '-depth',0,'Name', propName);
            tf = ~isempty(prop);
        end
    catch
        tf = false;
    end
end

% case insensitive
function tf = hasPropI( obj, propName)
    try
        if isgraphics(obj) && ~graphicsversion(obj,'handlegraphics')
            mc = metaclass(obj);
            if isempty(mc)
                % no properties
                tf = false;
            else
                % First check if prop exists, it might be a dynamic prop, if so, no
                % case-insensitivity is allowed.
                tf = ~isempty(findprop(obj, propName));
                % Check case-insensitive name
                if tf == false
                    props = mc.PropertyList;
                    tf = any(strcmpi(propName, {props.Name}));
                end
            end
        else
            p=findprop(obj, propName);
            tf = ~isempty(p) && strcmpi(p.Name,propName);
        end
    catch
        tf = false;
    end
end