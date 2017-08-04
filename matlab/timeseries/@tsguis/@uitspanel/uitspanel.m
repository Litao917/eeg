function h = uitspanel(varargin)
% Constructor for the uitspanel class.

% Copyright 2003-2012 The MathWorks, Inc.

import com.mathworks.mwswing.*;
import java.awt.*;

% If a parent it provided is must be passed to the uipanel
% constructor or a new figure will be created
if strcmpi(varargin{1},'parent')
    h = tsguis.uitspanel('parent',varargin{2});
else
    h = tsguis.uitspanel;
end

% Create JPanel and set properties
% h.jpanel = MJPanel(GridLayout(1,1));
for k=1:nargin/2
    set(h,varargin{2*k-1},varargin{2*k});
end

% Select the new panel
selectobject(h,'replace')

% Prevent deletion using Plot Edit Mode
b  = hggetbehavior(h,'PlotEdit');
b.EnableDelete = false;