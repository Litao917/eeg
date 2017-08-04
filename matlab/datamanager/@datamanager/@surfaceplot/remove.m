function remove(this,keepflag)

%   Copyright 2007-2013 The MathWorks, Inc.

% Find brushing array
I = [];
h = this.HGHandle;
if ~isempty(h.BrushData)
    I = h.BrushData(:,:,1)>0;
    for j=2:size(h.BrushData,3)
        I = I | (h.BrushData(:,:,j)>0);
    end
end  
if isempty(I)
    return
end
if keepflag
    I = ~I;
end

% Find complete columns/rows
Icols = all(I,1);
Irows = all(I,2);
if ~any(Icols) && ~any(Irows)
    if keepflag   
        errordlg(getString(message('MATLAB:datamanager:dataEditUsingMATLABClasses:NoRemoveNoBrush')), ...
            'MATLAB','modal');
    else
        errordlg(getString(message('MATLAB:datamanager:dataEditUsingMATLABClasses:NoRemoveBrush')), ...
           'MATLAB','modal');
    end
    return
end
% Calculate the new surface data
xdata = get(h,'XData');
ydata = get(h,'YData');
zdata = get(h,'ZData');
ydata(Irows) = [];
xdata(Icols) = [];
zdata(:,Icols) = [];
zdata(Irows,:) = [];
if isempty(zdata) || isempty(xdata) || isempty(ydata)
    zdata = NaN;
    xdata = NaN;
    ydata = NaN;
end

% Apply the new data
manMode = true;
try 
    manmode = strcmp(get(h,'XDataMode'),'manual');
end
if manMode
    if isempty(zdata)
        set(h,'XData',xdata,'YData',ydata);
    else
        set(h,'XData',xdata,'YData',ydata,'ZData',zdata);
    end
else
    if isempty(zdata)
        set(h,'YData',ydata);
    else
        set(h,'YData',ydata,'ZData',zdata);
    end
end

