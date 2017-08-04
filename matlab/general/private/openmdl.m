function out = openmdl(filename)
%OPENMDL   Open *.MDL model in Simulink.  Helper function for OPEN.
%
%   See OPEN.

%   Chris Portal 1-23-98
%   Copyright 1984-2009 The MathWorks, Inc.

if nargout, out = []; end

if exist('open_system','builtin')
    evalin('base', ['open_system(''' strrep(filename, '''','''''') ''');'] );
else
    error(message('MATLAB:openmdl:ExecutionError'))
end
