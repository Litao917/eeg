function [ fname, msgId, argname, argpos ]  = generateArgumentDescriptor( inputs, callingFunc )
; %#ok<NOSEM> % Undocumented

% Copyright 2011 The MathWorks, Inc.

% initialize optional inputs to default values
fname = '';
argname = '';
argpos = [];

if numel( inputs ) > 0
    % Try to disambiguate between user specifying argument position or
    % function name as the fourth input
    if numel( inputs ) == 1
        if isa( inputs{1}, 'double' )
            if ~isscalar( inputs{1} ) 
                error( matlab.internal.validators.generateId( callingFunc, 'badFunctionName' ), ...
                    '%s', getString(message('MATLAB:validateattributes:badFunctionName')) )                
            elseif ~isfinite(inputs{1}) || ~(floor(inputs{1})==inputs{1}) || inputs{1} < 1
                error( matlab.internal.validators.generateId( callingFunc, 'badArgPosition' ), ...
                    '%s', getString(message('MATLAB:validateattributes:badArgPosition')) ) 
            end
        elseif ~ischar( inputs{1} )
            error( matlab.internal.validators.generateId( callingFunc, 'badFunctionName' ), ...
                '%s', getString(message('MATLAB:validateattributes:badFunctionName')) )
        end
    else
        if ~ischar( inputs{1} )
            error( matlab.internal.validators.generateId( callingFunc, 'badFunctionNameString' ), ...
                '%s', getString(message('MATLAB:validateattributes:badFunctionNameString')) );
        end
    end
    
    if ischar(inputs{1})
        fname = inputs{1};
    else
        argpos = inputs{1};
    end
end

if numel( inputs ) > 1
    if ~ischar( inputs{2} )
        error( matlab.internal.validators.generateId( callingFunc, 'badVariableName' ), ...
            '%s', getString(message('MATLAB:validateattributes:badVariableName')) )
    end
    
    argname = inputs{2};
end

if numel( inputs ) > 2
    % cascade the checks to get specific error messages
    if isnumeric(inputs{3}) && ...
            ( isscalar(inputs{3}) || isempty(inputs{3}) )
        % any empty is ok
        if ~isempty(inputs{3}) && ...
                (~isfinite(inputs{3}) || ~(floor(inputs{3})==inputs{3}) || inputs{3} < 1)
            error( matlab.internal.validators.generateId( callingFunc, 'badArgPosition' ), ...
                '%s', getString(message('MATLAB:validateattributes:badArgPosition')) )
        end
    else
        error( matlab.internal.validators.generateId( callingFunc, 'badArgPositionClass' ), ...
            '%s', getString(message('MATLAB:validateattributes:badArgPositionClass')) )
    end
            
    argpos = inputs{3};
end

% build the argument descriptor based on which inputs were specified
% by the user
if isempty( argpos )
    if isempty( argname )
        msgId = 'NoNameNoNumber';
    else
        msgId = 'NameNoNumber';
    end
else
    if isempty( argname )
        msgId = 'NoNameNumber';
    else
        msgId = 'NameNumber';
    end
end    

end
