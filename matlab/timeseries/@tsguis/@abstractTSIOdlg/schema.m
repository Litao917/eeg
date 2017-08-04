function schema
%Defines properties for the children dialogs.
%
%   Parent class for timeseries import/export dialogs, which includes: 
%       Visiblity
%       Handles array
%       Figures array
%       Abstract listeners for XXXXXX
%
%   Author(s): Rong Chen
%   Copyright 2004-2012 The MathWorks, Inc. 

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'abstractTSIOdlg');

%% Public properties

%% Visibility
p = schema.prop(c,'Visible','on/off');

%% Handles
p = schema.prop(c,'Handles','MATLAB array');

%% Figures
p = schema.prop(c,'Figure','MATLAB array');

%% Parent
p = schema.prop(c,'Parent','handle');

%% Listeners
p = schema.prop(c,'Listeners','MATLAB array');

%% Cleanup listeners
schema.prop(c,'DeleteListener','MATLAB array');

%% Parameters for determine the positions of all the GUI components 
p = schema.prop(c,'DefaultPos','MATLAB array');

%% storing the size of the monitor screen 
p = schema.prop(c,'ScreenSize','MATLAB array');
p.AccessFlags.PublicSet = 'off';




