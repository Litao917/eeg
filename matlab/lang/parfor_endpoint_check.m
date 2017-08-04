function endpoint = parfor_endpoint_check(endpoint)
% This function is undocumented and reserved for internal use.  It may be
% removed in a future release.

% Copyright 2007-2009 The MathWorks, Inc.

% NOTE: the scalar test being done first ensures that all other tests
% return a scalar logical - the isfinite and integerness tests can produce
% vector outputs if endpoint is a vector.
if ~isscalar(endpoint) || ~isnumeric(endpoint) || ~isreal(endpoint) ...
   || ~isfinite(endpoint) || endpoint ~= round(endpoint)
    error(message('MATLAB:parfor:range_endpoint', doclink( '/toolbox/distcomp/distcomp_ug.map', 'ERR_PARFOR_RANGE', 'Parallel Computing Toolbox, "parfor"' )))
end
