function pasteUnlinked(h)

% Copyright 2007-2011 The MathWorks, Inc.

% Paste the current selection to the command line
sibs = datamanager.getAllBrushedObjects(h);
if isempty(sibs)
    errordlg(getString(message('MATLAB:datamanager:pasteUnlinked:AtLeastOneGraphicObjectMustBeBrushed')),'MATLAB','modal')
    return
elseif length(sibs)==1
    localMultiObjCallback(sibs);
else
    datamanager.disambiguate(handle(sibs),{@localMultiObjCallback});
end

function localMultiObjCallback(gobj)

import com.mathworks.page.datamgr.brushing.*;
import com.mathworks.mde.cmdwin.*;

if ~graphicsversion(gobj,'handlegraphics')
    cmdStr = datamanager.var2string(brushing.select.getArraySelection(gobj));
else   
    this = getappdata(double(gobj),'Brushing__');
    cmdStr = datamanager.var2string(this.getArraySelection);
end
cmd = CmdWinDocument.getInstance;
awtinvoke(cmd,'insertString',cmd.getLength,cmdStr,[]);