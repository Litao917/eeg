function write(h)

% Copyright 2004-2012 The MathWorks, Inc.

%% Find and open the file
if length(h.Filename)<3
    return
end
mfilepath = fullfile(h.Path,h.Filename);
[fid,msg] = fopen(mfilepath,'w');
if ~isempty(msg)
    error(message('MATLAB:tsguis:recorder:write:noopen'))
end

%% Write the file header
fprintf(fid,'%s','function ');
fprintf(fid,'%s','[');
for k=1:length(h.TimeseriesOut)
    fprintf(fid,'%s',sprintf('%s,',genvarname(h.TimeseriesOut(k).Name)));
end
for k=1:length(h.TimeseriesIn)-1
    fprintf(fid,'%s',sprintf('%s,',genvarname(h.TimeseriesIn(k).Name)));
end
if ~isempty(h.TimeseriesIn)
    fprintf(fid,'%s',sprintf('%s] = ',genvarname(h.TimeseriesIn(end).Name)));
else
    fprintf(fid,'%s',sprintf('] = '));  
end
fprintf(fid,'%s',h.Filename(1:end-2));
if ~isempty(h.TimeseriesIn)
    fprintf(fid,'%s','(');
    for k=1:length(h.TimeseriesIn)-1
        fprintf(fid,'%s,',genvarname(h.TimeseriesIn(k).Name));
    end
    fprintf(fid,'%s)',genvarname(h.TimeseriesIn(end).Name));
end
fprintf(fid,'\n\n%s', ['%% ' ...
    getString(message('MATLAB:timeseries:tsguis:recorder:TimeSeriesToolGeneratedCode',...
    datestr(now)))]);


%% Loop through the undo stack and write the contents of each transaction
%% buffer to the logged file
for k=1:length(h.Undo)
    thistrans = h.Undo(k);
    for j=1:length(thistrans.Buffer)
        fprintf(fid,'%s',sprintf('%s\n',thistrans.Buffer{j}));
    end
    % Clear buffer
    thistrans.Buffer = {};
end

%% Clear in/out time series names
h.TimeseriesIn = [];
h.TimeseriesOut = [];

%% Close the file and update the path
fclose(fid);

%% Edit the file
try %#ok<TRYNC>
    edit(mfilepath);
end
