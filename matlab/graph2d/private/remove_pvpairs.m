function pvpairs = remove_pvpairs(pvpairs, par)
% Helper function used by subplot for stripping 
% entries out of the pvpair list. Note that the
% par argument contains "pair indices". In other 
% words, a value of 2 will strip out the 4th and 
% 5th elements of the cell array.
%
% pvpairs : A cell array containing PVPairs
% par : A an of indices of the pairs to remove.

%   Copyright 2012 The MathWorks, Inc.

  if ~isempty(pvpairs) && ~isempty(par)
    if (min(par(:)) < 1 || 2*max(par(:)) > numel(pvpairs))
      error('MATLAB:subplot:SubplotIndexOutOfRange','some bogus message');
    end
    ix = ones(1,numel(pvpairs)/2);
    ix(par)=0;
    ix = [ix; ix];
    ix=reshape(ix,[1 numel(pvpairs)]);
    if all(~ix)
      pvpairs = {};
    else
      pvpairs = pvpairs(find(ix));
    end
  end
end  
