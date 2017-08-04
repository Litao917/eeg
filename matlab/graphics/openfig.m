function figOut = openfig(varargin)
%OPENFIG Open new copy or raise existing copy of saved figure.
%    OPENFIG('NAME.FIG','new') opens figure contained in .fig file,
%    NAME.FIG, and ensures it is completely on screen.  Specifying the
%    .fig extension is optional. Specifying the full path is optional
%    as long as the .fig file is on the MATLAB path.
%
%    If the .fig file contains an invisible figure, OPENFIG returns
%    its handle and leaves it invisible.  The caller should make the
%    figure visible when appropriate.
%
%    OPENFIG('NAME.FIG') is the same as OPENFIG('NAME.FIG','new').
%
%    OPENFIG('NAME.FIG','reuse') opens figure contained in .fig file
%    only if a copy is not currently open, otherwise ensures existing
%    copy is still completely on screen.  If the existing copy is
%    visible, it is also raised above all other windows.
%
%    OPENFIG(...,'invisible') opens as above, forcing figure invisible.
%
%    OPENFIG(...,'visible') opens as above, forcing figure visible.
%
%    F = OPENFIG(...) returns the handle to the figure.
%
%    See also: OPEN, MOVEGUI, GUIDE, GUIHANDLES, SAVE, SAVEAS.

%    OPENFIG(...,'auto') opens as above, forcing figure invisible on
%    creation.  Subsequent calls when the second argument is 'reuse' will
%    obey the visibility setting in the .fig file.
%
%   Copyright 1984-2011 The MathWorks, Inc.
%   Revision: 1.29.12.1.2.4.4.3   Date: 2013/04/11 17:33:02 

% legacy behavior of openfig, supports auto option and old focusing rules 
if ~feature('HGUsingMATLABClasses')

     figOut =  matlab.hg.internal.openfigLegacy(varargin{:});
     return ;
end
   
% matlab graphic mode
narginchk(0, 3);

% Split the argument list and get default values if required
[filename, reuse, visibleAction] = localGetFileAndOptions(varargin);

% Open a new figure or find an existing one
figOut = localOpenFigure(filename, reuse);

% Apply window visibility rules.
hFigs = figOut(ishghandle(figOut, 'figure'));
if strcmpi(visibleAction, 'visible')
    set(hFigs, 'Visible', 'on');
elseif strcmpi(visibleAction, 'invisible')
    set(hFigs, 'Visible', 'off');    
end

for n = 1:numel(hFigs)
   if ~(strcmpi(get(hFigs(n), 'WindowStyle'), 'docked'))
        movegui(hFigs(n), 'onscreen');
   end
end  


function h = localOpenFigure(filename, reuse)

if ~reuse
    h = loadFigure(filename);
else
    % Search for open figures that have a FileName property that contains
    % this file
    allH = findobj(allchild(0), 'flat', 'FileName', filename);
    if isempty(allH)
        h = loadFigure(filename);
    else
        h = allH(end);
    end
end


function [filename, reuse, visibleAction] = localGetFileAndOptions(args)
ip = inputParser;
ip.FunctionName = 'openFigure';
ip.addOptional('Filename', 'Untitled.fig', @ischar);
ip.addOptional('Option', '', @ischar);
ip.addOptional('SecondOption', '', @ischar);

ip.parse(args{:});

filename = ip.Results.Filename;

% Find the full path to the file.
filename = graphics.internal.figfile.findFigFile(filename);

% Check both optional arguments for valid option strings
reuse = false;
visibleAction = 'file';
if ~any(strcmp('Option', ip.UsingDefaults))
    [reuse, visibleAction] = localCheckOption(ip.Results.Option, reuse, visibleAction);
end
if ~any(strcmp('SecondOption', ip.UsingDefaults))
    [reuse, visibleAction] = localCheckOption(ip.Results.SecondOption, reuse, visibleAction);
end



function [reuse, visibleAction] = localCheckOption(value, reuse, visibleAction)
switch lower(value)
    case 'reuse'
        reuse = true;
    case 'new'
        reuse = false ;
    case {'visible', 'invisible','auto'}
        visibleAction = lower(value);
    otherwise
        error(message('MATLAB:openfig:InvalidOption', value));
end

