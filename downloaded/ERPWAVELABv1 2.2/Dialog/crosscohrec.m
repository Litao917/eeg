function varargout = crosscohrec(varargin)
% Dialog explaining cross coherence succesfully recorded
%
% Written by Morten Mørup
%
% CROSSCOHREC M-file for crosscohrec.fig
%      CROSSCOHREC, by itself, creates a new CROSSCOHREC or raises the existing
%      singleton*.
%
%      H = CROSSCOHREC returns the handle to a new CROSSCOHREC or the handle to
%      the existing singleton*.
%
%      CROSSCOHREC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CROSSCOHREC.M with the given input arguments.
%
%      CROSSCOHREC('Property','Value',...) creates a new CROSSCOHREC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before crosscohrec_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to crosscohrec_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Copyright (C) Morten Mørup and Technical University of Denmark, 
% September 2006
%                                          
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% Edit the above text to modify the response to help crosscohrec

% Last Modified by GUIDE v2.5 26-Oct-2006 21:28:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @crosscohrec_OpeningFcn, ...
                   'gui_OutputFcn',  @crosscohrec_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before crosscohrec is made visible.
function crosscohrec_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to crosscohrec (see VARARGIN)

% Choose default command line output for crosscohrec
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes crosscohrec wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = crosscohrec_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
