function [aviobj] = addframe(aviobj,varargin)
%ADDFRAME  Add video frame to AVI file.
%   AVIFILE will be removed in a future release. Use VIDEOWRITER instead.
%
%   AVIOBJ = ADDFRAME(AVIOBJ,FRAME) appends the data in FRAME to AVIOBJ,
%   which is created with AVIFILE.  FRAME can be either an indexed image
%   (M-by-N) or a truecolor image (M-by-N-by-3) of double or uint8
%   precision.  If FRAME is not the first frame added to the AVI file, it
%   must be consistent with the dimensions of the previous frames.
%   
%   AVIOBJ = ADDFRAME(AVIOBJ,FRAME1,FRAME2,FRAME3,...) adds multiple
%   frames to an avifile.
%
%   AVIOBJ = ADDFRAME(AVIOBJ,MOV) appends the frame(s) contained in the
%   MATLAB movie MOV to the AVI file. MATLAB movies which store frames as
%   indexed images will use the colormap in the first frame as the colormap
%   for the AVI file unless the colormap has been previously set.
%
%   AVIOBJ = ADDFRAME(AVIOBJ,H) captures a frame from the figure or
%   axis handle H, and appends this frame to the AVI file. The frame is
%   rendered into an offscreen array before it is appended to the AVI file.
%   This syntax should not be used if the graphics in the animation are using
%   XOR graphics.
%
%   If the animation is using XOR graphics, use GETFRAME instead to capture
%   the graphics into one frame of a MATLAB movie and then use the syntax
%   [AVIOBJ] = ADDFRAME(AVIOBJ,MOV) as in the example below. GETFRAME will
%   perform a snapshot of the onscreen image.
% 
%   Example: 
%
%      t = linspace(0,2.5*pi,40);
%      fact = 10*sin(t);
%      fig=figure;
%      aviobj = avifile('example.avi')
%      [x,y,z] = peaks;
%      for k=1:length(fact)
%          h = surf(x,y,fact(k)*z);
%          axis([-3 3 -3 3 -80 80])
%          axis off
%          caxis([-90 90])
%          F = getframe(fig);
%          aviobj = addframe(aviobj,F);
%      end
%      close(fig)
%      aviobj = close(aviobj);
%
%   See also VIDEOWRITER, MOVIE2AVI.

%   Copyright 1984-2013 The MathWorks, Inc.

numframes = nargin - 1;
error(nargoutchk(1,1,nargout));
if ~isa(aviobj,'avifile')
  error(message('MATLAB:audiovideo:addframe:invalidAviFileObjectInput'));
end

