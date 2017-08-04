function h = verticalline(fun, varargin)
% VERTICALLINE  Creates a vertical straight line from a constant function.

%   Copyright 1984-2010 The MathWorks, Inc.

if nargin < 1
    error(message('MATLAB:verticalline:NeedsMoreArgs'));
end

if (feature('HGUsingMATLABClasses') == 1)
    h = specgraphhelper('createConstantLineUsingMATLABClasses', varargin{:}); 
    h.Value = fun;
else    
    h = graph2d.constantlineseries(fun, varargin{:});
end

changedependvar(h,'x');