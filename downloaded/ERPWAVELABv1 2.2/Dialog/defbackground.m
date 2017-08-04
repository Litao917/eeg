function varargout = defbackground(varargin)
% Graphical userinterface to define background regions in data
%
% Written by Morten Mørup
%
% DEFBACKGROUND M-file for defbackground.fig
%      DEFBACKGROUND, by itself, creates a new DEFBACKGROUND or raises the existing
%      singleton*.
%
%      H = DEFBACKGROUND returns the handle to a new DEFBACKGROUND or the handle to
%      the existing singleton*.
%
%      DEFBACKGROUND('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEFBACKGROUND.M with the given input arguments.
%
%      DEFBACKGROUND('Property','Value',...) creates a new DEFBACKGROUND or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before defbackground_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to defbackground_OpeningFcn via varargin.
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

% Edit the above text to modify the response to help defbackground

% Last Modified by GUIDE v2.5 18-Oct-2006 11:24:52

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @defbackground_OpeningFcn, ...
                   'gui_OutputFcn',  @defbackground_OutputFcn, ...
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


% --- Executes just before defbackground is made visible.
function defbackground_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to defbackground (see VARARGIN)

% Choose default command line output for defbackground
handles.output = hObject;
t=varargin{1}.tim;
txt=varargin{1}.txt;
set(handles.txt,'String',txt);
if strcmp(txt(1:4),'Boot')
    set(handles.chpboot,'visible','on');
    set(handles.chpboot2,'visible','on');
else
    set(handles.chpboot,'visible','off');
    set(handles.chpboot2,'visible','off');
end
if isfield(varargin{1},'chpboot')
    set(handles.chpboot,'value',varargin{1}.chpboot);
end
for k=1:length(t)
    tim{k}=num2str(t(k));
end
set(handles.start,'string',tim);
set(handles.endtim,'string',tim);
if isfield(varargin{1},'v1')
    set(handles.start,'Value',varargin{1}.v1);
    set(handles.endtim,'Value',varargin{1}.v2);
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes defbackground wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = defbackground_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns start contents as cell array
%        contents{get(hObject,'Value')} returns selected item from start


% --- Executes during object creation, after setting all properties.
function start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in endtim.
function endtim_Callback(hObject, eventdata, handles)
% hObject    handle to endtim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns endtim contents as cell array
%        contents{get(hObject,'Value')} returns selected item from endtim


% --- Executes during object creation, after setting all properties.
function endtim_CreateFcn(hObject, eventdata, handles)
% hObject    handle to endtim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% hObject    handle to ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.s1=get(handles.start,'Value');
handles.s2=get(handles.endtim,'Value');
guidata(hObject,handles);
if handles.s1>handles.s2
    set(handles.errormsg,'String','End time larger than start time')
else
    uiresume(gcf)
end



% --- Executes on button press in chpboot.
function chpboot_Callback(hObject, eventdata, handles)
% hObject    handle to chpboot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chpboot


