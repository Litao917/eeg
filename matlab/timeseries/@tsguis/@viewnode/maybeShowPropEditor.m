function maybeShowPropEditor(h,groupContainer)

% Copyright 2006-2012 The MathWorks, Inc.

import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.widgets.*;

dt = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
% Create a property editor, since its already open in the MDI
if ~dt.isClientShowing('Property Editor', ...
        getString(message('MATLAB:timeseries:tsguis:viewnode:TimeSeriesPlots')))
    if isempty(h.Plot.axesgrid.parent.jpanel) && length(h.Plot.waves)<=1 && ~isempty(groupContainer) && ...
         (~dt.hasClient('Property Editor',getString(message('MATLAB:timeseries:tsguis:viewnode:TimeSeriesPlots'))) || ...
          ~dt.isClientShowing ('Property Editor',getString(message('MATLAB:timeseries:tsguis:viewnode:TimeSeriesPlots'))))
        msg = getString(message('MATLAB:timeseries:tsguis:viewnode:ThePropertyEditorCanBeUsed'));
        propEditOpen = Dialogs.showOptionalConfirmDialog(...
             groupContainer,...
             msg, ...
             getString(message('MATLAB:timeseries:tsguis:viewnode:TimeSeriesTools')), ...
             MJOptionPane.YES_NO_OPTION,...
             MJOptionPane.QUESTION_MESSAGE,tsPrefsPanel.PROPKEY_PROPEDITDLG,1,true);
        if propEditOpen == 0
             drawnow % Flush the queue so that property editor initialized correctly
             showplottool(ancestor(h.Plot.AxesGrid.Parent,'Figure'),'on',...
                 'propertyeditor');
             drawnow
        end
    end
end