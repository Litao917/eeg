function menu = getPopupInterface(this, manager)
% GETPOPUPINTERFACE Return the handle of the Java popup menu for right click on
% the tree nodes.

% Author(s):  
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.

if isempty( this.PopupMenu )
  this.PopupMenu = getPopupSchema( this, manager );
end

menu = this.PopupMenu;