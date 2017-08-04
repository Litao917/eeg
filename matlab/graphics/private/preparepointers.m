function pj = preparepointers( pj )
%PREPAREPOINTERS Set Pointers of all open Figures to Watch. 
%   Saves current value for restoration by RESTOREPOINTERS.
%
%   See also RESTOREPOINTER

%   Copyright 1984-2002 The MathWorks, Inc. 

%Let user know we are working and get rid of XOR cross hair cursor
if strcmp( pj.Driver, 'mfile' )
    pj.AllFigures = [];
    return
end

pj.AllFigures = findall(0,'type','figure');
if ~isempty(pj.AllFigures)
    pj.AllPointers = get( pj.AllFigures, 'pointer');
    set( pj.AllFigures, 'pointer', 'watch')
end
