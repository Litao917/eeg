%EVAL Execute string with MATLAB expression.
%   EVAL(EXPRESSION) evaluates the MATLAB code in the string EXPRESSION.
%
%   [OUTPUT1,...,OUTPUTN] = EVAL(EXPRESSION) returns output from EXPRESSION
%   in the specified variables.
%
%   Example: Interactively request the name of a matrix to plot.
%
%      expression = input('Enter the name of a matrix: ','s');
%      if (exist(expression,'var'))
%         plot(eval(expression))
%      end
%
%   See also FEVAL, EVALIN, ASSIGNIN, EVALC.

%   Copyright 1984-2011 The MathWorks, Inc.
%   Built-in function.
