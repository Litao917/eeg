% ORBITODE   ORBITDEM で使用される制約付き 3 体問題
% 
% これは、下記の文献の 246 ページで、Shampine と Gordon により記述された、
% ノンスティッフなソルバに対する標準のテスト問題です。最初の 2 つの解の
% 成分は、無限小の質量の物体の座標なので、1 つの解をもう 1 つの解に対して
% プロットすることは、他の 2 つの物体の周りの軌道を与えます。初期条件は、
% 軌道を周期的にするように選択されます。軌道の定量的な挙動の再生成のため
% には、適度に厳しい許容範囲が必要です。RelTol の適正な値は 1e-5 で、
% AbsTol の適正な値は 1e-4 です。
% 
% ORBITODE 自身では、ゼロクロッシングの方向を設定する機能の限界の位置を
% 求めるデモを実行します。初期の点と最長距離を示す点に戻す 2 点は共に同じ
% イベント関数値をもち、クロシングの方向を使って、それらを区別します。
%
% 3 番目の物体の軌道は、出力関数 ODEPHAS2 を使って、プロットできます。
%   
% L. F. Shampine and M. K. Gordon, Computer Solution of Ordinary
% Differential Equations, W.H. Freeman & Co., 1975.
%   
% 参考  ODE45, ODE23, ODE113, ODESET, ODEPHAS2, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
