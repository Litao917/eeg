function figObj = enddrag(figObj)
%FIGOBJ/ENDDRAG End drag for figobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 

dragBin = figObj.DragObjects;
for aObjH = fliplr(dragBin.Items);
   enddrag(aObjH);
end

% restore 
HG = get(figObj,'MyHGHandle');
set(HG,'pointer','arrow',...
        'WindowButtonMotionFcn','',...
        'WindowButtonUpFcn',''...
        );
if isappdata(HG,'ScribeSaveFigUnits')
   oldUnits = getappdata(HG,'ScribeSaveFigUnits');
   if ~isempty(oldUnits)
      set(HG,'Units',oldUnits);
   end
   rmappdata(HG,'ScribeSaveFigUnits');
end