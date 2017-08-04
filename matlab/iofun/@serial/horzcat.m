function out = horzcat(varargin)
%HORZCAT Horizontal concatenation of serial port objects.
%

%   MP 7-13-99
%   Copyright 1999-2008 The MathWorks, Inc. 
%   $Revision: 1.5.4.6 $  $Date: 2011/05/13 17:36:04 $


% Initialize variables.
c=[];

% Loop through each java object and concatenate.
for i = 1:nargin
    if ~isempty(varargin{i}),
        if isempty(c),
            % Must be an instrument object otherwise error.
            if ~isa(varargin{i},'instrument'),
                error(message('MATLAB:serial:horzcat:nonInstrumentConcat'))
            end
            c=varargin{i};
        else
            
            % Extract needed information.
            try
               appendJObject = varargin{i}.jobject;
               appendType = varargin{i}.type;
               appendConstructor = varargin{i}.constructor;
            catch  %#ok<CTCH>
                % This will fail if not an instrument object.
                error(message('MATLAB:serial:horzcat:nonInstrumentConcat'))
            end
            
            % Append the jobject field.
            try
                c.jobject = [c.jobject appendJObject];
            catch aException
                rethrow(aException);
            end
            
            % Append the type field.
            if ischar(c.type)
                if ischar(appendType)
                    c.type = {c.type appendType};
                else
                    c.type = {c.type appendType{:}};
                end
            else
                if ischar(appendType)
                    c.type = {c.type{:} appendType};
                else
                    c.type = {c.type{:} appendType{:}};
                end
            end
            
            % Append the constructor.
            if ischar(c.constructor)
                if ischar(appendConstructor)
                    c.constructor = {c.constructor appendConstructor};
                else
                    c.constructor = {c.constructor appendConstructor{:}};
                end
            else
                if ischar(appendConstructor)
                    c.constructor = {c.constructor{:} appendConstructor};
                else
                    c.constructor = {c.constructor{:} appendConstructor{:}};
                end
            end
        end 
    end
end

% Verify that a matrix was not created.
if length(c.jobject) ~= numel(c.jobject)
   error(message('MATLAB:serial:horzcat:nonMatrixConcat'))
end

% Output the array of objects.
out = c;


