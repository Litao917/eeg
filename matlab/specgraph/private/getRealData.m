function args = getRealData(args)
% This function is undocumented and may change in a future release.

   %  Copyright 2013 The MathWorks, Inc.

   % getRealData returns the real components of ARGS. If ARGS contains any
   % complex data, a warning is displayed.

narginchk(1, inf);

nargs = length(args);

if ~all(cellfun(@isreal, args))
    warning(message('MATLAB:specgraph:private:specgraph:UsingOnlyRealComponentOfComplexData'));
    for i = 1:nargs
        if isnumeric(args{i})
            args{i} = real(args{i});
        end
    end
end