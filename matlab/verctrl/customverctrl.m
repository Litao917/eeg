function customverctrl(fileNames, arguments)
%CUSTOMVERCTRL Custom version control template.
%   CUSTOMVERCTRL(FILENAMES, ARGUMENTS) is supplied as a function
%   stub for customers who want to integrate a version control
%   system that is not supported by MathWorks.
%
%   This function must conform to the structure of one of the
%   supported version control systems, e.g., RCS.  See rcs.m as
%   an example.
%   
%   See also CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, RCS, SOURCESAFE,
%   PVCS, and CLEARCASE.
%

%   Copyright 1998-2009 The MathWorks, Inc.

% Remove this error message when integrating a custom version
% control system:
error(message('MATLAB:sourceControl:noCustomSystem'));
