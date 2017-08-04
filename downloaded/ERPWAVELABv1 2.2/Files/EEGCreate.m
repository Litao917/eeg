function varargout = EEGCreate(varargin)
% GUI for ERPWAVELAB enabling the user to define the time-frequency
% transformation.
%
% Written by Morten Mørup
%
% EEGcreate takes user information given by the user interface
% EEGCreate.fig and sends this infomration to the function createitEEG,
% i.e.
%   EEGCreate -> createitEEG -> wanalysis
%
%
%
% EEGCREATE M-file for EEGCreate.fig
%      EEGCREATE, by itself, creates a new EEGCREATE or raises the existing
%      singleton*.
%
%      H = EEGCREATE returns the handle to a new EEGCREATE or the handle to
%      the existing singleton*.
%
%      EEGCREATE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EEGCREATE.M with the given input arguments.
%
%      EEGCREATE('Property','Value',...) creates a new EEGCREATE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EEGCreate_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EEGCreate_OpeningFcn via varargin.
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
%
% Revision:
% 6 November    Change of t1 and t2 to be in time index instead of ms.
%
% 17 November   res initialized as zeros(6,1) instead of zeros(5,1),
%               normalization 1/f set in main ERPWAVELAB program.
%
% 26 January 2007   Corrected such that measures can be de-selected

% Edit the above text to modify the response to help EEGCreate

% Last Modified by GUIDE v2.5 06-Nov-2006 11:29:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EEGCreate_OpeningFcn, ...
                   'gui_OutputFcn',  @EEGCreate_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before EEGCreate is made visible.
function EEGCreate_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EEGCreate (see VARARGIN)
global EEG 
% Choose default command line output for EEGCreate
handles.output = hObject;
set(handles.chantoanal,'String',[num2str(1) ':' num2str(length(EEG.chanlocs))]);
R=mat2cellstring(EEG.times);
set(handles.fromms,'String',R);
set(handles.toms,'String',R);
set(handles.fromms,'Value',1);
set(handles.toms,'Value',length(R));
set(handles.filetext,'String',[EEG.filepath, EEG.filename(1:end-4)])
% Update handles structure
guidata(hObject, handles);
dms_Callback(hObject, [], handles)
popupmenu1_Callback(hObject, eventdata, handles);

% UIWAIT makes EEGCreate wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EEGCreate_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


% --- Executes during object creation, after setting all properties.
function edit17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit17_Callback(hObject, eventdata, handles)
% hObject    handle to edit17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit17 as text
%        str2double(get(hObject,'String')) returns contents of edit17 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes on button press in fname.
function fname_Callback(hObject, eventdata, handles)
% hObject    handle to fname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname]=uiputfile('*.*','Coherence Explorer filename(s)');
set(handles.filetext,'String',[pathname filename]);


% --- Executes during object creation, after setting all properties.
function epochs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function epochs_Callback(hObject, eventdata, handles)
% hObject    handle to epochs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epochs as text
%        str2double(get(hObject,'String')) returns contents of epochs as a double


% --- Executes during object creation, after setting all properties.
function refch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function refch_Callback(hObject, eventdata, handles)
% hObject    handle to refch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of refch as text
%        str2double(get(hObject,'String')) returns contents of refch as a double


% --- Executes during object creation, after setting all properties.
function fromhz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fromhz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fromhz_Callback(hObject, eventdata, handles)
% hObject    handle to fromhz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fromhz as text
%        str2double(get(hObject,'String')) returns contents of fromhz as a double
guidata(hObject,handles);
if get(handles.popupmenu1,'value')==1
    showwavelet(hObject)
end
% --- Executes during object creation, after setting all properties.
function tohz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tohz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tohz_Callback(hObject, eventdata, handles)
% hObject    handle to tohz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tohz as text
%        str2double(get(hObject,'String')) returns contents of tohz as a double
guidata(hObject,handles);
if get(handles.popupmenu1,'value')==1
    showwavelet(hObject)
end

% --- Executes during object creation, after setting all properties.
function dhz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dhz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dhz_Callback(hObject, eventdata, handles)
% hObject    handle to dhz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dhz as text
%        str2double(get(hObject,'String')) returns contents of dhz as a double


