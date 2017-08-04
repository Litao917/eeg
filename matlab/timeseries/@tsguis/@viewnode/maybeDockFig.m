function maybeDockFig(h)

% Copyright 2006-2012 The MathWorks, Inc.

import com.mathworks.mde.desk.*;
import com.mathworks.mwswing.*;
import com.mathworks.toolbox.timeseries.*;
import com.mathworks.widgets.desk.*;  % Doesn't appear to be needed

%% If a group name is specified for the tsviewer, dock the figure in a 
%% maximized MDI with the Plot Tools initially closed
mdiGroupName = h.getRoot.Tsviewer.MDIGroupName;
if ~isempty(mdiGroupName)
    if isunix % Work around g279812 
        jf = tsguis.getjavaFrame(h.Figure);      
        jf.setGroupName(mdiGroupName);
    end
    mld = MLDesktop.getInstance;
    
    % Return early if figure is already docked and group is undocked
    if strcmp(get(h.Figure,'windowStyle'),'docked') && ~mld.isGroupDocked(mdiGroupName)
        return
    end 
    
    mld.setGroupDocked(mdiGroupName, false);
    % Initialize the MDI in maximized state
    if ~mld.isGroupShowing(mdiGroupName)
        mld.setDocumentArrangement(mdiGroupName,Desktop.MAXIMIZED,[]);
        mld.closeGroupSingletons(mdiGroupName)
        if strcmp(get(h.Figure,'visible'),'on')
           mld.showGroup(mdiGroupName,false);
        end
    end
    % Make sure group configuration is complete before docking
    drawnow
    set(h.Figure,'WindowStyle','docked','Visible','on');
else
    set(h.Figure,'visible','on');
end