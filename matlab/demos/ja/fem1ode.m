% FEM1ODE   時変質量行列 M(t)*y' = f(t,y) をもつスティッフな問題
% 
% パラメータ N は離散化を制御し、結果のシステムは、N個の方程式で構成されます。
% デフォルトでは、N は 19 です。  
%
% この例で、サブ関数 f(Y,Y) は、偏微分方程式の有限要素の離散化用の微係数
% ベクトルを出力します。サブ関数 mass(T) は、時刻 T で評価する時変の質量
% 行列 M を出力します。デフォルトでは、ODE Suite のソルバは、y' = f(t,y) の
% 型のシステムを解きます。システム M(t)y' = f(t,y) を解くために、ODESET を
% 使って、プロパティ 'Mass' を関数に設定し、M(t) を計算するために、
% 'MStateDepencence' に 'none' を設定します。
%   
% この問題で、Jacobian df/dy は定数で、三重対角行列になります。'Jacobian' 
% プロパティは、df/dy をソルバに与えます。
%
% 参考  ODE15S, ODE23T, ODE23TB, ODESET, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
