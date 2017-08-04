function delselection(h)

% Copyright 2004-2011 The MathWorks, Inc.

%% Deletes selected points and resets the selected status of deleted points

%% Create transaction
T = tsguis.transaction;
recorder = tsguis.recorder;

%% Delete selected data
for k=1:length(h.Waves)
    if h.Waves(k).isvisible  

        data = h.Waves(k).DataSrc.Timeseries.Data;

        % Collect indices in any selected Y interval
        for j=1:size(h.Waves(k).View.SelectedInterval,1)
            data(data>=min(h.Waves(k).View.SelectedInterval(j,:)) & ...
               data<=max(h.Waves(k).View.SelectedInterval(j,:))) = NaN;
        end

        % Update data
        T.ObjectsCell = [T.ObjectsCell, {h.Waves(k).DataSrc.Timeseries}];
        h.Waves(k).DataSrc.Timeseries.Data = data;
        
        %% If macro recorder is on write the code
        if strcmp(recorder.Recording,'on')
            T.addbuffer(['I = false([size(' genvarname(h.Waves(k).DataSrc.Timeseries.Name) '.Data)]);']);
            for j=1:size(h.Waves(k).View.SelectedInterval,1)
               T.addbuffer([genvarname(h.Waves(k).DataSrc.Timeseries.Name) '.Data(' ...
                   genvarname(h.Waves(k).DataSrc.Timeseries.Name) '.Data>=' ...
                   sprintf('%f',min(h.Waves(k).View.SelectedInterval(j,:))) ' & ' ...
                   genvarname(h.Waves(k).DataSrc.Timeseries.Name) '.Data<=' ...
                   sprintf('%f',max(h.Waves(k).View.SelectedInterval(j,:))) ') = NaN;'],...
                   h.Waves(k).DataSrc.Timeseries);
            end      
        end

        % Clear current selection
        h.Waves(k).View.SelectedInterval = [];
    end
end

%% Clear existing selections and reset limits
drawnow % Flush the event queue before activating
h.draw

%% Store transaction
T.commit;
recorder.pushundo(T);