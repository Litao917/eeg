function ret_fig = clf(varargin)
%CLF Clear current figure.
%   CLF deletes all children of the current figure with visible handles.
%
%   CLF RESET deletes all children (including ones with hidden
%   handles) and also resets all figure properties, except Position,
%   Units, PaperPosition and PaperUnits, to their default values.
%
%   CLF(FIG) or CLF(FIG,'RESET') clears the single figure with handle FIG.
%
%   FIG_H = CLF(...) returns the handle of the figure.
%
%   See also CLA, RESET, HOLD.

%   CLF(..., HSAVE) deletes all children except those specified in
%   HSAVE.
%
%   Copyright 1984-2013 The MathWorks, Inc.

if nargin>0 && length(varargin{1})==1 && ishghandle(varargin{1}) && strcmpi(get(varargin{1},'Type'),'figure')
    % If first argument is a single figure handle, apply CLF to it
    fig = varargin{1};
    extra = varargin(2:end);
elseif nargin>0 && length(varargin{1})==1 && ~ishghandle(varargin{1})
    error(message('MATLAB:clf:InvalidFigureHandle'));
else
    % Default target is current figure
    fig = gcf;
    extra = varargin;
end

% annotations are cleared by hand since the handle is hidden
clearscribe(fig);

% if IntegerHandle is 'off', then a numeric handle becomes invalid when RESET
% is called in CLO.
fig_was_numeric = true;
if isnumeric(fig)
    [ lmsg, lid ] = lastwarn;
    ws = warning('query','MATLAB:hg:DoubleToHandleConversion');
    warning('off','MATLAB:hg:DoubleToHandleConversion')

    fig_handle = handle(fig);
    
    warning(ws.state,ws.identifier)
    lastwarn( lmsg, lid );
else
    fig_was_numeric = false;
    fig_handle = fig;
end
    
% If the reset option was selected, clear any active modes and any link plot 
% state. 
if ~isempty(extra)
    scribeclearmode(fig_handle);
    if isprop(fig_handle,'ModeManager') && ~isempty(get(fig_handle,'ModeManager'))
        clearModes(get(fig_handle,'ModeManager'));
        set(fig_handle,'ModeManager','');
        uiundo(fig_handle,'clear');
    end
    if ~isdeployed % linkdata is not deployable
        linkDataState = linkdata(fig); 
        if strcmp(get(linkDataState,'Enable'),'on') 
             linkdata(fig,'off'); 
        end 
    end
end

if ~isempty(get(fig,'CurrentAxes'))
    if (graphicsversion(fig,'handlegraphics'))
        set(double(fig),'CurrentAxes',[]);
    else
        set(fig,'CurrentAxes',[]);
    end
end


clo(fig, extra{:});


% cast back to double
if fig_was_numeric
    fig = double(fig_handle);
end

% cause a complete redraw of the figure, so that movie frame remnants
% are cleared as well
try
    refresh(fig)
catch
    %228992 No operation since no figure exists
end


% now that IntegerHandle can be changed by reset, make sure
% we're returning the new handle:
if (nargout ~= 0)
    ret_fig = fig;
end
