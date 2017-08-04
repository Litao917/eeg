% SHOCKBVP 　x = 0 近傍のショック層をもつ解
% 
% これは、メッシュ選択手法を使った Numerical Solution of Boundary Value 
% Problems for Ordinary Differential Equations, SIAM, Philadelphia, PA, 
% 1995 の U. Ascher, R. Mattheij, R. Russell で示した例です。
%
% 0 < e << 1 に対して、 
%
%     e*u'' + x*u' = -e*pi^2*cos(pi*x) - pi*x*sin(pi*x)
%
% の解は、境界条件 u(-1) = -2,u(1) = 0 で、区間 [-1,1] の範囲で、x = 0 で
% 急激な遷移層をもちます。
%
% この例は、連続性を使って、うまく解を求めるためには、どのくらい難しい
% 問題かを数値的に示したものです (e = 1e-5)。この例に対して、解析的な
% 偏微係数は導出が簡単で、ソルバは微係数を使うように作られています。
% 
% 参考  BVP4C, BVPSET, BVPGET, BVPINIT, DEVAL, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
