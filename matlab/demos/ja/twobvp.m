% TWOBVP 厳密な意味で 2 つの解をもつ BVP を解きます。
% 
% TWOBVP は、BVP4C を使って、
% 
%      y'' + |y| = 0
% 
% の 2 つの解を計算します。ここで、つぎの境界条件を満足します。
% 
%      y(0) = 0,  y(4) = -2
% 
% この例は、初期推定値により、いかに異なる解を導くかを示しています。
% 
%   
% 参考 TWOODE, TWOBC, BVPINIT, BVPSET, BVPGET, BVP4C, DEVAL, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
