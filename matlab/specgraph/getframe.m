function [x,m]=getframe(varargin)
%GETFRAME Get movie frame.
%   GETFRAME returns a movie frame. The frame is a snapshot
%   of the current axis. GETFRAME is usually used in a FOR loop 
%   to assemble an array of movie frames for playback using MOVIE.  
%   For example:
%
%      for j=1:n
%         plot_command
%         M(j) = getframe;
%      end
%      movie(M)
%
%   GETFRAME(H) gets a frame from object H, where H is a handle
%   to a figure or an axis.
%   GETFRAME(H,RECT) specifies the rectangle to copy the bitmap
%   from, in pixels, relative to the lower-left corner of object H.
%
%   F = GETFRAME(...) returns a movie frame which is a structure 
%   having the fields "cdata" and "colormap" which contain the
%   the image data in a uint8 matrix and the colormap in a double
%   matrix. F.cdata will be Height-by-Width-by-3 and F.colormap  
%   will be empty on systems that use TrueColor graphics.  
%   For example:
%
%      f = getframe(gcf);
%      colormap(f.colormap);
%      image(f.cdata);
%
%   See also MOVIE, IMAGE, IM2FRAME, FRAME2IM.

%   Copyright 1984-2012 The MathWorks, Inc.

  h = [];
  offsetRect = [];
  
  switch nargin
      case 0
          h = gca;
      case 1
          h = varargin{1};
      case 2
          h  = varargin{1};
          offsetRect = varargin{2};
   end
   
  offsetRectGiven = ~isempty(offsetRect);
  
  drawnow; % give any pending updates a chance to occur 
  parentFig = ancestor(h, 'Figure');
  usingMATLABClasses = ~graphicsversion(parentFig, 'handlegraphics');

  if usingMATLABClasses
      if ~(ishghandle(h, 'Figure') || ishghandle(h, 'Axes'))
          error(message('MATLAB:capturescreen:BadObject'));
      end
  else
      if ~feature('ShowFigureWindows')
        error(message('MATLAB:capturescreen:FigureWindowRequired'));
      end
  end

  [offsetRect, absoluteRect, figPos, figOuterPos] = ...
                   Local_getRectanglesOfInterest(parentFig, ...
                                                 h, offsetRect);

  if any(offsetRect(3:4) < 1)
      error(message('MATLAB:capturescreen:WidthAndHeightMustBeAtLeast1'));
  end

  if offsetRectGiven
     [withinOuterRect, withinClientRect] = ...
        Local_determineIfWithinFigure(absoluteRect, figPos, figOuterPos);
  else
     % if no offset rectangle specified then we are w/in the figure bounds
     withinOuterRect = true;
     withinClientRect = true;
  end
  % warn if specified rectangle is outside the figure
  if ~withinOuterRect
      warning(message('MATLAB:getframe:RequestedRectangleExceedsFigureBounds'));
  end

  % Be sure to call cleanup on exit.
  cleanupHandler = onCleanup(@() doCleanup(parentFig, get(parentFig, 'Visible')));

  useCaptureScreen = ~usingMATLABClasses;
  
  if ~useCaptureScreen
     if withinOuterRect 
         if ~offsetRectGiven
             % we'll recalculate as needed later
             offsetRect = [];
         end
         x = alternateGetframe(parentFig, h, offsetRect, withinClientRect);
     else
         varargin{2} = absoluteRect;
         useCaptureScreen = true;
     end
  end
  
  if useCaptureScreen
     figure(parentFig); % bring parent figure and make visible if needed
     drawnow;
     x=builtin('capturescreen', varargin{:});
  end

  if (nargout == 2)
    m=x.colormap;
    x=x.cdata;
  end
end  

function  [offsetRect, absoluteRect, figPos, figOuterPos] = ...
           Local_getRectanglesOfInterest(parentFig, ...
                                         h, offsetRect)

  drawnow; % further chance for updates to occur
  
  givenRect = ~isempty(offsetRect); % were we given a rectangle to use?
  % determine container used to convert normalized units
 
  % get figure outerposition in pixels
  if ~strcmpi(get(parentFig, 'Units'), 'Pixels')
      figOuterPos = hgconvertunits(parentFig,  get(parentFig, 'OuterPosition'), ...
                                   get(parentFig, 'Units'), 'Pixels', 0);
  else
      figOuterPos = get(parentFig, 'OuterPosition');
  end
  
  if ~strcmpi(get(parentFig, 'Units'), 'Pixels')
      figPos = hgconvertunits(parentFig,  get(parentFig, 'Position'), ...
                              get(parentFig, 'Units'), 'Pixels', 0);
  else
      figPos = get(parentFig, 'Position');
  end
  
  % we want the rectangle in Pixels, so if we're not already in Pixels, convert.
  if ~strcmpi(get(h, 'Units'), 'Pixels')
      if ishghandle(h, 'Axes') 
         ref = parentFig;  % axes pos relative to figure container
      else
         ref = 0; % root object is container for figure
      end
      pos = hgconvertunits(parentFig, get(h, 'Position'), ...
                           get(h, 'Units'), 'Pixels', ref);
  else
      pos = get(h, 'Position');
  end
  
  if ishghandle(h, 'Axes') 
      % axes rect is relative to figure, adjust rect so it is in absolute
      % coordinates
      pos(1) = pos(1) + figPos(1);
      pos(2) = pos(2) + figPos(2);
      pos(1:2) = pos(1:2) - 1; % adjust origin
  end
  
  % determine absolute rectangle to retrieve
  if ~givenRect
      % if capturing a figure the x- and y-offset will be [0 0]
      % if capturing an axes x- and y-offset will be axes
      offsetRect = [pos(1) - figPos(1) pos(2) - figPos(2) pos(3:4)]; 
      absoluteRect = pos; % we want entire content
  else
      absoluteRect = [pos(1:2)+offsetRect(1:2) offsetRect(3:4)];
  end
  
  offsetRect = [floor(offsetRect(1:2)) ceil(offsetRect(3:4))];
  absoluteRect = [floor(absoluteRect(1:2)) ceil(absoluteRect(3:4))];
                                 
end

function [withinOuterRect, withinClientRect] = ...
      Local_determineIfWithinFigure(absoluteRect, figPos, figOuterPos)
  
  withinOuterRect = true; % assume we're within figure outer position
  withinClientRect = true; % assume we're within figure position

  if ~(absoluteRect(1) >= figOuterPos(1) && absoluteRect(1)+absoluteRect(3) <= figOuterPos(1)+figOuterPos(3) && ...
       absoluteRect(2) >= figOuterPos(2) && absoluteRect(2)+absoluteRect(4) <= figOuterPos(2)+figOuterPos(4)) 
      withinOuterRect = false;
      withinClientRect = false;
  end

  if withinOuterRect 
      % determine if completely within figure position bounds (e.g. not
      % asking for figure window frame, menus, other decorations)
      if ~(absoluteRect(1) >= figPos(1) && absoluteRect(1)+absoluteRect(3) <= figPos(1)+figPos(3) && ...
           absoluteRect(2) >= figPos(2) && absoluteRect(2)+absoluteRect(4) <= figPos(2)+figPos(4)) 
         withinClientRect = false;
      end
  end
  
end

% cleanup handler to restore things when done 
function doCleanup(fig, visible)
    set(fig, 'Visible', visible);
end
% LocalWords:  capturescreen outerposition recalc yoffset IM handlegraphics
