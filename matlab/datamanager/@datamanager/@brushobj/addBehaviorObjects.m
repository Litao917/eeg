function addBehaviorObjects(h)

% This undocumented function may be removed in a future release.

%   Copyright 2004-2010 The MathWorks, Inc.

brushGraphicObj = h.SelectionHandles;
for k=1:length(brushGraphicObj)
    % Selection graphics should have no legend
    set(brushGraphicObj(k),'DisplayName','');
    hasbehavior(double(brushGraphicObj(k)),'legend',false);

    % Exclude from code generation
    b = hggetbehavior(brushGraphicObj(k),'MCodeGeneration');
    b.MCodeIgnoreHandleFcn = @localReturnTrue;
    b = hggetbehavior(brushGraphicObj(k),'PlotEdit');
    b.Enable = false;
    b.EnableCopy = false;
    b.EnablePaste = false;
    b = hggetbehavior(brushGraphicObj(k),'DataCursor');
    b.StartCreateFcn = {@localGetBaseObj h}; 
end

function state = localReturnTrue(~,~)

state = true;

function obj = localGetBaseObj(bobj)

obj = bobj.HGHandle;