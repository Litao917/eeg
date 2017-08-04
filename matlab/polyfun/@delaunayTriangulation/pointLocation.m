% pointLocation  Triangle or tetrahedron containing specified point
% TI = pointLocation(DT, QP)  returns the index of the triangle/tetrahedron
%     enclosing the query point QP. The matrix QP contains the coordinates 
%     of the query points. QP is a mpts-by-ndim, matrix where mpts is the 
%     number of query points and 2 <= ndim <= 3.
%     TI is a column vector of triangle or tetrahedron IDs corresponding to the 
%     row numbers of the triangulation connectivity matrix DT.ConnectivityList. 
%     The triangle/tetrahedron enclosing the point QP(k,:) is TI(k). 
%     pointLocation returns NaN for all points outside the convex hull.
%
%     TI = pointLocation(DT, QX,QY) and TI = pointLocation (DT, QX,QY,QZ)
%     allow the query points to be specified in alternative column vector 
%     format when working in 2D and 3D.
%
%     [TI, BC] = pointLocation(DT,...) returns in addition, the Barycentric
%     coordinates BC. BC is a mpts-by-ndim matrix, each row BC(i,:) represents
%     the Barycentric coordinates of QP(i,:) with respect to the enclosing TI(i).
%
%    Example 1:
%        % Point Location in 2D
%        X = rand(10,2)
%        dt = delaunayTriangulation(X)
%        % Find the triangles that contain the following query points
%        qrypts = [0.25 0.25; 0.5 0.5]
%        triids = pointLocation(dt, qrypts)
%
%    Example 2:
%        % Point Location in 3D plus barycentric coordinate evaluation
%        x = rand(10,1); y = rand(10,1); z = rand(10,1);
%        dt = delaunayTriangulation(x,y,z)
%        % Find the triangles that contain the following query points
%        qrypts = [0.25 0.25 0.25; 0.5 0.5 0.5]
%        [tetids, bcs] = pointLocation(dt, qrypts)
%
%    See also delaunayTriangulation, delaunayTriangulation.nearestNeighbor.

% Copyright 2012 The MathWorks, Inc.
