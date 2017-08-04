function this = variableEditorPaste(this,rows,columns,data)
%   This function is undocumented and will change in a future release

% Performs a paste operation on data from the clipboard which was not
% obtained from another categorical array.

%   Copyright 2013 The MathWorks, Inc.

ncols = size(data,2);
nrows = size(data,1);

% If the number of pasted columns does not match the number of selected columns,
% just paste columns starting at the left-most column 
if length(columns)~=ncols
    columns = columns(1):columns(1)+ncols-1;
end

% If the number of pasted rows does not match the number of selected rows,
% just paste rows starting at the top-most row 
if length(rows)~=nrows
    rows = rows(1):rows(1)+nrows-1;
end
 
% Paste data onto existing nominal variables
s = struct('type',{'()'},'subs',{{rows,columns}});
if isa(data,'categorical')            
    this = subsasgn(this,s,data);
elseif iscell(data)
    this = subsasgn(this,s,data);
else
    this = subsasgn(this,s,cellstr(data));
end



