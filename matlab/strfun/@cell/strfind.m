function items = strfind(str,pat)
%STRFIND Find pattern in a cell array of strings.
%   [ITEMS]=STRFIND(STR,PAT)
%   Implementation of STRFIND for cell arrays of strings.  Returns a cell array,
%   ITEMS, of the same shape as STR, containing all starting positions of PAT
%   in each cell of STR.
%
%   INPUT PARAMETERS:
%       STR:  cell array of strings.
%       PAT:  char vector
%
%   RETURN PARAMETERS:
%       ITEMS: cell array of double arrays, of size of STR. 
%
%   See STRFIND for more information.

%   Copyright 1984-2010 The MathWorks, Inc.
%------------------------------------------------------------------------------
% initialise variables
items = cell(0);

% handle input
% verify number of input arguments
narginchk(2,2);
% check empty input arguments
if isempty(str)
    return; 
end

% check input class
if ~(iscellstr(str) && ischar(pat))
  error(message('MATLAB:strfind:InputClass'));
end

% reserve memory for output parameter
items = cell(size(str));
% iteratively find string in cell array
for i = 1:numel(str)
    items{i} = strfind(str{i},pat);
end
%------------------------------------------------------------------------------