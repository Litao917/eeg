% BALLODE   バウンドするボールのデモを実行
% 
% BALLODE は、繰り返されるイベントの位置を求めます。ここで、初期条件は、
% 各最終イベント終了後、変化します。このデモは、ODE23 を使って、10回の
% バウンドを計算します。ボールのスピードは、各バウンドで、0.9倍に変速
% します。ボールの軌道は、出力関数 ODEPLOT を使って、プロットされます。
%
% 参考  ODE23, ODE45, ODESET, ODEPLOT, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