for i = 1:numframes
  MovieLength = 1;
  mlMovie = 0;
  % Parse input arguments
  inputType = getInputType(varargin{i});
  switch inputType
   case 'axes'
    frame = getFrameForFigure(get(varargin{i},'parent'));
   case 'figure'
    frame = getFrameForFigure(varargin{i});
   case 'movie'
    mlMovie = 1;
    MovieLength = length(varargin{i});
    if ( ~isempty(varargin{i}(1).colormap) && ...
	 isempty(aviobj.Bitmapheader.Colormap) && ...
	 aviobj.MainHeader.TotalFrames == 0 )
      aviobj = set(aviobj,'Colormap',varargin{i}(1).colormap);
    end
   case 'data'
    frame = varargin{i};
   otherwise
    error(message('MATLAB:audiovideo:addframe:invalidInputType'));
  end

  for j = 1:MovieLength
    if mlMovie 
      frame = varargin{i}(j).cdata;
    end
    
    frameClass = class(frame);
    if isempty(strmatch(frameClass,strvcat('double','uint8')))
      error(message('MATLAB:audiovideo:addframe:invalidFrameType'));
    end
        
    % Determine image dimensions
    height = size(frame,1); 
    width = size(frame,2);
    dims = size(frame,3);

    % Check requirements for the Intel Indeo codec
    % Intel Indeo requires images dimensions to be a multiple of four,
    % greater than 32, and no more than 4,194,304 pixels.
    isIndeo = strncmpi('iv',aviobj.StreamHeader.fccHandler, 2);

    if isIndeo
      if (aviobj.MainHeader.TotalFrames == 0) && ...
	    (aviobj.Bitmapheader.biBitCount == 8) && ...
	    (aviobj.Bitmapheader.biClrUsed >236)
            error(message('MATLAB:audiovideo:addframe:invalidIndeoColorMapSize'));
      end
            
      if (width < 32) || (height < 32)
        error(message('MATLAB:audiovideo:addframe:indeoFrameSizeTooSmall'));
      end
      if width*height > 4194304
        error(message('MATLAB:audiovideo:addframe:indeoFrameSizeTooLarge'));
      end
    end % if isIndeo

    % Check requirements for MPEG-4 compressors.  This list is maintained
    % from Microsoft's list of registered codecs:
    % http://msdn.microsoft.com/library/default.asp?url=/library/en-us/dnwmt/html/registeredfourcccodesandwaveformats.asp
    codec = aviobj.StreamHeader.fccHandler;
    isMPG4 = any(strncmpi(codec, {'M4S2', 'MP43', 'MP42', 'MP4S', 'MP4V'}, 4));
    
    % Indeo and MPEG-4 codecs require that frame height and width
    % are multiples of 4.
    if isMPG4 || isIndeo
        hpad = rem(height,4);
        wpad = rem(width,4);
        if hpad
            if  aviobj.MainHeader.TotalFrames == 0
                warning(message('MATLAB:audiovideo:aviaddframe:frameheightpadded'));
            end
            frame = [frame;zeros(4-hpad,size(frame,2),dims)];
        end
        if wpad
            if  aviobj.MainHeader.TotalFrames == 0
                warning(message('MATLAB:audiovideo:aviaddframe:framewidthpadded'));
            end
            frame = [frame, zeros(size(frame,1),4-wpad,dims)];
        end

        % Determine adjusted image dimensions
        height = size(frame,1);
        width = size(frame,2);
        dims = size(frame,3);
    end
    
    % Truecolor images can not be compressed with RLE or MSVC compression 
    if dims == 3
      if strcmpi(aviobj.StreamHeader.fccHandler,'mrle') || ...
          strcmpi(aviobj.StreamHeader.fccHandler,'msvc')
        error(message('MATLAB:audiovideo:addframe:invalidCompressionType'));
      end
    end
    
    % If this is not the first frame, make sure it is consistent
    if aviobj.MainHeader.TotalFrames ~= 0
      ValidateFrame(aviobj,width, height,dims);
    end

    % Reshape image data
    frame = ReshapeImage(frame);

    % Compute memory requirements for frame storage
    numFrameElements = prod(size(frame));

    % If this is the first frame, set necessary fields
    if aviobj.MainHeader.TotalFrames==0
      aviobj.MainHeader.SuggestedBufferSize = numFrameElements;
      aviobj.StreamHeader.SuggestedBufferSize = numFrameElements;
      aviobj.MainHeader.Width = width;
      aviobj.MainHeader.Height = height;
      aviobj.Bitmapheader.biWidth = width;
      aviobj.Bitmapheader.biHeight = height;
      aviobj.Bitmapheader.biSizeImage = numFrameElements;
      if dims == 3 
	aviobj.Bitmapheader.biBitCount = 24;
      else
	aviobj.Bitmapheader.biBitCount = 8;
      end
    end

    % On Windows use Video for Windows to write the video stream
    if ispc
      % fps is calculated in avi.c by dividing the rate by the scale (100).
      % The scale of 100 is hard coded into avi.c
      rate = aviobj.StreamHeader.Rate; 
    
      avi('addframe',rot90(frame,-1), aviobj.Bitmapheader, ...
	  aviobj.MainHeader.TotalFrames,rate, ...
	  aviobj.StreamHeader.Quality,aviobj.FileHandle, ...
	  aviobj.StreamName,aviobj.KeyFrameEveryNth);
    end
    
    if isunix
    
      % Determine and update new size of movi LIST
      % ------------------------------------------
      %   '00db' or '00dc'   4 bytes
      %   size               4 bytes
      %   <movie data>       N
      %   Padd byte          rem(numFrameElements,2)
      newMovieListSize = aviobj.Sizes.movilist+4+4+numFrameElements + ...
	  rem(numFrameElements,2);
      aviobj.Sizes.movilist = newMovieListSize;

      % Determine and update new size of idx1 chunk
      % ------------------------------------------
      %   '00db' or '00dc'   4 bytes
      %   flags              4 bytes
      %   offset             4 bytes
      %   length             4 bytes
      newidx1size = aviobj.Sizes.idx1size + 4*4; 
      aviobj.Sizes.idx1size = newidx1size;

      % Determine and update new size of RIFF chunk
      % ------------------------------------------
      %   '00db' or '00dc'   4 bytes
      %   size               4 bytes
      %   <movie data>       N
      %   Padd byte          rem(numFrameElements,2)
      %   '00db' or '00dc'   4 bytes
      %   flags              4 bytes
      %   offset             4 bytes
      %   length             4 bytes
      newRIFFsize = aviobj.Sizes.riffsize + 4+4+numFrameElements + 4*4 ...
	  + rem(numFrameElements,2);
      aviobj.Sizes.riffsize = newRIFFsize;

      % Write  movi chunk to temp file
      if aviobj.Compression == 1
    	ckid = '00dc';
      else
        ckid = '00db';
      end
      WriteTempdata(ckid,numFrameElements,frame,aviobj.TempDataFile);
    end %End of UNIX specific code

  % Update the total frames
  aviobj.MainHeader.TotalFrames = aviobj.MainHeader.TotalFrames + 1;
  
  % Always make sure the main header and stream header length
  % match the total # of frames.
  aviobj.MainHeader.Length = aviobj.MainHeader.TotalFrames;
  aviobj.StreamHeader.Length = aviobj.MainHeader.TotalFrames;
  end
