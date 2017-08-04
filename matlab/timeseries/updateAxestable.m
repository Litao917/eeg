function updateAxestable(h,type,model,startRow,col)
%
% tstool utility function

% Copyright 2005-2012 The MathWorks, Inc.

% Callback for user edits the Axes Panel of the Property Editor
% Update the @timeplot
switch col
    case 0
        if isa(h,'resppack.respplot')
            if strcmp(type,'X')
                h.InputName{startRow+1} = model.getValueAt(startRow,0);
            elseif strcmp(type,'Y')
                h.OutputName{startRow+1} = model.getValueAt(startRow,0);
            end
        elseif isa(h,'wavepack.waveplot') && strcmp(type,'Y')
            h.ChannelName{startRow+1} = model.getValueAt(startRow,0);
        end
    case 1
        if strcmp(type,'Y')
            Ylimmode = h.Axesgrid.YlimMode;
            Ylimmode{startRow+1} = model.getValueAt(startRow,1);
            h.Axesgrid.YlimMode = Ylimmode;
        else
            Xlimmode = h.Axesgrid.XlimMode;
            Xlimmode{startRow+1} = model.getValueAt(startRow,1);
            h.Axesgrid.XlimMode = Xlimmode;
        end
    case {2,3}
        lim = [0 0];
        for r=1:2
            if ischar(model.getValueAt(startRow,1+r))
                try
                    tmp = eval(model.getValueAt(startRow,1+r));
                catch me %#ok<NASGU>
                    tmp = [];
                end
                if isempty(tmp)
                    oldylim=h.Axesgrid.getylim(startRow+1);
                    model.setValueAtNoCallback(num2str(oldylim(r)),startRow,1+r);
                    return
                else
                    lim(r) = tmp;
                end
            else
                lim(r) = model.getValueAt(startRow,1+r);
            end
        end
        if lim(2)<=lim(1)
            errordlg(getString(message('MATLAB:timeseries:TheMINLimitMustBeSmallerThanTheMAXLimit')), ...
                getString(message('MATLAB:timeseries:TimeSeriesTools')),'modal')
            oldylim=h.Axesgrid.getylim(startRow+1);
            model.setValueAtNoCallback(num2str(oldylim(1)),startRow,2);
            model.setValueAtNoCallback(num2str(oldylim(2)),startRow,3);
            return
        end
        if strcmp(type,'Y')
            h.Axesgrid.setylim(lim,startRow+1);
        else
            h.Axesgrid.setxlim(lim,startRow+1);
        end   
end

% Send a viewchnage to refresh absolute x axes time labels
h.AxesGrid.send('viewchange')
