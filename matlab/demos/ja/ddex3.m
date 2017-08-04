% DDEX3  DDESD の例
%
%   この例は、状態依存の遅延を使って 2 つの遅延微分方程式のシステムを
%   解きます。
%       y1'(t) =  y2(t)  
%       y2'(t) = -y2(exp(1-y2(t))) * y2(t)^2 * exp(1-y2(t))  
%   システムは解析解をもちます。
%       y1(t) = log(t)
%       y2(t) = 1/t
%   ここで、t < 0.1 に対する履歴として機能します。
%   
%   問題は、つぎの文献に基づきます。
%   W.H. Enright and H. Hayashi, The Evaluation of Numerical Software 
%   for Delay Differential Equations, pp. 179-192 in R. Boisvert (Ed.), 
%   The Quality of Numerical Software: Assessment and Enhancement, 
%   Chapman & Hall, London, 1997.
%  
%   参考 DDESD, FUNCTION_HANDLE.


%   Copyright 1984-2006 The MathWorks, Inc. 
