function cellarray = makedisplaynames (var, varname)
% This undocumented function may be removed in a future release.
  
% MAKEDISPLAYNAMES creates a cell array of display names that can be
% assigned to the DisplayName of the plot of a 2D matrix.
% One name is created for each plotted column, e.g. 'data(:,1)'.

% Copyright 2003-2006 The MathWorks, Inc.

exp = strcat (varname, '(:,%d)\n');
str = sprintf (exp, 1:length(var));
cellarray = strread (str, '%s', 'delimiter', '\n');
