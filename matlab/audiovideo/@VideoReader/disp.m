function disp(obj)
%DISP Display method for VideoReader objects.
%
%    DISP(OBJ) displays information pertaining to the VideoReader object.
%
%    See also VIDEOREADER/GET.

%    JCS
%    Copyright 2004-2013 The MathWorks, Inc.

if length(obj) > 1 || ~isvalid(obj)
    disp@hgsetget(obj);
    return;
end

% Determine if we want a compact or loose display.
isloose = strcmp(get(0,'FormatSpacing'),'loose');
if isloose,
   newline=sprintf('\n');
else
   newline=sprintf('');
end

% =========================================================================
% OBJECT PROPERTY VARIABLES:
% =========================================================================
objprops = {'Name', ...
            'BitsPerPixel', ...
            'FrameRate', ...
            'Height', ...
            'Width',...
            'NumberOfFrames'};

ObjVals = get(obj,objprops);

[Name, BitsPerPixel, FrameRate, Height, Width, NumberOfFrames] = ...
    deal(ObjVals{:});

% =========================================================================
% DYNAMIC DISPLAY BEGINS HERE...
% =========================================================================
% Display header:

st = getString(message('MATLAB:audiovideo:VideoReader:SummaryOfMultimediaReaderObject', ...
    newline, Name));
st=[st sprintf(newline)];
st=[st sprintf(['  ',getString(message('MATLAB:audiovideo:VideoReader:VideoParameters')),'  '])];

FrameString = '';
if (FrameRate > 0.0)
    FrameString = getString(message('MATLAB:audiovideo:VideoReader:FramesPerSecond', sprintf('%0.2f', FrameRate)));
    FrameString = [FrameString,' '];
end

FormatString = obj.VideoFormat;
st = [st sprintf('%s%s %dx%d.\n', FrameString, FormatString, ...
    Width, Height)];
st=[st sprintf('                     ')]; % Indent to align with previous row.

if (isempty(NumberOfFrames))
    st = [st getString(message('MATLAB:audiovideo:VideoReader:UnableToDetermineVideoFramesAvailable'))];
else
    st = [st getString(message('MATLAB:audiovideo:VideoReader:TotalVideoFramesAvailable', sprintf('%0d',NumberOfFrames)))];
end
st=[st  sprintf(newline)];

% File identifier...fid=1 outputs to the screen.
fid=1;
fprintf(fid,'%s', st);

    