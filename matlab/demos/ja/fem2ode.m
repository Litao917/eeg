% FEM2ODE   定数質量行列 M*y' = f(t,y) をもつスティフな問題
%
% パラメータ N は、離散化をコントロールし、結果のシステムは N 個の方程
% 式から構成されます。たとえば、20 行 20 列のシステムを解くには、
% 
%       fem2ode(20)
% 
% を使います。デフォルトは、N が 9 です。  
%
% F(T,Y) は、偏微分方程式の有限要素離散用に微係数ベクトルを出力します。
% デフォルトで、ODE Suite のソルバは、y' = f(t,y) の型のシステムを解きます。
% システム My' = f(t,y) を解くには、ODESET を使って、'Mass' プロパティ
% に定数行列 M を設定します。
%
% 参考 ODE23S, ODE15S, ODE23T, ODE23TB, ODESET, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
