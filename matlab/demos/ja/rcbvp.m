%RCBVP  BVP4C と BVP5C で解いた Russell and Christiansen の例 C
%
%   非常に粗い許容誤差で解かれた Russell and Christiansen [1] の例 C は、
%   BVP4C と BVP5C で制御される誤差がやや異なることを示します。特に、BVP5C が
%   正確な誤差を制御するのは明らかです。より厳密な許容誤差では、違いは目に
%   見えません。
%
%   1. R.D. Russell and J. Christiansen, Adaptive mesh selection stragegies
%      for solving boundary value problems, SIAM J. Numer. Anal., 14 (1978)
%      pp. 59-80.
%
%   参考 BVP4C, BVP5C, BVPINIT, BVPSET, FUNCTION_HANDLE.


%   Copyright 1984-2008 The MathWorks, Inc.
