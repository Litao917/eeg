function s=toolboxdir(tbxdirname)
% TOOLBOXDIR Root directory for specified toolbox
%    S=TOOLBOXDIR(TBXDIRNAME) returns a string that is the absolute
%    path to the specified toolbox directory name, TBXDIRNAME
%
%    TOOLBOXDIR is particularly useful for MATLAB Compiler. The base
%    directory of all toolboxes installed with MATLAB is
%    <matlabroot>/toolbox/<tbxdirname>. However, in deployed mode, the base
%    directories of the toolboxes are different. TOOLBOXDIR returns the
%    correct root directory irrespective of the mode in which the code is
%    running.
%
%    See also MATLABROOT, COMPILER/CTFROOT.

%    Copyright 1984-2012 The MathWorks, Inc.

narginchk(1,1)

if( ~isdeployed )
    s=fullfile(matlabroot,'toolbox', tbxdirname);
else
    if (strcmpi(tbxdirname, 'matlab') || strcmpi(tbxdirname, 'compiler'))
        s=fullfile(tbxprefix,lower(tbxdirname) );
    else
        s=fullfile(ctfroot, 'toolbox', tbxdirname);
    end
end
if(exist(s, 'dir')~=7)
    error(message('MATLAB:toolboxdir:DirectoryNotFound', tbxdirname));
end
