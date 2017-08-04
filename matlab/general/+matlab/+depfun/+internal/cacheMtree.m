function t = cacheMtree(file)
% cacheMtree Cache results of MTREE for reuse (higher performance)
%
% t = cacheMtree(file)
%    Return an MTREE for file. Create one and store it in the cache if
%    one is not available.
%
%   cacheMtree()
%     Clear the cache (by creating a new, empty one).

persistent mtreeCache

t = [];
if nargin == 0
    mtreeCache = containers.Map('KeyType', 'char', 'ValueType', 'any');
else
    if isKey(mtreeCache, file)
        t = mtreeCache(file);
    else
        if ~isempty(file) && isMcode(file) ...
            && matlab.depfun.internal.cacheExist(file, 'file')
            t = mtree(file, '-file', '-com');
        end
        mtreeCache(file) = t;
    end
end
