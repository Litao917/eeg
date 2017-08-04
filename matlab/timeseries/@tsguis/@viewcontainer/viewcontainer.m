function this = viewcontainer(label,childclass)

% Copyright 2004-2012 The MathWorks, Inc.

import java.awt.dnd.*
import com.mathworks.toolbox.timeseries.*;

%% Constructor for viewcontainer node
this = tsguis.viewcontainer;
this.HelpFile = 'plots_manage';


%% Icon and label
set(this,'Label',label,'ChildClass',childclass)
set(this,'AllowsChildren',true,'Editable',true,'Icon',...
    fullfile(matlabroot,'toolbox','matlab','timeseries','folder.gif'));

%% Build tree node. Note in the CETM there is no need to do this because the
%% Explorer calls it when building the tree
this.getTreeNodeInterface;