% --- Executes during object creation, after setting all properties.
function fromms_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fromms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fromms_Callback(hObject, eventdata, handles)
% hObject    handle to fromms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fromms as text
%        str2double(get(hObject,'String')) returns contents of fromms as a double


% --- Executes during object creation, after setting all properties.
function toms_CreateFcn(hObject, eventdata, handles)
% hObject    handle to toms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function toms_Callback(hObject, eventdata, handles)
% hObject    handle to toms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of toms as text
%        str2double(get(hObject,'String')) returns contents of toms as a double


% --- Executes during object creation, after setting all properties.
function dms_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function dms_Callback(hObject, eventdata, handles)
% hObject    handle to dms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dms as text
%        str2double(get(hObject,'String')) returns contents of dms as a double
global EEG;
set(handles.timms,'String',['d_ms: ' num2str(str2num(get(handles.dms,'String'))/EEG.srate*1000) ' ms']);
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
s=get(handles.popupmenu1,'value');
axes(handles.axes3)
cla;
text('Position',[0 0],'Interpreter','tex','String','Bandwidth \sigma =');
axis off;
if s==1
    set(handles.fb,'string','0.05');
else
    set(handles.fb,'string','1');
end

guidata(hObject,handles);
showwavelet(hObject);

% --- Executes during object creation, after setting all properties.
function fc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fc_Callback(hObject, eventdata, handles)
% hObject    handle to fc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fc as text
%        str2double(get(hObject,'String')) returns contents of fc as a double
showwavelet(hObject);

% --- Executes during object creation, after setting all properties.
function fb_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fb_Callback(hObject, eventdata, handles)
% hObject    handle to fb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fb as text
%        str2double(get(hObject,'String')) returns contents of fb as a double
showwavelet(hObject);

% --- Executes during object creation, after setting all properties.
function filetext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filetext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function filetext_Callback(hObject, eventdata, handles)
% hObject    handle to filetext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filetext as text
%        str2double(get(hObject,'String')) returns contents of filetext as a double


% --- Executes on button press in createbut.
function createbut_Callback(hObject, eventdata, handles)
% hObject    handle to createbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global EEG;
savefile=get(handles.filetext,'String');
f1=str2num(get(handles.fromhz,'String'));
f2=str2num(get(handles.tohz,'String'));
nfr=str2num(get(handles.dhz,'String'));
Fa=[f1,f2,nfr];
t1=get(handles.fromms,'Value');
t2=get(handles.toms,'Value');
ndt=str2num(get(handles.dms,'String'));
fb=str2num(get(handles.fb,'String'));
res=readbuts(hObject);
chantoanal=str2num(get(handles.chantoanal,'String'));
if get(handles.createall,'value')
    normmeth=[];
else
    if get(handles.normalizationmeth,'value')==2
        bt1=t1;
        bt2=t2;
        a.tim=EEG.times(bt1:ndt:bt2);
        a.txt='Define background region';
        H=defbackground(a);
        uiwait(H);
        handlesd=guidata(H);
        bt1=handlesd.s1;
        bt2=handlesd.s2;
        close('defbackground')
        normmeth=[bt1,bt2];
    else
        normmeth=0;
    end

