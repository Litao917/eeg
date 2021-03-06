% IHB1DAE  保存則からのスティッフな微分代数方程式 (DAE)
%
% IHB1DAE は、完全な陰的システム f(t,y,y') = 0 として表わされたスティッフな
% 微分代数方程式の解のデモを実行します。
%   
% Robertson 問題は、HB1ODE にコード化されたように、スティッフな常微分方程式 
% (系）を解くコードに対する古典的なテスト問題です。問題は、つぎの通りです。
%
%         y(1)' = -0.04*y(1) + 1e4*y(2)*y(3)
%         y(2)' =  0.04*y(1) - 1e4*y(2)*y(3) - 3e7*y(2)^2
%         y(3)' =  3e7*y(2)^2
%
%
% 定常状態に対する、初期条件 y(1) = 1, y(2) = 0, y(3) = 0 をもつものとして
% 解かれます。
%
% これらの微分方程式は、問題をDAEとして定式化するために使用できる線形の
% 保存則を満たします。
%
%         0 =  y(1)' + 0.04*y(1) - 1e4*y(2)*y(3)
%         0 =  y(2)' - 0.04*y(1) + 1e4*y(2)*y(3) + 3e7*y(2)^2
%         0 =  y(1)  + y(2) + y(3) - 1
%
% この問題は、LSODI [1] の序文において例として用いられます。矛盾のない
% 初期条件は自明ですが、推定 y(3) = 1e-3 が、初期化のテストに使用されます。
% 対数スケールは、長時間間隔の解をプロットするために適しています。y(2) は
% 小さく、その主な変化は比較的短時間で起こります。従って、LSODI の序文は、
% このコンポーネントについて、はるかに小さい絶対許容誤差を指定します。
% また、他の要素とともにプロットする場合、1e4 が乗算されます。コードの
% 通常の出力は、この要素の振る舞いをはっきりとは示しません。従って、この
% 目的のために、追加の出力が指定されます。
%   
%   [1]  A.C. Hindmarsh, LSODE and LSODI, two new initial value ordinary
%        differential equation solvers, SIGNUM Newsletter, 15 (1980), 
%        pp. 10-11.
%   
% 参考 ODE15I, ODE15S, ODE23T, ODESET, HB1ODE, HB1DAE, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc.
