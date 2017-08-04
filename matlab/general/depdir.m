function [list, prob_files, prob_symbols, prob_strings] = depdir(varargin)
%DEPDIR  Locate dependent directories of program file.
%    LIST = DEPDIR('FUN') returns a cell array of directory names
%    that FUN is dependent on.
%
%    [LIST,PROB_FILES,PROB_SYMBOLS,PROB_STRINGS] = DEPDIR('FUN') also
%    returns a list of MATLAB program or pcode files that could not be
%    parsed in PROB_FILES, a list of symbols that could not be found in
%    PROB_SYMBOLS, and list of strings that could not be parsed in
%    PROB_STRINGS.
%
%    [...] = DEPDIR('FILE1','FILE2',...) processes each file in turn.
%
%    See also DEPFUN.

%    Copyright 1984-2010 The MathWorks, Inc. 

% Start to display DEPDIR's deprecation warning in 14a
warning(message('MATLAB:DEPFUN:DeprecatedDEPDIR'));
% Prevent DEPFUN's warning from overwriting LASTWARN.
[wmsg,wid] = lastwarn;
resetLastWarn = onCleanup(@()lastwarn(wmsg,wid));

% Suppress DEPFUN's deprecation warning
orgWarn = warning('off', 'MATLAB:DEPFUN:DeprecatedAPI');
restoreWarn = onCleanup(@()warning(orgWarn));

% Use depfun to get a list of the dependent functions
%
[list,~,~,prob_files,prob_symbols,prob_strings] = ...
					depfun(varargin{:},'-quiet');

% Strip off function names in list
%
for i=1:length(list)
  list{i} = fileparts(list{i});
end

% Find the unique set
%
list = unique(list);
