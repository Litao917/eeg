function h = horizontalline(fun, varargin)
% HORIZONTALLINE  Creates a horizontal line from a constant function.

%   Copyright 1984-2010 The MathWorks, Inc.

if nargin < 1
    error(message('MATLAB:horizontalline:NeedsMoreArgs'));
end

if (feature('HGUsingMATLABClasses') == 1)
    h = specgraphhelper('createConstantLineUsingMATLABClasses', varargin{:});
    h.Value = fun;
else
    h = graph2d.constantlineseries(fun, varargin{:});
end
