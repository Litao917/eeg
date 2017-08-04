function timercb(obj,type,val,event)
%TIMERCB Wrapper for timer object callback.
%
%   TIMERCB(OBJ,TYPE,VAL,EVENT) calls the function VAL with parameters
%   OBJ and EVENT.  This function is not intended to be called by the 
%   user.
%
%   See also TIMER
%

%    Copyright 2001-2008 The MathWorks, Inc.

if ~isvalid(obj)
    return;
end
try  
    if isa(val,'char') % strings are evaled in base workspace.
        evalin('base',val);
    else % non-strings are fevaled with calling object and event struct as parameters
    % Construct the event structure.  The callback is expected to be of cb(obj,event,...) format
        eventStruct = struct(event);
        eventStruct.Data = struct(eventStruct.Data);
    
	% make sure val is a cell / only not a cell if user specified a function handle as callback.
        if isa(val, 'function_handle')
            val = {val};
        end	
     % Execute callback function.
        if iscell(val)
    		feval(val{1}, obj, eventStruct, val{2:end});
        else
            error(message('MATLAB:timer:IncorrectCallbackInput')); 
        end
    end        
catch exception
    if ~ strcmp(type,'ErrorFcn') && isJavaTimer(obj.jobject)
        try %#ok<TRYNC>
           obj.jobject.callErrorFcn(exception.message,exception.identifier);
        end
    end
    identifier = 'MATLAB:timer:badcallback';
    %Displays the exception message without throwing it.
    disp(getReport(MException(identifier, '%s', ...
                getString(message(identifier, type, get(obj,'Name'), exception.message)))));
end
