% Interpolation and polynomials.
%
% Data interpolation.
%   pchip       - Piecewise cubic Hermite interpolating polynomial.
%   interp1     - 1-D interpolation (table lookup).
%   interp1q    - Quick 1-D linear interpolation.
%   interpft    - 1-D interpolation using FFT method.
%   interp2     - 2-D interpolation (table lookup).
%   interp3     - 3-D interpolation (table lookup).
%   interpn     - N-D interpolation (table lookup).
%   griddata    - Data gridding and surface fitting.
%   griddatan   - Data gridding and hyper-surface fitting (dimension >= 2).
%   scatteredInterpolant - Interpolant for scattered data
%   griddedInterpolant - Interpolant for gridded data
%
% Spline interpolation.
%   spline      - Cubic spline interpolation.
%   ppval       - Evaluate piecewise polynomial.
%
% Geometric analysis.
%   delaunay    - Delaunay triangulation.
%   delaunayn   - N-D Delaunay triangulation.
%   dsearchn    - Search N-D Delaunay triangulation for nearest point.
%   tsearchn    - N-D closest triangle search.
%   convhull    - Convex hull.
%   convhulln   - N-D convex hull.
%   voronoi     - Voronoi diagram.
%   voronoin    - N-D Voronoi diagram.
%   inpolygon   - True for points inside polygonal region.
%   rectint     - Rectangle intersection area.
%   polyarea    - Area of polygon.
% 
% Triangulation Representation.
%   triangulation                   - A Triangulation Representation
%   triangulation/barycentricToCartesian - Converts the coordinates of a point from barycentric to cartesian
%   triangulation/cartesianToBarycentric - Converts the coordinates of a point from cartesian to barycentric
%   triangulation/circumcenter      - Circumcenter of triangle or tetrahedron
%   triangulation/edges             -  Triangulation edges
%   triangulation/edgeAttachments   - Triangles or tetrahedra attached to an edge
%   triangulation/faceNormal        - Triangulation face normal
%   triangulation/featureEdges      - Triangulation sharp edges
%   triangulation/freeBoundary      -  Triangulation facets referenced by only one triangle or tetrahedron
%   triangulation/incenter          - Incenter or triangle or tetrahedron
%   triangulation/isConnected       - Test if a pair of vertices is connected by an edge
%   triangulation/neighbors         - Neighbors to a triangle or tetrahedron
%   triangulation/size              - Returns the size of the Triangulation matrix
%   triangulation/vertexAttachments -  Triangles or tetrahedra attached to a vertex 
%   triangulation/vertexNormal      - Triangulation vertex normal
%   
% Delaunay Triangulation.
%   delaunayTriangulation                 - Delaunay triangulation in 2-D and 3-D
%   delaunayTriangulation/convexHull      - Convex hull
%   delaunayTriangulation/isInterior     -  Test if a triangle is in the interior of a 2-D constrained Delaunay triangulation
%   delaunayTriangulation/nearestNeighbor - Vertex closest to specified point
%   delaunayTriangulation/pointLocation   - Triangle or tetrahedron containing specified point
%   delaunayTriangulation/voronoiDiagram  - Voronoi diagram
%
% Polynomials.
%   roots       - Find polynomial roots.
%   poly        - Convert roots to polynomial.
%   polyval     - Evaluate polynomial.
%   polyvalm    - Evaluate polynomial with matrix argument.
%   polyfit     - Fit polynomial to data.
%   polyder     - Differentiate polynomial.
%   polyint     - Integrate polynomial analytically.
%   conv        - Multiply polynomials.
%   deconv      - Divide polynomials.

% Utilities.
%   xychk       - Check arguments to 1-D and 2-D data routines.
%   xyzchk      - Check arguments to 3-D data routines.
%   xyzvchk     - Check arguments to 3-D volume data routines.
%   automesh    - True if inputs should be automatically meshgridded.
%   mkpp        - Make piecewise polynomial.
%   unmkpp      - Supply details about piecewise polynomial.
%   splncore    - N-D Spline interpolation.
%   qhullmx     - Gateway function for Qhull.
%   qhull       - Copyright information for Qhull.

%   Copyright 1984-2012 The MathWorks, Inc.

