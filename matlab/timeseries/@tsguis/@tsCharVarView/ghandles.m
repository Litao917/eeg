function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a TimeFinalValueView object.

%  Author(s): Bora Eryilmaz
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

h = cat(3, this.Lines,this.VLines(:));

% REVISIT: Include line tips when handle(NaN) workaround removed
