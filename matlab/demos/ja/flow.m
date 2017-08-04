% FLOW   3変数からなる単純な関数
% 
% 流量のデータを生成する3変数の関数 FLOW は、SLICE, INTERP3、スカラの
% ボリュームデータを視覚化する関数のデモに役立ちます。
% 
% つぎのような呼び出し方法があります。
% 
%     V = FLOWは、50*25*25の配列を作成します。
%     V = FLOW(N)は、2N*N*Nの配列を作成します。
%     V = FLOW(X,Y,Z)は、点(X,Y,Z)での速度プロファイルを評価します。
%     [X,Y,Z,V] = FLOW(...)は、座標も出力します。


%   Reference: Fluid Mechanics, L. D. Landau and E. M. Lifshitz.
%   Copyright 1984-2004 The MathWorks, Inc.
