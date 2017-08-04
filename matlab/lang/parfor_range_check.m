function range = parfor_range_check(range)
% This function is undocumented and reserved for internal use.  It may be
% removed in a future release.

% Copyright 2007-2008 The MathWorks, Inc.
    
dims = size(range);
if dims(1) ~= 1 || length(dims) > 3
    if isempty(range)
        range = [1, 0];
        return
    end
    error(message('MATLAB:parfor:range_must_be_row_vector', doclink( '/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_RANGE', 'Parallel Computing Toolbox, "parfor"' )));
    
elseif ~isnumeric(range)
    error(message('MATLAB:parfor:range_must_be_numeric', doclink( '/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_RANGE', 'Parallel Computing Toolbox, "parfor"' )));
else
    if isempty(range)
        range = [1 0]; % the canonical empty range
        return
    end
    a = range(1);
    b = range(end);
    if a <= b && isequal(range, a:b)
        range = [a, b];
        return
    end
    error(message('MATLAB:parfor:range_not_consecutive', doclink( '/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_RANGE', 'Parallel Computing Toolbox, "parfor"' )));
end
