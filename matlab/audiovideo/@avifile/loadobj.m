function obj = loadobj(B)
%LOADOBJ Load filter for avifile objects.
%
%    OBJ = LOADOBJ(B) is called by LOAD when an avifile object is 
%    loaded from a .MAT file. The return value, OBJ, is subsequently 
%    used by LOAD to populate the workspace.  
%
%    LOADOBJ will be separately invoked for each object in the .MAT file.

%    Copyright 2008-2013 The MathWorks, Inc.

filename = privateGet(B, 'Filename');
fps = privateGet(B, 'fps');
compression = privateGet(B, 'compression');
quality = privateGet(B, 'quality');
keyframes = privateGet(B, 'keyframepersec');
videoname = privateGet(B, 'videoname');

ws = warning('off', 'MATLAB:audiovideo:aviset:compressionUnsupported');
cleanup = onCleanup(@() warning(ws));

if isempty(B.Bitmapheader.Colormap)
    obj = avifile(filename, 'fps', fps, 'Compression', compression, ...
        'quality', quality, 'keyframe', keyframes, ...
        'videoname', videoname);
else
    colormap = B.Bitmapheader.Colormap';
    colormap = double(fliplr(colormap(:, 1:3)))/255;
    obj = avifile(filename, 'fps', fps, 'Compression', compression, ...
        'quality', quality, 'keyframe', keyframes, ...
        'videoname', videoname, 'Colormap', colormap);
end