end
files=CreateitEEG(savefile,handles.wname,fb, Fa, t1,t2,ndt,chantoanal,res,normmeth,get(handles.lfrax,'value'));
k=length(savefile);
while ~(savefile(k)=='/' | savefile(k)=='\')
    k=k-1;
end
for t=1:length(files)
    handles.pathnames{t}=files{t}(1:k);
    handles.filenames{t}=files{t}(k+1:end);
end
guidata(hObject,handles);
uiresume(gcf)


% --- Executes during object creation, after setting all properties.
function eventch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function eventch_Callback(hObject, eventdata, handles)
% hObject    handle to eventch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eventch as text
%        str2double(get(hObject,'String')) returns contents of eventch as a double


% --- Executes during object creation, after setting all properties.
function chantoanal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chantoanal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function chantoanal_Callback(hObject, eventdata, handles)
% hObject    handle to chantoanal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chantoanal as text
%        str2double(get(hObject,'String')) returns contents of chantoanal as a double


% --- Executes on button press in createall.
function createall_Callback(hObject, eventdata, handles)
% hObject    handle to createall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of createall
set(handles.createall,'value',1);
set(handles.itpc,'value',0);
set(handles.itlc,'value',0);
set(handles.ersp,'value',0);
set(handles.avwt,'value',0);
set(handles.wtav,'value',0);
set(handles.induced,'value',0);
set(handles.normalizationmeth,'visible','off');

% --- Executes on button press in itpc.
function itpc_Callback(hObject, eventdata, handles)
% hObject    handle to itpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of itpc
if ~(get(handles.itpc,'value'))
    set(handles.itpc,'value',0);
else
    set(handles.createall,'value',0);
    set(handles.itpc,'value',1);
end

% --- Executes on button press in avwt.
function avwt_Callback(hObject, eventdata, handles)
% hObject    handle to avwt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of avwt
if ~(get(handles.avwt,'value'))
    set(handles.avwt,'value',0);
else
    set(handles.createall,'value',0);
    set(handles.avwt,'value',1);
    set(handles.normalizationmeth,'Visible','On');
end

% --- Executes on button press in ersp.
function ersp_Callback(hObject, eventdata, handles)
% hObject    handle to ersp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ersp
if ~(get(handles.ersp,'value'))
    set(handles.ersp,'value',0);
else
    set(handles.createall,'value',0);
    set(handles.ersp,'value',1);
    set(handles.normalizationmeth,'Visible','On');
end

% --- Executes on button press in wtav.
function wtav_Callback(hObject, eventdata, handles)
% hObject    handle to wtav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of wtav

if ~(get(handles.wtav,'value'))
    set(handles.wtav,'value',0);
else
    set(handles.createall,'value',0);
    set(handles.wtav,'value',1);
    set(handles.normalizationmeth,'Visible','On');
end

% --- Executes on button press in induced.
function induced_Callback(hObject, eventdata, handles)
% hObject    handle to induced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of induced

if ~(get(handles.induced,'value'))
    set(handles.induced,'value',0);
else
    set(handles.createall,'value',0);
    set(handles.induced,'value',1);
    set(handles.normalizationmeth,'Visible','On');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res=readbuts(hObject)
handles=guidata(hObject);
if get(handles.createall,'value')
    res=[];
else
    res=zeros(6,1);
    if get(handles.itpc,'value')
        res(1)=1;
    end
    if get(handles.itlc,'value')
        res(2)=1;
    end
    if get(handles.ersp,'value')
        res(3)=1;
    end
    if get(handles.avwt,'value')
        res(4)=1;
    end
    if get(handles.wtav,'value')
        res(5)=1;
    end
    if get(handles.induced,'value')
        res(6)=1;
    end
end



function r_Callback(hObject, eventdata, handles)
% hObject    handle to r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of r as text
%        str2double(get(hObject,'String')) returns contents of r as a double
showwavelet(hObject);


% --- Executes during object creation, after setting all properties.
function r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showwavelet(hObject)
global EEG;
handles=guidata(hObject);
s=get(handles.popupmenu1,'value');
ss=get(handles.popupmenu1,'String');
fb=str2num(get(handles.fb,'String'));
FF(1)=str2num(get(handles.fromhz,'String'));
FF(2)=str2num(get(handles.tohz,'String'));
axes(handles.plotwavelet);
handles.wname=ss{s};
Fs=EEG.srate;
if Fs==1
    Fs=1000;
end
plotwavelet(handles.wname,fb,Fs,FF);
guidata(hObject,handles);






% --- Executes on selection change in normalizationmeth.
function normalizationmeth_Callback(hObject, eventdata, handles)
% hObject    handle to normalizationmeth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns normalizationmeth contents as cell array
%        contents{get(hObject,'Value')} returns selected item from normalizationmeth


% --- Executes during object creation, after setting all properties.
function normalizationmeth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to normalizationmeth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in lfrax.
function lfrax_Callback(hObject, eventdata, handles)
% hObject    handle to lfrax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lfrax




% --- Executes on button press in itlc.
function itlc_Callback(hObject, eventdata, handles)
% hObject    handle to itlc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of itlc
if ~(get(handles.itlc,'value'))
    set(handles.itlc,'value',0);
else
    set(handles.createall,'value',0);
    set(handles.itlc,'value',1);
    set(handles.normalizationmeth,'Visible','On');
end

