% VDPODE   (大きい mu に対してスティッフな) van der Pol 式のパラメータ化
% 
% MU が 1000 のとき、方程式は振動を緩和し、問題は非常にスティッフになります。
% このリミットサイクルには、解の成分がゆっくりと変化し、問題が非常にスティッフな
% 領域と、スティッフでない (準不連続性) 非常に激しい変化のある領域が交互にあります。
% 初期条件は、初期ステップサイズの選択に対するテストのために、ゆっくり変化する
% 領域に近くなっています。
%   
% サブ関数 J(T,Y) は、(T,Y) で解析的に計算した Jacobian 行列 dF/dY を
% 出力します。デフォルトで、ODE Suite のスティフなソルバは、数値的に 
% Jacobian 行列を近似します。しかし、ODE Solver プロパティ Jacobian は、
% 関数 ODESET を使って、@vdpJac に設定され、ソルバーは、dF/dy を得るため
% に関数をコールします。解析的な Jacobian をもつソルバーが、必ずしも用意
% されなくても構いませんが、積分の信頼性と効率を高めます。
% 
%   L. F. Shampine, Evaluation of a test set for stiff ODE solvers, ACM
%   Trans. Math. Soft., 7 (1981) pp. 409-420.
%   
% 参考 ODE15S, ODE23S, ODE23T, ODE23TB, ODESET, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
