function out = validatestring( varargin )
%VALIDATESTRING Check validity of text string.
%   VALIDSTR = VALIDATESTRING(STR,VALID_STRINGS) checks the validity of
%   text string STR. If STR is an unambiguous, case-insensitive match to
%   one or more strings in cell array VALID_STRINGS, VALIDATESTRING returns
%   the matching string in VALIDSTR. Otherwise, VALIDATESTRING issues a
%   formatted error message.
%
%   VALIDSTR = VALIDATESTRING(STR,VALID_STRINGS,ARG_INDEX) includes the 
%   position of the input in your function argument list as part of any
%   generated error messages.
%
%   VALIDSTR = VALIDATESTRING(STR,VALID_STRINGS,FUNC_NAME) includes the 
%   specified function name in generated error identifiers.
%
%   VALIDSTR = VALIDATESTRING(STR,VALID_STRINGS,FUNC_NAME,VAR_NAME) includes 
%   the specified variable name in generated error messages.
%
%   VALIDSTR = VALIDATESTRING(STR,VALID_STRINGS,FUNC_NAME,VAR_NAME,ARG_INDEX) 
%   includes the specified information in the generated error messages or
%   identifiers.
%
%   Input Arguments:
%
%   VALID_STRINGS   Cell array of text strings.
%
%   ARG_INDEX       Positive integer that specifies the position of the
%                   input argument.
%
%   FUNC_NAME       String that specifies the function name. If you specify
%                   an empty string, '', FUNCNAME is ignored.
%
%   VAR_NAME        String that specifies input argument name. If you 
%                   specify an empty string, '', VARNAME is ignored.
%
%   Example: Define a cell array of text strings, and pass in another
%            string that is not in the cell array.
%
%       validatestring('C',{'A','B'},'func_name','var_name',2)
%
%   This code throws an error and displays a formatted message:
%
%       Error using func_name
%       Expected argument 2, var_name, to match one of these strings:
%
%         A, B
%
%       The input, 'C', did not match any of the valid strings.
%
%   See also validateattributes, inputParser.

%   Copyright 1993-2013 The MathWorks, Inc.

narginchk(2,5);

try
    [ in, validStrings, optional_inputs ] = checkInputs( varargin );
catch e
    % only VALIDATESTRING should be on the stack
    throw(e)
end

try    
    % check the contents of IN
    out = checkString( in, validStrings, optional_inputs);
    
catch e
    myId = 'MATLAB:validatestring:';
    if strncmp( myId, e.identifier, length(myId) )
        % leave VALIDATESTRING on the stack, because there was a misuse
        % of VALIDATESTRING itself
        throw(e)
    else
        % strip VALIDATESTRING off the stack so that the error looks like
        % it comes from the caller just as if it had hand-coded its input checking
        throwAsCaller( e )
    end
end

end

function out = checkString( in, validStrings, optional_inputs )

try
    if ~(ischar(in) && strcmp(in,''))
        validateattributes( in, {'char'}, {'row'} )
    end
catch e
    [ fname, msgId, argname, argpos ] = matlab.internal.validators.generateArgumentDescriptor( ...
        optional_inputs, 'validatestring' );
    argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );
    me = MException( matlab.internal.validators.generateId( fname, 'unrecognizedStringChoice' ),...
        '%s', getString(message( 'MATLAB:validatestring:unrecognizedStringChoice2', ...
                    argDes, validStringList( validStrings ))));
    me = me.addCause( e );
    throwAsCaller(me);
end

% do a case insensitive search, but use the case from validStrings,
% not the case from the input
if isempty(in)
    out = validStrings( ismember(validStrings,in) );
else
    out = validStrings( strncmpi( in, validStrings, length(in) ) );
end

if numel( out ) == 1
    % unambiguous match
    out = out{1};
elseif numel( out ) > 1
    % possibly ambiguous match
    
    % determine if all the matching strings are substrings of each other
    [ shortestMatchLength, shortestMatchIdx] = min( cellfun( @length, out ) );
    shortestMatch = out{shortestMatchIdx};
    allSubstrings = all( strncmpi( shortestMatch, out, shortestMatchLength ) );
        
    if allSubstrings
        % return the shortest match
        out = shortestMatch;
    else
        [ fname, msgId, argname, argpos ] = matlab.internal.validators.generateArgumentDescriptor( ...
            optional_inputs, 'validatestring' );
        argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );

        error( matlab.internal.validators.generateId( fname, 'ambiguousStringChoice' ), '%s', ...
            getString(message('MATLAB:validatestring:ambiguousStringChoice', ...
            argDes, validStringList( validStrings ), in)))
    end
else
    % no match found
    [ fname, msgId, argname, argpos ] = matlab.internal.validators.generateArgumentDescriptor( ...
        optional_inputs, 'validatestring' );
    argDes = matlab.internal.validators.getArgumentDescriptor( msgId, argname, argpos );

    error( matlab.internal.validators.generateId( fname, 'unrecognizedStringChoice' ), '%s', ...
        getString(message('MATLAB:validatestring:unrecognizedStringChoice3', ...
        argDes, validStringList( validStrings ), in )));
end

end

function s = validStringList( validStrings )
% create a comma separated list of the valid strings
s = sprintf( '''%s'', ', validStrings{:});
if ~isempty( s )
    s(end-1:end) = [];
end
end

function [ in, validStrings, optional_inputs ]  = checkInputs( inputs )
    
% 
in = inputs{1};
validStrings = inputs{2};

if ~iscellstr( validStrings )
    error(message('MATLAB:validatestring:invalidStringList'))
end

optional_inputs = inputs(3:end);

end
