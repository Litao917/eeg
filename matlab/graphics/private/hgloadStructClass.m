function h = hgloadStructClass(S)
%hgloadStructClass Convert a structure to object handles.
%
%  hgloadStructClass converts a saved structure into a set of new handles.
%  This function is called when MATLAB is using objects as HG handles.

%   Copyright 2009 The MathWorks, Inc.

% Create parent-less objects
h = struct2handle(S, 'none', 'convert');



% HG1->HG2 restore the linkaxes 
allAxes = findall(h,'Type','axes');                                           
targets = cell(1,length(allAxes));
props = cell(1,length(allAxes));
maxGroup = 0;
for i = 1:length(allAxes)
    if isappdata(allAxes(i),'graphics_linkaxes_targets') 
        num = getappdata(allAxes(i),'graphics_linkaxes_targets'); 
        targets{num} = [targets{num} allAxes(i)];
        if isempty(props{num})
            props{num} = getappdata(allAxes(i),'graphics_linkaxes_props');  
        end
        rmappdata(allAxes(i),'graphics_linkaxes_targets'); 
        rmappdata(allAxes(i),'graphics_linkaxes_props');
        if num > maxGroup, maxGroup = num; end
    end
end
targets = targets(1:maxGroup); 
props = props(1:maxGroup);
for i = 1:maxGroup
    linkaxes(targets{i},props{i}); 
end

% from HG1 fig ->HG2 restore the subplot listeners
% within HG1 struct filed name is SubplotListeners and SubplotDeleteListeners

% special treatment for 2006a
shouldInstallLM = true;
if length(allAxes)> 1  % only check figure contains the subplot
    if isappdata(allAxes(1),'SubplotInsets')
        shouldInstallLM = false ;
    end
end

lm =  graphics.internal.SubplotListenersManager();
%lm.helper = 0 ;  % trigger set.helper
for iter = 1: length(h)
   if (isappdata(h(iter),'SubplotListenersManager') || isappdata(h(iter),'SubplotListeners')) && shouldInstallLM
       lm.helper = 0; 
       setappdata(h,'SubplotListenersManager',lm);
   end
end

for iterH = 1: length(h)
    if isappdata(h(iterH),'SubplotListeners')
        allAxes = get(h(iterH),'Children');
        for iterA = 1: length(allAxes)
            if isappdata(allAxes(iterA),'SubplotDeleteListener')  % no -s in hg1
                dlm = graphics.internal.SubplotDeleteListenersManager();
                dlm.addToListeners(allAxes(iterA));
                setappdata(allAxes(iterA),'SubplotDeleteListenersManager',dlm);
                rmappdata(allAxes(iterA),'SubplotDeleteListener');
            end
        end
    end
end