end
return;

% ------------------------------------------------------------------------
function WriteTempdata(chunktype,chunksize,chunkdata,filename)
% WRITETEMPDATA 
%   Append the frame data to a temporary file. The data is written as
% 
%   chunktype  4 bytes
%   chunksize  4 bytes
%   chunkdata  N bytes  
%   

fid = fopen(filename,'a','l');
fseek(fid,0,'eof');

count = fwrite(fid,chunktype,'char');
if count ~= 4
  error(message('MATLAB:audiovideo:addframe:unableToWriteTempFile'));
end

count = fwrite(fid,chunksize,'uint32');
if count ~= 1
  error(message('MATLAB:audiovideo:addframe:unableToWriteTempFile'));
end

count = fwrite(fid,rot90(chunkdata,-1),'uint8');
if count ~= prod(size(chunkdata))
  error(message('MATLAB:audiovideo:addframe:unableToWriteTempFile'));
end

fclose(fid);
return;

% ------------------------------------------------------------------------
function ValidateFrame(aviobj, width, height, dims)
% VALIDATEFRAME
%   Verify the frame is consistent with header information in AVIOBJ.  The
%   frame must have the same WIDTH, HEIGHT, and DIMS as the previous frames.

if width ~= aviobj.MainHeader.Width
  error(message('MATLAB:audiovideo:addframe:invalidFrameSize', aviobj.MainHeader.Width, aviobj.MainHeader.Height))
elseif height ~= aviobj.MainHeader.Height
  error(message('MATLAB:audiovideo:addframe:invalidFrameSize', aviobj.MainHeader.Width, aviobj.MainHeader.Height))
end

if (aviobj.Bitmapheader.biBitCount == 24) && (dims ~= 3)
  error(message('MATLAB:audiovideo:addframe:invalidColorBitDepth'));
elseif (aviobj.Bitmapheader.biBitCount == 8) && (dims ~= 1)
  error(message('MATLAB:audiovideo:addframe:invalidColorBitDepthForIndexed'))
end
return;

% ------------------------------------------------------------------------
function X = ReshapeImage(X)
numdims = ndims(X);
numcomps = size(X,3);

if (isa(X,'double'))
  if (numcomps == 3)
    X = uint8(round(255*X));
  else
    X = uint8(X-1);
  end
end

% Squeeze 3rd dimension into second
if (numcomps == 3)
  X = X(:,:,[3 2 1]);
  X = permute(X, [1 3 2]);
  X = reshape(X, [size(X,1) size(X,2)*size(X,3)]);
end

width = size(X,2);
tmp = rem(width,4);
if (tmp > 0)
    padding = 4 - tmp;
    X = cat(2, X, repmat(uint8(0), [size(X,1) padding]));
end

return;

% ------------------------------------------------------------------------
function inputType = getInputType(frame)
  if isscalar(frame) && ishandle(frame)
    inputType = get(frame,'type');
  elseif isstruct(frame) && isfield(frame,'cdata')
    inputType = 'movie';
  elseif isa(frame,'numeric')
    inputType = 'data';
  else
    error(message('MATLAB:audiovideo:addframe:invalidInputType'));
  end

% ------------------------------------------------------------------------
function frame = getFrameForFigure( figHandle )
    % make sure the figures units are in pixels
    oldUnits = get( figHandle, 'Units');
    set( figHandle, 'Units', 'pixels');
    unitCleanup = onCleanup( @()set(figHandle, 'Units', oldUnits) );
    
    pixelsperinch = get(0,'screenpixelsperInch');
    pos =  get( figHandle,'position');
    
    set(figHandle, 'paperposition', pos./pixelsperinch);
    renderer = get(figHandle,'renderer');
    if strcmp(renderer,'painters') || strcmp(renderer,'none')
        renderer = 'opengl';
    end
    %Turn off warning in case opengl is not supported and
    %hardcopy needs to use zbuffer
    warnstate = warning('off','MATLAB:audiovideo:addframe:warningsTurnedOff');
    warnCleanup = onCleanup( @()warning(warnstate) );

    frame = hardcopy(figHandle, ['-d' renderer], ['-r' num2str(round(pixelsperinch))]);
    
