% BRUSSODE   化学反応のモデリングのスティッフな問題 (the Brusselator).
% 
% パラメータ N > =  2 を使って、グリッド点の数を指定します。結果のシステム
% の結果は、2N 個の方程式で構成されます。デフォルトでは、N は 20 です。
% N が増加すると、問題はスティッフ、かつスパース度は高くなります。
% この問題のヤコビアンは、スパース定数行列です (帯域は 5 です)。
%   
% プロパティ 'JPattern' は、Jacobian df/dy の中の非ゼロの位置を示す、0 と
% 1 から構成されるスパース行列を使ったソルバを与えるために使うものです。
% デフォルトでは、ODE Suite のスティフなソルバは、フル行列と同じような
% 数値的なヤコビアンを作成します。しかし、スパース性を示すパターンが
% 与えられた場合、ソルバはそれを使って、スパース行列として数値的な 
% ヤコビアンを作成します。スパースパターンを与えることは、ヤコビアンを
% 作成するために必要な関数値の算出回数を非常に減らし、積分を速くすることに
% なります。BRUSSODE 問題に対して、2N 行 2N 列のヤコビアン行列を計算する
% ために、4回の関数の実行が必要です。
%   
% 'Vectorized' プロパティを設定することは、関数 f がベクトル化されて
% いることを示しています。
%   
% E. Hairer and G. Wanner, Solving Ordinary Differential Equations II,
% Stiff and Differential-Algebraic Problems, Springer-Verlag, Berlin,
% 1991, pp. 5-8.
%   
%   参考 ODE15S, ODE23S, ODE23T, ODE23TB, ODESET, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
