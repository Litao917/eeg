function instrcb(val,obj,event)
%INSTRCB Wrapper for serial object callback.
%
%  INSTRCB(FCN,OBJ,EVENT) calls the function FCN with parameters
%  OBJ and EVENT.
%

%   MP 7-13-99
%   Copyright 1999-2011 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2011/05/13 17:36:40 $

% Store the warning state. Note, reset warning to address 
% G309961 which was causing the same last warn to be rethrown.
lastwarn('');
s = warning('backtrace', 'off');

switch (nargin)
case 1
    try
        evalin('base', val);
    catch aException
        eval(['war' 'ning(s)']);
        rethrow(aException);
    end
case 3    
    % Construct the event structure.
    eventStruct = struct(event);
    eventStruct.Data = struct(eventStruct.Data);
 
    if isa(val, 'function_handle')
        val = {val};
    end
    
    % Execute callback function.
    try
        feval(val{1}, obj, eventStruct, val{2:end});
    catch aException
        eval(['war' 'ning(s)']);
        rethrow(aException);
    end
end

% Restore the warning state.
eval(['war' 'ning(s)']);
  
% Report the last warning if it occurred.
if ~isempty(lastwarn)
   warning(message('MATLAB:serial:instrcb:invalidcallback', lastwarn));
end

