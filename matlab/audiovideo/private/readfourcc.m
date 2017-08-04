function [rifftype,msg,msgID] = readfourcc(fid)
%READFOURCC read four character code
%   [RIFFTYPE,MSG] = READFOURCC(FID) returns a four character code RIFFTYPE
%   from the file represented by FID. If the desired amount of data was not
%   read, then MSG is a string containing an error message, otherwise MSG is
%   empty. 

%   Copyright 1984-2013 The MathWorks, Inc.

msg = '';
msgID='';
[rifftype, count] = fread(fid,4,'uchar');
rifftype = [char(rifftype)]';
if (count ~= 4)
  msgID='MATLAB:audiovideo:fourcc:invalidFourCC';
  msg = getString(message(msgID));
end
return;