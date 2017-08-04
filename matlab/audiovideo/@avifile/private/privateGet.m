function value = privateGet(obj,param)
% PRIVATEGET Query objects from an AVIFILE object
%
%   PRIVATEGET is an internal AVIFILE function designed to allow both GET
%   and LOADOBJ to use the same code.  It should not be called directly by
%   code outside of the AVIFILE directory.

%   Copyright 2008-2013 The MathWorks, Inc.

switch lower(param)
 case 'filename'
  value = obj.Filename;
 case 'fps'
   value = getFpsFromHeaderFps( obj.MainHeader.Fps );
 case 'compression'
  value =obj.StreamHeader.fccHandler;
 case 'quality'
  value = obj.StreamHeader.Quality/100;
 case 'totalframes'
  value = obj.MainHeader.TotalFrames;
 case 'width'
  value = obj.MainHeader.Width;  
 case 'height'
  value = obj.MainHeader.Height;  
 case 'length'
  fps = getFpsFromHeaderFps( obj.MainHeader.Fps );
  value = obj.MainHeader.Length / fps;  
 case 'keyframepersec'
  fps = obj.MainHeader.Fps;  
  fps = 10^6/fps;
  KeyFrameEvery = obj.KeyFrameEveryNth;
  value = fps/KeyFrameEvery;
 case 'videoname'
  value = obj.StreamName;
 case 'imagetype'
  if obj.Bitmapheader.biBitCount == 24
    value = 'TrueColor';
  elseif obj.Bitmapheader.biBitCount == 8
    value = 'Indexed';
  else
    value = 'Unknown';
  end
 case 'currentstate'
  value = obj.CurrentState;
 otherwise
  error(message('MATLAB:audiovideo:avifileget:unrecognizedParameter', param));
end
return;
end

function fps = getFpsFromHeaderFps( headerFPS )
    fps = 1/headerFPS*10^6;
end
  
