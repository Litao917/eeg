function EEGLABtoERPWAVELAB

% Function for exporting an epoched dataset from EEGLAB to ERPWAVELAB.
% Calls EEGcreate to perform time-frequency transformation. 
% The transformed dataset is opened in ERPWAVELAB.

global EEG

if isempty(which('ERPWAVELAB.m'))
    web http://www.erpwavelab.org/
else
    if size(EEG.data,3)==1
        disp('Data must be epoched before imported to ERPWAVELAB');
    elseif isempty(EEG.chanlocs)
        disp('Channel locations must be defined prior to importing the dataset to ERPWAVELAB');
    else
        h=EEGcreate;        % GUI for time-frequency transformation
        uiwait(h);
        hand=guidata(h);
        delete(hand.figure1);
        opts.filenames=hand.filenames;
        opts.pathnames=hand.pathnames;
        ERPWAVELAB(opts);   % Time-frequency transformed data is opended in ERPWAVELAB
    end
end
