function h = ghandles(this)
%GHANDLES  Returns a 3-D array of handles of graphical objects associated
%          with a freqview object.

%  Author(s): 
%  Copyright 1986-2006 The MathWorks, Inc.
h = cat(3, [this.Curves(:);this.SelectionPatch(:);this.WatermarkCurves(:)]);