function hh = triplot(tri,varargin)
%TRIPLOT Plots a 2D triangulation
%   TRIPLOT(TRI,X,Y) displays the triangles defined in the
%   M-by-3 matrix TRI.  A row of TRI contains indices into X,Y that
%   define a single triangle. The default line color is blue.
%
%   TRIPLOT(TriRep) will not accept TriRep in a future release. 
%                   Use TRIPLOT(triangulation) instead.
%   TRIPLOT(TR) displays the triangles in a TriRep - a Triangulation 
%   representation.
%
%   TRIPLOT(...,COLOR) uses the string COLOR as the line color.
%
%   H = TRIPLOT(...) returns a vector of handles to the displayed triangles.
%
%   TRIPLOT(...,'param','value','param','value'...) allows additional
%   line param/value pairs to be used when creating the plot.
%
%   Example 1:
%       X = rand(10,2);
%       dt = delaunayTriangulation(X);
%       triplot(dt)
%
%   Example 2:
%       % Plotting a Delaunay triangulation in face-vertex format
%       X = rand(10,2);
%       dt = delaunayTriangulation(X);
%       tri = dt(:,:);
%       triplot(tri, X(:,1), X(:,2));
%
%   See also TRISURF, TRIMESH, DELAUNAY, triangulation, delaunayTriangulation.

%   Copyright 1984-2012 The MathWorks, Inc. 


error(nargchk(1,inf,nargin,'struct'));

start = 1;

if isa(tri, 'TriRep')
     if tri.size(1) == 0
        error(message('MATLAB:triplot:EmptyTri'));
     elseif tri.size(2) ~= 3
        error(message('MATLAB:triplot:NonTriangles'));
     end
    x = tri.X(:,1);
    y = tri.X(:,2);
    trids = tri(:,:);
    if (nargin == 1) || (mod(nargin-1,2) == 0)
      c = 'blue';
    else
      c = varargin{1};
      start = 2;
    end
elseif isa(tri, 'triangulation')
     if tri.size(1) == 0
        error(message('MATLAB:triplot:EmptyTri'));
     elseif tri.size(2) ~= 3
        error(message('MATLAB:triplot:NonTriangles'));
     end
    x = tri.Points(:,1);
    y = tri.Points(:,2);
    trids = tri(:,:);
    if (nargin == 1) || (mod(nargin-1,2) == 0)
      c = 'blue';
    else
      c = varargin{1};
      start = 2;
    end     
else
    x = varargin{1};
    y = varargin{2};
    trids = tri;
    if (nargin == 3) || (mod(nargin-3,2) == 0)
      c = 'blue';
      start = 3;
    else 
      c = varargin{3};
      start = 4;
    end
end
  
d = trids(:,[1 2 3 1])';
h = plot(x(d), y(d),c,varargin{start:end});
if nargout == 1, hh = h; end
