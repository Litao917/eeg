function h = ghandles(this)
%  GHANDLES  Returns a 3-D array of handles of graphical objects associated
%            with a eventCharView object.

%  Author(s):  
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.

%h = cat(3, [this.VLines(:) this.Labels(:)]);
h = cat(3,this.VLines(:),this.Points(:));

% REVISIT: Include line tips when handle(NaN) workaround removed
