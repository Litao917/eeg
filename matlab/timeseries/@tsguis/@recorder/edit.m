function edit(h,parent)
%% Opens the editor dialog box which defines this M logging session

%   Copyright 2004-2012 The MathWorks, Inc.

import com.mathworks.toolbox.timeseries.*;

if isempty(h.Dialog)
    jf = tsguis.getJavaFrame(parent);
    if ~isempty(jf)
        jframe = javax.swing.SwingUtilities.getWindowAncestor(jf.getAxisComponent);
    else
        errordlg(getString(message('MATLAB:timeseries:tsguis:recorder:JavaFiguresMustBeEnabled')),...
            getString(message('MATLAB:timeseries:tsguis:recorder:TimeSeriesTools')),'modal')
        return
    end
    h.Dialog = macroRecorder(jframe);
    h.Dialog.setLocationRelativeTo(jframe);
    % Define the start and stop button callbacks
    set(handle(h.Dialog.BTNStart,'callbackproperties'), ...
        'actionperformedcallback',{@localGetJavaProps h});
    set(handle(h.Dialog.BTNStop,'callbackproperties'), ...
        'actionperformedcallback',{@localStopLogging h})
end
awtinvoke(h.Dialog,'setVisible(Z)',true)

function localGetJavaProps(es,ed,h)

%% Synch the @recorder props to the java dialog
try
    fname = deblank(char(h.Dialog.EDITfile.getText));
    if length(fname)<=2 || ~strcmp(fname(end-1:end),'.m')
        fname = sprintf('%s.m',fname);
    end
    set(h,'Filename',fname,'Path',char(h.Dialog.TXTpath.getText));
catch
    errordlg(getString(message('MATLAB:timeseries:tsguis:recorder:InvalidPath')), ...
        getString(message('MATLAB:timeseries:tsguis:recorder:TimeSeriesTools')),'modal')
    return
end

%% Open the file to make sure that the logging will not fail for file
%% access reasons
mfilepath = fullfile(h.Path,fname);
[fid,msg] = fopen(mfilepath,'wt');
if ~isempty(msg)
    errordlg(getString(message('MATLAB:timeseries:tsguis:recorder:CannotWriteToTheSpecifiedFile')),...
        getString(message('MATLAB:timeseries:tsguis:recorder:TimeSeriesTools')),'modal')
    return
else
    fclose(fid);
end

%% Put the java dialog into the logging state
h.Recording = 'on';
awtinvoke(h.Dialog,'startLogging');

function localStopLogging(es,ed,h)

%% Stop logging callback - turns off logging and writes the data to file

%% Set the dialog state
awtinvoke(h.Dialog,'stopLogging');

%% Write the data
h.write

%% Clear logging status
set(h,'Saveddata','off','Recording','off','TimeseriesIn',[],'TimeseriesOut',[]);