% KNEEODE  非負の制約をもつ "knee problem"
%   
%   0 < epsilon << 1 における、つぎの初期値問題
%
%       epsilon*y' = (1-x)*y - y^2,    y(0) = 1 
%
%   の解は、それぞれ、x < 1 と x > 1 に対する null の等斜褶曲 y = 1 - x と 
%   y = 0 に近似します。デフォルトの許容誤差で計算された数値解は、積分
%   区間全体に対する y = 1 - x の等斜褶曲に従います。非負制約を課すことで、
%   正しい解になります。
%
%   G. Dahlquist, L. Edsberg, G. Skollermo, G. Soderlind, Are the
%   Numerical Methods and Software Satisfactory for Chemical
%   Kinetics?, in Numerical Integration of Differential Equations
%   and Large Linear Systems, J. Hinze ed., Springer, Berlin, 1982,
%   pp. 149-164. 
%   
%   参考 ODE15S, ODE23T, ODE23TB, ODESET, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc. 
