function [validNames, modified] = makeValidName(names, modException, varargin)
%MAKEVALIDNAME Construct valid MATLAB identifiers from input strings
%   MAKEVALIDNAME is a private function for table that wraps around
%   MATLAB.LANG.MAKEVALIDNAME. It adds exception control for when
%   input strings contains invalid identifier.   
%
%   VARNAMES = MAKEVALIDNAME(STRINGS, MODEXCEPTION) returns valid 
%   identifiers, VARNAMES, constructed from the input STRINGS. STRINGS is 
%   specified as a string or a cell array of strings. 
%
%   MODEXCEPTION controls warning or error response when STRINGS contains 
%   invalid MATLAB identifiers. Valid values for MODEXCEPTION are 'silent',
%   'warn' and 'error', respectively meaning no warning/error, a warning or
%   an error will be thrown when STRINGS contain invalid identifiers.
%
%   See also MATLAB.LANG.MAKEVALIDNAME

%   Copyright 2013 The MathWorks, Inc.

[validNames, modified] = matlab.lang.makeValidName(names, varargin{:});

if any(modified)        
    switch modException % Throw exception per level specified
        case 'warn'
            warning(message('MATLAB:table:ModifiedVarnames'));
        case 'error'
            % Find first modified name
            firstModifiedName = names;
            if iscell(names)
                firstModifiedName = names{find(modified,1)};
            end
            % Error and include the first modeified name in message
            error(message('MATLAB:table:InvalidVariableName', firstModifiedName));
        case 'silent'
            % makeValid without throwing any exception
        otherwise
            % modException should only  be one of the above valid options. 
            % The code goes through here when NOT all valid options are 
            % captured in the cases above - an exception will be thrown.
            assert(false);
    end
end
end