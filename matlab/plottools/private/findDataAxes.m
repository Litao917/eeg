function axesList = findDataAxes (fig)

figH = handle(fig);
if (feature('HGUsingMATLABClasses') == 1)
    axesList = figH.findobj ...
       ('-depth', 8, ...    % 8 is somewhat arbitrary
        'type','axes', ...
        'handlevisibility', 'on', ...
        '-not','tag','legend','-and','-not','tag','Colorbar');
else
        axesList = figH.find ...
       ('-depth', 8, ...    % 8 is somewhat arbitrary
        'type','axes', ...
        'handlevisibility', 'on', ...
        '-not','tag','legend','-and','-not','tag','Colorbar');
end
% Note:  this is the same search used in addsubplot.