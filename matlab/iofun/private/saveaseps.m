function saveaseps( h, name )
%SAVEASEPS Save Figure to Encapsulated Postscript file with TIFF preview.

%   Copyright 1984-2002 The MathWorks, Inc. 

print( h, name, '-deps', '-tiff' )
