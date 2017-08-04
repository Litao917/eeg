% scatteredInterpolant   Scattered data interpolation
%    scatteredInterpolant is used to perform interpolation on a scattered 
%    dataset that resides in 2D/3D space. A scattered data set defined by 
%    locations X and corresponding values V can be interpolated using a 
%    Delaunay triangulation of X. This produces a surface of the form V = F(X). 
%    The surface can be evaluated at any query location QX, using QV = F(QX), 
%    where QX lies within the convex hull of X. The interpolant F always 
%    goes through the data points specified by the sample.
%
%    F = scatteredInterpolant() Creates an empty scattered data interpolant. 
%    This can subsequently be initialized with sample data points and values 
%    (Xdata, Vdata) via F.Points = Xdata and F.Values = Vdata.
%
%    F = scatteredInterpolant(X, V) Creates an interpolant that fits a surface 
%    of the form V = F(X) to the scattered data in (X, V). X is a matrix 
%    of size mpts-by-ndim, where mpts is the number of points and ndim is 
%    the dimension of the space where the points reside, ndim >= 2. V is a 
%    column vector that defines the values at X, where the length of V 
%    equals mpts.
%
%    F = scatteredInterpolant(X, Y, V) and F = scatteredInterpolant(X, Y, Z, V) 
%    allow the data point locations to be specified in alternative column 
%    vector format when working in 2D and 3D.
%
%    F = scatteredInterpolant(..., METHOD) specifies the method used to 
%    interpolate the data, where METHOD is one of the following; 
%           'nearest'   Nearest neighbor interpolation
%           'linear'    Linear interpolation (default)
%           'natural'   Natural neighbor interpolation
%    The 'natural' method is C1 continuous except at the scattered data 
%    locations. The 'linear' method is C0 continuous, and the 'nearest' 
%    method is discontinuous.
%
%    F = scatteredInterpolant (..., METHOD, EXTRAPOLATIONMETHOD) supports the 
%    selection of an extrapolation method to be used outside the convex hull.
%    Where EXTRAPOLATIONMETHOD is one of the following: 
%           'nearest' - Evaluates to the value of the nearest neighbor on the 
%                       boundary (default for METHOD ='nearest')
%           'linear'  - Performs linear extrapolation based on boundary gradients 
%                       (default for METHOD = 'linear' and METHOD='natural')
%           'none'    - Queries outside the convex hull will return NaN
%
%    Example 1:
%        xy = -2.5 + 5*gallery('uniformdata',[200 2],0);
%        x = xy(:,1); y = xy(:,2);
%        v = x.*exp(-x.^2-y.^2);
%
%   % Construct the interpolant
%        F = scatteredInterpolant(x,y,v);
%
%   % Evaluate the interpolant at the locations (xq, yq),
%   %    vq is the corresponding value at these locations.
%        ti = -2:.2:2; 
%        [xq,yq] = meshgrid(ti,ti);
%        vq = F(xq,yq);
%        mesh(xq,yq,vq); hold on; plot3(x,y,v,'o'); hold off
%
%
%    Example 2: Edit the interpolant created in Example 1 
%               to add/remove points or replace values
%
%        % Insert 5 additional sample points, we need to update both F.V and F.X
%        close(gcf)
%        x = rand(5,1); 
%        y = rand(5,1); 
%        v = x.*exp(-x.^2-y.^2);
%        F.V(end+(1:5)) = v;
%        F.X(end+(1:5), :) = [x, y]; 
%
%        % Replace the location and value of the fifth point
%        F.X(5,:) = [0.1, 0.1];
%        F.V(5) = 0.098;
%
%        % Remove the fourth point
%        F.X(4,:) = [];
%        F.V(4) = [];
%
%        % Replace the value of all sample points
%        vnew = 1.2*(F.V);
%        F.V(1:length(vnew)) = vnew;
% 
%    scatteredInterpolant methods:
%        scatteredInterpolant provides subscripted evaluation of the
%        interpolant. It is evaluated in the same manner as evaluating a
%        function.
%
%        Vq = F(Xq), evaluates the interpolant at the specified query 
%        locations Xq to produce the query values Vq.
%
%        Vq = F(Xq, Yq) and Vq = F(Xq, Yq, Zq) allow the query points to be
%        specified in column vector format when working in 2D and 3D. 
%
%
%    scatteredInterpolant properties:
%        Points      - Locations of the scattered data points
%        Values      - Value associated with each data point
%        Method      - Method used to interpolate the data
%        ExtrapolationMethod - Extrapolation method used outside the convex hull

%
%    See also  delaunayTriangulation, interp1, interp2, interp3, ndgrid.

%   Copyright 2008-2012 The MathWorks, Inc.
%   Built-in function.

%{
properties
    %Points - Defines the locations of the scattered data points 
    %    The dimension of Points is mpts-by-ndim, where mpts is the number of 
    %    data points and ndim is the dimension of the space where the 
    %    points reside 2 <= ndim <= 3. 
    %    If column vectors of X,Y or X,Y,Z coordinates are used to construct
    %    the interpolant, the data is consolidated into a single matrix Points.
    Points;    

    %Values - Defines the value associated with each data point
    %    Values is a column vector of length mpts where mpts is the number
    %    of scattered data points.
    Values;

    %Method - Defines the method used to interpolate the data
    %    The Method is one of the following; 
    %           'nearest'   Nearest neighbor interpolation  
    %           'linear'    Linear interpolation (default)
    %           'natural'   Natural neighbor interpolation
    %    The 'nearest' method is discontinuous. The 'linear' method is C0 
    %    continuous, and the 'natural' method is C1 continuous except at the 
    %    scattered data locations. 
    Method;

   %ExtrapolationMethod - Defines the method used to extrapolate the data
    %    The ExtrapolationMethod is one of the following; 
    %           'nearest' - Evaluates to the value of the nearest neighbor on the 
    %                       boundary (default for METHOD='nearest')
    %           'linear'  - Performs linear extrapolation based on boundary gradients 
    %                       (default for METHOD='linear' and METHOD='natural')
    %           'none'    - Queries outside the convex hull will return NaN
    ExtrapolationMethod;
end
%}
