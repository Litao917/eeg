function a = ylim(arg1, arg2)
%YLIM Y limits.
%   YL = YLIM             gets the y limits of the current axes.
%   YLIM([YMIN YMAX])     sets the y limits.
%   YLMODE = YLIM('mode') gets the y limits mode.
%   YLIM(mode)            sets the y limits mode.
%                            (mode can be 'auto' or 'manual')
%   YLIM(AX,...)          uses axes AX instead of current axes.
%
%   YLIM sets or gets the YLim or YLimMode property of an axes.
%
%   See also PBASPECT, DASPECT, XLIM, ZLIM.
 
%   Copyright 1984-2005 The MathWorks, Inc. 

if nargin == 0
  a = get(gca,'ylim');
else
  if isscalar(arg1) && ishghandle(arg1) && isprop(arg1,'YLim')
    ax = arg1;
    if nargin==2
      val = arg2;
    else
      a = get(ax,'ylim');
      return
    end
  else
    if nargin==2
      error(message('MATLAB:ylim:InvalidNumberArguments'))
    else
      ax = gca;
      val = arg1;
    end
  end
    
  if ischar(val)
    if(strcmp(val,'mode'))
      a = get(ax,'ylimmode');
    else
      set(ax,'ylimmode',val);
    end
  else
    set(ax,'ylim',val);
  end
end
