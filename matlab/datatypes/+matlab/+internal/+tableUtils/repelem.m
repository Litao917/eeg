function x = repelem(v,reps)
%REPELEM Replicate elements of a vector
%   X = REPELEM(V,REPS) returns a vector containing REPS(I) replicates of V(I).
%   In other words, X = [REPMAT(V(1),1,REPS(1)) REPMAT(V(2),1,REPS(2)) ...
%   REPMAT(V(END),1,REPS(END)) ].

%   Copyright 2012 The MathWorks, Inc.

% Ignore elements replicated zero number of times
pos = (reps > 0);
reps = reps(pos);
v = v(pos);
if isempty(v)
    x = [];
    return;
end

% Replicate each element of v
endlocs = cumsum(reps);
incr = zeros(1,endlocs(end));
incr(endlocs(1:end-1)+1) = 1;
incr(1) = 1;
x = v(cumsum(incr));
