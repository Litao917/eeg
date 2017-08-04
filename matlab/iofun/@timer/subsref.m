function result = subsref(obj, Struct)
%SUBSREF Subscripted reference into timer objects.
%
%   SUBSREF Subscripted reference into timer objects.
%
%   OBJ(I) is an array formed from the elements of OBJ specified by the
%   subscript vector I.  
%
%   OBJ.PROPERTY returns the property value of PROPERTY for timer
%   object OBJ.
%
%   Supported syntax for timer objects:
%
%   Dot Notation:                  Equivalent Get Notation:
%   =============                  ========================
%   obj.Tag                        get(obj,'Tag')
%   obj(1).Tag                     get(obj(1),'Tag')
%   obj(1:4).Tag                   get(obj(1:4), 'Tag')
%   obj(1)                         
%
%   See also TIMER/GET.

%    Copyright 2001-2009 The MathWorks, Inc.

StructL = length(Struct);
result = obj;

try
    dotrefFound = false; % no referencing beyond the dot will be allowed.
    for lcv=1:StructL
        switch Struct(lcv).type
        case '.'
            if (dotrefFound) % indexing into properties not currently supported by language.
                error(message('MATLAB:timer:inconsistentdotref'));
            end
                result = get(result,Struct(lcv).subs);
                dotrefFound = true;
        case '()'
            if (dotrefFound) % indexing into properties not currently supported by language.
                error(message('MATLAB:timer:inconsistentsubscript'));
            end
            % Error if index is a non-number.
            for i=1:length(Struct(lcv).subs)
                ind = Struct(lcv).subs{i};
                if ~islogical(ind) && ~isnumeric(ind) && ~ischar(ind)
                    error(message('MATLAB:timer:badsubscript', class(ind)));
                end
                % Make sure that the indices are a vector.  This will be
                % true if the length of ind is equal to the number of
                % elements in ind.
                if (length(ind) ~= numel(ind))
                    error(message('MATLAB:timer:creatematrix'));
                end
            end
            result.jobject = result.jobject(Struct(lcv).subs{:});
        case '{}' % all the cell referencing needed should have already been handled by MATLAB
            error(message('MATLAB:timer:badcellref'));
        otherwise
            error(message('MATLAB:timer:badref',Struct(1).type));
        end
    end    
catch exception
    throw(fixexception(exception));
end  

