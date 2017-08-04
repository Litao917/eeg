% BATONODE   バトンの挙動のシミュレーション
% 
% BATONODE は、時間依存および状態依存の質量行列問題を解きます。この例は、
% D.A. Wells、Theory and Problems of Lagrangian Dynamics、McGraw-Hill、
% 1967 の Example 4.3A に基づいています。質量行列を使った多くの問題が公式化
% されています。バトンは、長さ L の軽い棒に堅く固定された質量 m1 および 
% m2 の2つの粒子としてモデル化されています。その挙動は、重力の作用の下で
% 垂直の xy 平面内で起こります。1つ目の粒子の座標が (X,Y) で、水平方向と
% 棒の角度が theta の場合、Lagrange 方程式は、未知の theta に依存する質量
% 行列を導きます。ここで、変数 y は、y(1) = X、y(2)= X'、y(3) = Y、y(4) = Y'、
% y(5) = theta、y(6) = theta' です。
%   
% 参考  ODE45, ODE113, ODESET, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
