% NUMGRID   2次元領域でのグリッド点の番号付け
% 
% G = NUMGRID(REGION,N) は、REGION で決定されるサブ領域 -1<=x<=1 および
% -1<=y<=1 内の、N 行 N 列のグリッド上の点を番号付けます。
% SPY(NUMGRID(REGION,N)) は、点をプロットします。
% DELSQ(NUMGRID(REGION,N)) は、5 点離散ラプラシアンを出力します。
% 現在使用可能な領域は、つぎのものです。
% 
%    'S' - 正方形
%    'L' - 正方形全体の3/4のL型領域
%    'C' - 'L'に似ていますが、第4象限に4半円をもちます。
%    'D' - 単位円
%    'A' - 環状
%    'H' - ハート型
%    'B' - "Butterfly"の外側
%    'N' - 正方形の入れ子式のナンバリング
% 
% 他の領域を追加するためには、toolbox/matlab/demos/numgrid.m を修正して
% ください。
%
% 参考  DELSQ, DELSQSHOW, DELSQDEMO.


%   Copyright 1984-2006 The MathWorks, Inc.
