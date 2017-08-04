function undocheckout(fileNames)
%UNDOCHECKOUT Undo version control checkout.
%   UNDOCHECKOUT(FILENAME) Undo the checkout for FILENAME. 
%   FILENAME must be the full path of the file or a cell 
%   array of files. 
%
%   Examples:
%   undocheckout('\filepath\file.ext')
%   Un-checks out \filepath\file.ext from the version control tool.
%
%   undocheckout({'\filepath\file1.ext','\filepath\file2.ext'})
%   Un-checks out \filepath\file1.ext and \filepath\file2.ext from
%   the	version control tool.
%	
%   See also CHECKIN, CHECKOUT, and CMOPTS.
%

%   Copyright 1998-2008 The MathWorks, Inc.

[sc, system] = issourcecontrolconfigured;             % Check for Source control system
if (sc == 0)
	 error(message('MATLAB:sourceControl:noSourceSystem'));
end

if (isempty(fileNames))                               % If no file name is supplied error out.
   error(message('MATLAB:sourceControl:noFileName'));
end

if (ischar(fileNames))                                % Convert the fileNames to a cell array.
   fileNames = cellstr(fileNames);
end

arguments       = cell(1, 2);
arguments{1, 1} = 'action';
arguments{1, 2} = 'undocheckout';
arguments{2, 1} = 'lock';
arguments{2, 2} = 'off';

feval(system, fileNames, arguments);