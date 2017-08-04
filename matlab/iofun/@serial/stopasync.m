function stopasync(obj)
%STOPASYNC Stop asynchronous read and write.
%
%   STOPASYNC(OBJ) stops the asynchronous read and write operation that
%   is in progress with the device connected to serial port object, OBJ.
%   OBJ can be an array of serial port objects.  
%
%   Data can be written asynchronously with the FPRINTF or FWRITE functions.
%   Data can be read asynchronously with the READASYNC function and by 
%   configuring the ReadAsyncMode property to continuous. In-progress
%   asynchronous operations are indicated by the TransferStatus property.
%
%   After the in-progress asynchronous operations are stopped, the 
%   TransferStatus property is configured to idle, the output buffer
%   is flushed and the ReadAsyncMode property is configured to manual.
%
%   Data in the input buffer is not flushed. This data can be returned to
%   the MATLAB workspace using any of the synchronous read functions, for
%   example, FREAD or FSCANF. 
%
%   If OBJ is an array of serial port objects and one of the objects cannot
%   be stopped, the remaining objects in the array will be stopped and a 
%   warning will be displayed.
%
%   Example:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, 'Function:Shape Sin', 'async');
%       stopasync(s);
%       fclose(s);
%
%   See also SERIAL/READASYNC, SERIAL/FREAD, SERIAL/FSCANF, SERIAL/FGETL,
%   SERIAL/FGETS.
%

%   MP 7-13-99
%   Copyright 1999-2011 The MathWorks, Inc. 
%   $Revision: 1.8.4.5 $  $Date: 2011/05/13 17:36:34 $

% Initialize variables.
errorOccurred = false;
jobject = igetfield(obj, 'jobject');

% Call stopasync on each java object.  Keep looping even 
% if one of the objects could not be stopped.  
for i=1:length(jobject)
   try
      stopasync(jobject(i));
   catch aException
   	  errorOccurred = true;	    
	  errmsg = aException.message;
   end   
end   

% Report error if one occurred.
if errorOccurred
    if length(jobject) == 1
        error(message('MATLAB:serial:stopasync:opfailed', errmsg));
    else
        warnState = warning('backtrace', 'off');
        warning(message('MATLAB:serial:stopasync:invalid'));
        warning(warnState);
    end
end
