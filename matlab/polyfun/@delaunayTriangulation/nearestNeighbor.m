% nearestNeighbor  Vertex closest to specified point
% VI = nearestNeighbor(DT, QP)  returns the index of the vertex nearest the
%      query point QP. The matrix QP contains the coordinates of the query
%      points. QP is a mpts-by-ndim, matrix where mpts is the number of query 
%      points and 2 <= ndim <= 3. VI is a column vectors of vertex IDs of length 
%      mpts, where a vertex ID corresponds to the row number into TR.Points.
%
%      VI = nearestNeighbor(DT, QX,QY) and VI = nearestNeighbor(DT, QX,QY,QZ)
%      allow the query points to be specified in alternative column vector
%      format in 2D and 3D.
%
%      [VI, D] = nearestNeighbor(DT,...)  returns in addition, the corresponding
%      Euclidean distances D between the query points and their nearest
%      neighbors. D is a column vector of length mpts.
%
%      Note: nearestNeighbor is not supported for 2D triangulations that have
%            constrained edges.
%
%    Example:
%        x = rand(10,1)
%        y = rand(10,1)
%        dt = delaunayTriangulation(x,y)
%        % Find the points nearest the following query points
%        qrypts = [0.25 0.25; 0.5 0.5]
%        pid = nearestNeighbor(dt, qrypts)
%
%    See also delaunayTriangulation, delaunayTriangulation.pointLocation.

% Copyright 2012 The MathWorks, Inc.
