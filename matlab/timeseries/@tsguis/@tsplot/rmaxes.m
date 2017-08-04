function rmaxes(h,pos)
%% Removes axes at the specified position

%   Copyright 2004-2012 The MathWorks, Inc.

%% Check that there are enough axes to remove
if length(h.ChannelName)<2
    errordlg(getString(message('MATLAB:timeseries:tsguis:tsplot:TheNumberOfAxesCannotBeReducedToZero')),...
        getString(message('MATLAB:timeseries:tsguis:tsplot:TimeSeriesTools')),'modal')
    return
end

%% Check that the axes to be removed are empty
for k=1:length(h.Waves)
    if ~isempty(intersect(h.Waves(k).RowIndex,pos))
         ButtonName = questdlg(getString(message('MATLAB:timeseries:tsguis:tsplot:SelectedAxesContainContinue', ...
             h.Waves(k).DataSrc.Timeseries.Name)), ...
                       getString(message('MATLAB:timeseries:tsguis:tsplot:TimeSeriesTools')), ...
                       getString(message('MATLAB:timeseries:tsguis:tsplot:OK')), ...
                       getString(message('MATLAB:timeseries:tsguis:tsplot:Cancel')), ...
                       getString(message('MATLAB:timeseries:tsguis:tsplot:Cancel')));
         if strcmp(ButtonName,getString(message('MATLAB:timeseries:tsguis:tsplot:Cancel')))
             return
         end
         % Remove wave
         h.rmwave(h.Waves(k));
    end
end

%% Define the new channel names 
newChannelName = h.ChannelName;
newChannelName(pos) = [];

%% Resize the grid - retaining the scales of axes in manual
cacheYlimMode = h.AxesGrid.YlimMode;
cacheYlimScale = h.AxesGrid.getylim;
cacheYlimMode(pos) = [];
cacheYlimScale(pos) = [];
h.resize(newChannelName);
for k=1:h.AxesGrid.size(1)
    if strcmpi(cacheYlimMode{k},'manual')
        h.AxesGrid.setylim(cacheYlimScale{k},k);
    end
end

%% Announce the change to the axestable listeners
h.AxesGrid.send('viewchanged')
