function varargout = designmatrix(varargin)
% Graphical user interface to perform group analysis using ANOVA/KW
%
% Written by Morten Mørup
%
% DESIGNMATRIX M-file for designmatrix.fig
%      DESIGNMATRIX, by itself, creates a new DESIGNMATRIX or raises the existing
%      singleton*.
%
%      H = DESIGNMATRIX returns the handle to a new DESIGNMATRIX or the handle to
%      the existing singleton*.
%
%      DESIGNMATRIX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DESIGNMATRIX.M with the given input arguments.
%
%      DESIGNMATRIX('Property','Value',...) creates a new DESIGNMATRIX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before designmatrix_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to designmatrix_OpeningFcn via varargin.
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

% Edit the above text to modify the response to help designmatrix

% Last Modified by GUIDE v2.5 15-Aug-2006 12:38:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @designmatrix_OpeningFcn, ...
                   'gui_OutputFcn',  @designmatrix_OutputFcn, ...
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


% --- Executes just before designmatrix is made visible.
function designmatrix_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to designmatrix (see VARARGIN)

% Choose default command line output for designmatrix
handles.output = hObject;
if exist('varargin{1}.groupclass','var')
    handles.groupclass=varargin.groupclass;
else
    handles.groupclass=zeros(length(varargin{1}.files),1);
end

ftext=displayit(varargin{1}.files,handles.groupclass);
set(handles.Filelist,'string',ftext);
set(handles.g1,'visible','off')
set(handles.g2,'visible','off')
set(handles.g3,'visible','off')
set(handles.g4,'visible','off')
set(handles.g5,'visible','off')
set(handles.g6,'visible','off')
set(handles.g7,'visible','off')
set(handles.g8,'visible','off')
set(handles.g9,'visible','off')
set(handles.g10,'visible','off')
handles.files=varargin{1}.files;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes designmatrix wait for user response (see UIRESUME)
% uiwait(handles.designmatrix);


% --- Outputs from this function are returned to the command line.
function varargout = designmatrix_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Filelist.
function Filelist_Callback(hObject, eventdata, handles)
% hObject    handle to Filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns Filelist contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Filelist


% --- Executes during object creation, after setting all properties.
function Filelist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Filelist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NOG_Callback(hObject, eventdata, handles)
% hObject    handle to NOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NOG as text
%        str2double(get(hObject,'String')) returns contents of NOG as a double
nog=str2num(get(handles.NOG,'String'));
for k=1:10
    if k==1
        if k<=nog
            set([handles.g1],'visible','on');
        else
            set([handles.g1],'visible','off');
        end
    end
    if k==2
        if k<=nog
            set([handles.g2],'visible','on');
        else
            set([handles.g2],'visible','off');
        end
    end
    if k==3
        if k<=nog
            set([handles.g3],'visible','on');
        else
            set([handles.g3],'visible','off');
        end
    end
    if k==4
        if k<=nog
            set([handles.g4],'visible','on');
        else
            set([handles.g4],'visible','off');
        end
    end
    if k==5
        if k<=nog
            set([handles.g5],'visible','on');
        else
            set([handles.g5],'visible','off');
        end
    end
    if k==6
        if k<=nog
            set([handles.g6],'visible','on');
        else
            set([handles.g6],'visible','off');
        end
    end
    if k==7
        if k<=nog
            set([handles.g7],'visible','on');
        else
            set([handles.g7],'visible','off');
        end
    end
    if k==8
        if k<=nog
            set([handles.g8],'visible','on');
        else
            set([handles.g8],'visible','off');
        end
    end
    if k==9
        if k<=nog
            set([handles.g9],'visible','on');
        else
            set([handles.g9],'visible','off');
        end
    end
    if k==10
        if k<=nog
            set([handles.g10],'visible','on');
        else
            set([handles.g10],'visible','off');
        end
    end
    
end

% --- Executes during object creation, after setting all properties.
function NOG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NOG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in g1.
function g1_Callback(hObject, eventdata, handles)
% hObject    handle to g1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.Filelist,'value');
handles.groupclass(nr)=1;
if length(handles.files)>nr
    set(handles.Filelist,'value',nr+1);
end
guidata(hObject,handles);
ftext=displayit(handles.files,handles.groupclass);
set(handles.Filelist,'String',ftext);

% --- Executes on button press in g2.
function g2_Callback(hObject, eventdata, handles)
% hObject    handle to g2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.Filelist,'value');
handles.groupclass(nr)=2;
if length(handles.files)>nr
    set(handles.Filelist,'value',nr+1);
