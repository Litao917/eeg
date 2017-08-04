function [b] = hgbehaviorfactory(behavior_name,hObj)
% This internal helper function may be removed in a future release.

%HGBEHAVIORFACTORY Convenience for creating behavior objects
%   
%   HGGETBEHAVIOR
%   With no arguments, a list of all registered behavior
%   objects is generated to the command window.
%
%   BH = HGBEHAVIORFACTORY(NAME)
%   Specify NAME (string or cell array of strings) to create
%   behavior objects.
%
%   Example 1:
%   bh = hgbehaviorfactory('Zoom');
%
%   Example 2:
%   h = line;
%   bh = hgbehaviorfactory({'Zoom','DataCursor','Rotate3d'});
%   set(h,'Behavior',bh);
%
%   See also hgaddbehavior, hggetbehavior.

% Copyright 2003-2013 MathWorks, Inc.

if nargin==0
    % Pretty print output
    info = localGetBehaviorInfo;
    localPrettyPrint(info);
else
    % if the axes is passed as the second argument, behavior object is
    % constructed based on the axes or figure version.
    if nargin == 1 
        hObj = [];
    end
    b = localCreate(behavior_name, hObj);
end

%---------------------------------------------------%
function [ret_h] = localCreate(behavior_name, hObj)

ret_h = [];
dat = localGetBehaviorInfo(hObj);
% Note that ret_h cannot be used to accumulate both MCOS and UDD behavior
% objects. This should not happen currently since hgbehaviorfacotry is not
% called with a cell array of behavior_name. 
for n = 1:length(dat)
     info = dat{n};
     s = strcmpi(behavior_name,info.name);
     if any(s)
         behavior_name(s) = [];
         bh = feval(info.constructor);
         if isempty(ret_h)
             ret_h = bh;
         else
             ret_h(end+1) = bh; %#ok<AGROW>
         end
     end
end

%---------------------------------------------------%
function localPrettyPrint(behaviorinfo)
% Pretty prints to command window
% in a similar manner as the PATH command.

% Header
disp(' ');
disp(sprintf('\tBehavior Object Name         Target Handle'))     
disp(sprintf('\t--------------------------------------------'))

info = {};
for n = 1:length(behaviorinfo)
    str1 = behaviorinfo{n}.name;
    str2 = behaviorinfo{n}.targetdescription;

    % string formatting, padding specific number of dots
    padl = 30-length(str1);
    p = [];
    if padl>0
      p = zeros(1,padl); p(:) = '.';
    end
    info{n} = ['''',str1,'''',p,str2];
end

% Display items
ch= strvcat(info);
tabspace = ones(size(ch,1),1);
tabspace(:) = sprintf('\t');
s = [tabspace,ch];
disp(s)

% Footer
disp(sprintf('\n'))

%---------------------------------------------------%
function [behaviorinfo] = localGetBehaviorInfo(hObj)
% Loads info for registered behavior objects

behaviorinfo = {};
if nargin == 0 
    hObj = [];
end

% Constructor is based on graphics version, if axes/figure is available; 
% otherwise, default constructors based on graphicsversion(hObj,'handlegraphics').
% Behavior objects will be a udd for hg1 and mcos for hg2. 
% If an axes information is available for mixed mode then axes/figure decides if it will be an mcos,
% or a udd object.

hgUddObjFlag = graphicsversion('handlegraphics'); 
if ~isempty(hObj)
    hgUddObjFlag = graphicsversion(hObj,'handlegraphics');
 end


info = [];
info.name = 'Plotedit';
info.targetdescription = 'Any Graphics Object';
if hgUddObjFlag
   info.constructor = 'graphics.ploteditbehavior';
else
   info.constructor = 'graphics.internal.PlotEditBehavior';
end
behaviorinfo{end+1} = info;

info = [];
info.name = 'Print';
if hgUddObjFlag
   info.targetdescription = 'Any Graphics Object';
   info.constructor = 'graphics.printbehavior';
else
   info.targetdescription = 'Figure and Axes';
   info.constructor = 'graphics.internal.PrintBehavior';
end
behaviorinfo{end+1} = info;

info = [];
info.name = 'Zoom';
info.targetdescription = 'Axes';
if hgUddObjFlag
    info.constructor = 'graphics.zoombehavior';
else
    info.constructor = 'graphics.internal.ZoomBehavior';
end
behaviorinfo{end+1} = info;

info = [];
info.name = 'Pan';
info.targetdescription = 'Axes';
if hgUddObjFlag
   info.constructor = 'graphics.panbehavior';
else
   info.constructor = 'graphics.internal.PanBehavior';
end
behaviorinfo{end+1} = info;

info = [];
info.name = 'Rotate3d';
info.targetdescription = 'Axes';
if hgUddObjFlag
    info.constructor = 'graphics.rotate3dbehavior';
else
    info.constructor = 'graphics.internal.Rotate3dBehavior';
end
behaviorinfo{end+1} = info;

info = [];
info.name = 'DataCursor';
info.targetdescription = 'Axes and Axes Children';
if hgUddObjFlag
    info.constructor = 'graphics.datacursorbehavior';
else
    info.constructor = 'graphics.internal.DataCursorBehavior';
end
behaviorinfo{end+1} = info;

info = [];
info.name = 'MCodeGeneration';
info.targetdescription = 'Axes and Axes Children';
if hgUddObjFlag
    info.constructor = 'graphics.mcodegenbehavior';
else
    info.constructor = 'graphics.internal.MCodeGenBehavior';
end
behaviorinfo{end+1} = info;

info = [];
info.name = 'DataDescriptor';
info.targetdescription = 'Axes and Axes Children';
if hgUddObjFlag
    info.constructor = 'graphics.datadescriptorbehavior';
else
    info.constructor = 'graphics.internal.DataDescriptorBehavior';
end
behaviorinfo{end+1} = info;

info = [];
info.name = 'PlotTools';
info.targetdescription = 'Any graphics object';
if hgUddObjFlag
   info.constructor = 'objutil.plottoolsbehavior';
else
   info.constructor = 'matlab.graphics.internal.plottools.PlottoolsBehavior';
end
behaviorinfo{end+1} = info;

info = [];
info.name = 'Linked';
info.targetdescription = 'Any graphics object';
if hgUddObjFlag
    info.constructor = 'datamanager.linkbehavior';
else
    info.constructor = 'matlab.graphics.internal.datamanager.LinkBehavior';
end
behaviorinfo{end+1} = info;

info = [];
info.name = 'Brush';
info.targetdescription = 'Any graphics object';
if hgUddObjFlag
    info.constructor = 'datamanager.brushbehavior';
else
    info.constructor = 'matlab.graphics.internal.datamanager.BrushBehavior';
end
behaviorinfo{end+1} = info;

