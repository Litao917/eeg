function varargout = primitivevertexpicker(varargin)
% This function is undocumented and may change in a future release.

% [ind interp extra] = PRIMITIVEVERTEXPICKER(prim,point)
%   PRIM is an HG primitive object
%   POINT is the point (in viewer pixel coordinates)
%
%   IND is the closest vertex index.
%   INTERP is the interpolation factor (a scalar for lines, a vector for
%   others).
%   EXTRA contains a structure with additional information.

%   Copyright 2010 The MathWorks, Inc.

% The primitive must be in an axes.                  

% Output variables

if ~isempty(varargin{1}) && ~graphicsversion(varargin{1},'handlegraphics')
    try 
        [varargout{1:nargout}] = primitivevertexpickerHGUsingMATLABClasses(varargin{:});
    catch me
        throw(me)
    end
else
    error(message('MATLAB:primitivevertexpicker:mcosonly'))
end