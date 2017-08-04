% RIGIDODE   外力のない剛体の Euler 方程式
% 
% Krogh により提示された、ノンスティッフなソルバに対する標準的なテスト
% 問題です。解析解は、MATLAB でアクセス可能なヤコビアン楕円関数です。
% ここでの区間は、約 1.5 です。これは、下記の文献 Shampine and Gorden の
% 243 ページにプロットされている区間です。
%   
% L. F. Shampine and M. K. Gordon, Computer Solution of Ordinary
% Differential Equations, W.H. Freeman & Co., 1975.
%   
% 参考  ODE45, ODE23, ODE113, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