end
guidata(hObject,handles);
ftext=displayit(handles.files,handles.groupclass);
set(handles.Filelist,'String',ftext);


% --- Executes on button press in g3.
function g3_Callback(hObject, eventdata, handles)
% hObject    handle to g3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.Filelist,'value');
handles.groupclass(nr)=3;
if length(handles.files)>nr
    set(handles.Filelist,'value',nr+1);
end
guidata(hObject,handles);
ftext=displayit(handles.files,handles.groupclass);
set(handles.Filelist,'String',ftext);


% --- Executes on button press in g4.
function g4_Callback(hObject, eventdata, handles)
% hObject    handle to g4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.Filelist,'value');
handles.groupclass(nr)=4;
if length(handles.files)>nr
    set(handles.Filelist,'value',nr+1);
end
guidata(hObject,handles);
ftext=displayit(handles.files,handles.groupclass);
set(handles.Filelist,'String',ftext);


% --- Executes on button press in g5.
function g5_Callback(hObject, eventdata, handles)
% hObject    handle to g5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.Filelist,'value');
handles.groupclass(nr)=5;
if length(handles.files)>nr
    set(handles.Filelist,'value',nr+1);
end
guidata(hObject,handles);
ftext=displayit(handles.files,handles.groupclass);
set(handles.Filelist,'String',ftext);


% --- Executes on button press in g6.
function g6_Callback(hObject, eventdata, handles)
% hObject    handle to g6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.Filelist,'value');
handles.groupclass(nr)=6;
if length(handles.files)>nr
    set(handles.Filelist,'value',nr+1);
end
guidata(hObject,handles);
ftext=displayit(handles.files,handles.groupclass);
set(handles.Filelist,'String',ftext);


% --- Executes on button press in g7.
function g7_Callback(hObject, eventdata, handles)
% hObject    handle to g7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.Filelist,'value');
handles.groupclass(nr)=7;
if length(handles.files)>nr
    set(handles.Filelist,'value',nr+1);
end
guidata(hObject,handles);
ftext=displayit(handles.files,handles.groupclass);
set(handles.Filelist,'String',ftext);


% --- Executes on button press in g8.
function g8_Callback(hObject, eventdata, handles)
% hObject    handle to g8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.Filelist,'value');
handles.groupclass(nr)=8;
if length(handles.files)>nr
    set(handles.Filelist,'value',nr+1);
end
guidata(hObject,handles);
ftext=displayit(handles.files,handles.groupclass);
set(handles.Filelist,'String',ftext);


% --- Executes on button press in g9.
function g9_Callback(hObject, eventdata, handles)
% hObject    handle to g9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.Filelist,'value');
handles.groupclass(nr)=9;
if length(handles.files)>nr
    set(handles.Filelist,'value',nr+1);
end
guidata(hObject,handles);
ftext=displayit(handles.files,handles.groupclass);
set(handles.Filelist,'String',ftext);


% --- Executes on button press in g10.
function g10_Callback(hObject, eventdata, handles)
% hObject    handle to g10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.Filelist,'value');
handles.groupclass(nr)=10;
if length(handles.files)>nr
    set(handles.Filelist,'value',nr+1);
end
guidata(hObject,handles);
ftext=displayit(handles.files,handles.groupclass);
set(handles.Filelist,'String',ftext);


function ftext=displayit(files,groupclass)
for k=1:length(files)
    if groupclass(k)~=0
        ftext{k}=[num2str(groupclass(k)) ' - ' files{k}];
    else
        ftext{k}=files{k};
    end
end

% --- Executes on button press in done.
function done_Callback(hObject, eventdata, handles)
% hObject    handle to done (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=sort(handles.groupclass);
L=unique(handles.groupclass);
Q=length(handles.groupclass)/length(L);
if get(handles.ANOVA,'value')
    handles.testtype='ANOVA';
else
    handles.testtype='KW';
end

LL=a(end:-Q:1);
if length(L)~=length(LL)
    set(handles.errortext,'String','Not the same number of files assigned to each group')
elseif length(handles.groupclass)==length(handles.files) & length(find(handles.groupclass==0))==0
    guidata(hObject,handles);
    uiresume(gcf)
else
    set(handles.errortext,'String','One or more files have not been assigned a group')
end



% --- Executes on button press in ANOVA.
function ANOVA_Callback(hObject, eventdata, handles)
% hObject    handle to ANOVA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ANOVA
set(handles.KW,'value',0);
set(handles.ANOVA,'value',1);


% --- Executes on button press in KW.
function KW_Callback(hObject, eventdata, handles)
% hObject    handle to KW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KW
set(handles.KW,'value',1);
set(handles.ANOVA,'value',0);

