function varargout = ERPWAVELAB(varargin)
% ERPWAVELAB version 1.1 December 2006
%
% ERPWAVELAB is developed by Morten Mørup, 
% contact: erpwavelab@erpwavelab.org
%
% To run ERPWAVELAB type ERPWAVELAB in the matlab prompth
% 
% ERPWAVELAB requires that EEGLAB is installed. EEGLAB is free to download
% from: http://www.sccn.ucsd.edu/eeglab/
% A tutorial of ERPWAVELAB can be found at www.erpwavelab.com/tutorial/
% This is the main GUI file operating with ERPWAVELAB.fig
%
% Written by Morten Mørup
%
% Variable structures
% The ERPWAVELAB dataset is stored as .mat files containing the following
% entities:
%   WT          Channel x frequence x time x epoch Array of wavelet coefficients 
%   Fa          Frequency range in Hz
%   Fs          Sampling rate of original EEG file
%   tim         Time range in ms.
%   wavetyp     Type of wavelet used 'Cmor2-1' means bandwidth parameter is 2
%   nepoch      number of epochs used to generate the file
%   chanlocs    The location of each channel
%  
%   file endname denotes what type of file it is:
%   No extensions       WT is full array of Channel x Frequency x Time x Epoch
%   -ITPC               WT is given as sum(WT./abs(WT),4))
%   -ERSP               WT is given as sum(WT.*conj(WT),4))
%   -avWT               WT is given as sum(abs(WT),4)
%   -WTav               WT is given as sum(WT,4)
%
% ERPWAVELAB version 1.0
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

% Revisions:
% 15 September 2006 fixed rcc_callback such that cross coherence could be
%                   recorded within same time-frequency instances.
%
% 9 October 2006    Edited nmf2but_callback and parafacbut_callback such that saving decomposition results
%                   generates Excel file.
%
% 27 October 2006   Rayleigh distribution enabled for specific ITPC/ITLC
%                   measures.
%
% 6 November 2006   function rejectERPCOHphase added such that phase of ERPCOH can be tested for 0 and 180 degrees 
%                   Using Von Mises statistics.
%
% 7 November 2006   Significance of ITPC and ERPCOH not given as contours
%                   but activity not significant instead set to zero. 
%
% 9 November 2006   Bug fixed when selecting channel from popup-menu.
%
% 15 November 2006  function getCoef defined to extract value at current
%                   inspected point, function rcc redefined to also include ERPCOH phase
%                   statistics. Topmontage set to plot statistical
%                   significant region. Some of the commands in 
%                   loadit(hObject) moved to new function updateGuiforDataset(hObject) 
%
% 29 November 2006  Post normalization enabled for ITPC and ERPCOH, ERPCOH
%                   for specific time or frequency enabled 
%
% 7 December 2006   Plot function for measures at a given channel, bug when
%                   removing channel fixed
%
% 19 December 2006  ERPWAVELAB can be called with files to open, vonMisses
%                   statistics only for coherence of same time-frequency instances.
%
% 1 February 2007   Bug in Ch x Fr-time-subj decomposition fixed, user
%                   interface corrected for measures selected
% 25 Juni 2014      Updated gabortf and fastwavelet to be consistent in
%                   phase definition between performing transform in
%                   time domain (dt>3) and frequency domain (dt<=3).

warning('off','MATLAB:dispatcher:InexactMatch');
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ERPWAVELAB_OpeningFcn, ...
                   'gui_OutputFcn',  @ERPWAVELAB_OutputFcn, ...
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


% --- Executes just before ERPWAVELAB is made visible.
function ERPWAVELAB_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ERPWAVELAB (see VARARGIN)

% Choose default command line output for ERPWAVELAB
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Set the path to all subfolders
ERPWAVEpath = which('ERPWAVELAB.m');
ERPWAVEpath=ERPWAVEpath(1:end-length('ERPWAVELAB.m'));
addpath(ERPWAVEpath);
addpath([ERPWAVEpath 'Tools']);
addpath([ERPWAVEpath 'Tools' ERPWAVEpath(end) 'nmwf']);
addpath([ERPWAVEpath 'Tools' ERPWAVEpath(end) 'honmf']);
addpath([ERPWAVEpath 'Tools' ERPWAVEpath(end) 'plotfcns']);
addpath([ERPWAVEpath 'Splines']);
addpath([ERPWAVEpath 'Dialog']);
addpath([ERPWAVEpath 'Files']);


% Set GUI to default settings

setguiasopening(hObject);
if ~isempty(varargin)
    opts=varargin{1};
    handles=guidata(hObject);
    handles.pathnamelist(end+1:end+length(opts.pathnames))=opts.pathnames;
    handles.filenamelist(end+1:end+length(opts.pathnames))=opts.filenames;
    if isfield(handles,'rec')
        handles.rec(end+1:end+length(opts.pathnames))=cell(length(opts.pathnames),1);
    else
        handles.rec=cell(length(opts.pathnames),1);
    end
    set(handles.files,'String',handles.filenamelist);
    set(handles.files,'Value',length(handles.filenamelist));
    guidata(hObject,handles);
    files_Callback(hObject, eventdata, handles)
end

% UIWAIT makes ERPWAVELAB wait for user response (see UIRESUME)
% uiwait(handles.ERPWAVELAB);


% --- Outputs from this function are returned to the command line.
function varargout = ERPWAVELAB_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function setguiasopening(hObject);
handles = guidata(hObject);
if ~isfield(handles,'filenamelist')
    handles.filenamelist={};        % list of name of files
end
if ~isfield(handles,'pathnamelist')
    handles.pathnamelist={};        % list of path to files
end
if ~isfield(handles,'plotsithist')
    handles.plotsithist={};         % Track what cross coherences have been stored
end

if length(handles.filenamelist)==0
    set(handles.angleplot,'visible','off');
    set(handles.cch,'Visible','off');
    set(handles.cfr,'Visible','off');
    set(handles.ctm,'Visible','off');
    set(handles.chepoch,'Visible','off');
    set(handles.erpcohpt,'Visible','off');
    set(handles.ch2pop,'Visible','off');
    set(handles.itpcbut,'Value',1);
    handles.measure='ITPC';         % Define what is currently the measure used
    handles.splnfile=[];            % Variable defining path to splnfile
    axes(handles.Montageplot)
    axis off;
    axes(handles.Topoplot)
    axis off;
    axes(handles.Headplot)
    axis off;
    set(handles.fastfile,'enable','off');
    set(handles.savecurrROI,'enable','off');
    set(handles.options,'enable','off');
    set(handles.tools,'enable','off');
    set(handles.normalization,'enable','off');
    ss=get(handles.phasecoh,'checked');
    ss2=get(handles.lincoh,'checked');
    ss3=get(handles.ampcorr,'checked');
    if ss(2)=='n'
        handles.cohtype=1;
    elseif ss2(2)=='n'
        handles.cohtype=2;
    else
         handles.cohtype=3;
    end
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function ch_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function ch_Callback(hObject, eventdata, handles)
% hObject    handle to ch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ch as text
%        str2double(get(hObject,'String')) returns contents of ch as a double

guidata(hObject,handles);
if get(handles.mfsch,'value') | get(handles.epochbut,'value');
    Plotmontage(hObject,10)
end
Topheadplot(hObject);


% --- Executes during object creation, after setting all properties.
function tm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tm_Callback(hObject, eventdata, handles)
% hObject    handle to tm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tm as text
%        str2double(get(hObject,'String')) returns contents of tm as a double
handles.plotsit(3)=str2num(get(handles.tm,'String'));
if handles.plotsit(3)<handles.tim(1)
    handles.plotsit(3)=handles.tim(1);
    set(handles.tm,'String',num2str(handles.plotsit(3)));
end
if handles.plotsit(3)>handles.tim(end)
    handles.plotsit(3)=handles.tim(end);
    set(handles.tm,'String',num2str(handles.plotsit(3)));
end
handles.plotsithist{end+1}=handles.plotsit;
guidata(hObject,handles);
Topheadplot(hObject);


% --- Executes during object creation, after setting all properties.
function fr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fr_Callback(hObject, eventdata, handles)
% hObject    handle to fr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fr as text
%        str2double(get(hObject,'String')) returns contents of fr as a double
handles.plotsit(2)=str2num(get(handles.fr,'String'));
if handles.plotsit(2)<handles.Fa(1)
    handles.plotsit(2)=handles.Fa(1);
elseif handles.plotsit(2)>handles.Fa(end)
    handles.plotsit(2)=handles.Fa(end);
else
    handles.plotsit(2)=handles.Fa(m2mp(handles.Fa,handles.plotsit(2)));
end
set(handles.fr,'String',num2str(handles.plotsit(2)));
handles.plotsithist{end+1}=handles.plotsit;
guidata(hObject,handles);
Topheadplot(hObject);


% --- Executes during object creation, after setting all properties.
function noc_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function noc_Callback(hObject, eventdata, handles)
% hObject    handle to noc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noc as text
%        str2double(get(hObject,'String')) returns contents of noc as a double


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function LoadF_Callback(hObject, eventdata, handles)
% hObject    handle to LoadF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.*', 'File to load');
if ~filename==0
    if exist([pathname filename],'file')
         handles.pathname=pathname;             % path of current file
         handles.filename=filename;             % name of current file
         handles.filenamelist{end+1}=filename;  % name of all files
         handles.pathnamelist{end+1}=pathname;  % path of all files
        % Update GUI
         set(handles.files,'String',handles.filenamelist);
         set(handles.files,'Value', length(handles.filenamelist));

         handles.rec{length(handles.filenamelist)}={};
         guidata(hObject,handles);
         loadit(hObject);
         CalculateYh(hObject);
    end
end
 


% --------------------------------------------------------------------
function Create_Callback(hObject, eventdata, handles)
% hObject    handle to Create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function CalculateYh(hObject)
% Internal function assisting in calculating the current measure
% Outputs handles.Y containing the current measure as well as
% handles.nrepoch giving how many epochs were used to generate the measure

handles=guidata(hObject);
% initialize variables
Y=0;
Y1=0;
Y2=0;
N1=0;
N2=0;
handles.nrepoch=0;

% Check if subtract ITPC background is active
if get(handles.erpcohbut,'value') & get(handles.sITPC,'value')
    sITPCact=0;
end
if get(handles.useall,'Value')==1 % Check if grand average is to be calculated
    for k=1:length(handles.filenamelist) % Load and calculate measure of each dataset
        handles.filename=handles.filenamelist{k};
        handles.pathname=handles.pathnamelist{k};
        disp(['Processing: ' handles.filename]);
        guidata(hObject,handles);
        loadit(hObject);
        handles=guidata(hObject);
        handles.nrepoch=handles.nrepoch+handles.nepoch;
        guidata(hObject,handles);        
        CalculateY(hObject);
        handles=guidata(hObject);
        
        if ~isempty(handles.N1) % Check if linear coherence was used in measure
            N1=N1+handles.N1;
            N2=N2+handles.N2;
            Y=Y+handles.Y;
        else % Multiply by handles.nepoch to weight grand average by number of epochs present
            Y=Y+handles.nepoch*handles.Y;
        end
        % enable subtraction of ITPC activity for ERPCOH
        if get(handles.erpcohbut,'value') & get(handles.sITPC,'value')
            sITPCact=sITPCact+mean(handles.WT./abs(handles.WT),4);    
        end        
    end
    % Normalize by total amount of epochs
    handles.Y=Y/handles.nrepoch;
    % Subtract ITPC activity for ERPCOH
    if get(handles.erpcohbut,'value') & get(handles.sITPC,'value')
       sITPCact=sITPCact/length(handles.filenamelist);
       handles.Y=abs(handles.Y)-abs(sITPCact);
       handles.Y(handles.Y<0)=0;
    elseif get(handles.erpcohbut,'value') & handles.cohtype==2  % Correct for linear coherence
        handles.Y=handles.nrepoch*handles.Y./(sqrt(handles.N1).*sqrt(handles.N2));
    elseif get(handles.itpcbut,'value') & handles.cohtype==2    % Correct for linear coherence
        handles.Y=handles.nrepoch*handles.Y./sqrt(handles.nrepoch*handles.N1);
    end
    clear Y;
else
    CalculateY(hObject);
    handles=guidata(hObject);
    handles.nrepoch=handles.nepoch;
    % Subtract ITPC activity from ERPCOH
    if get(handles.erpcohbut,'value') & get(handles.sITPC,'value')
          sITPCact=mean(handles.WT./abs(handles.WT),4);    
          handles.Y=abs(handles.Y)-abs(sITPCact);
          handles.Y(handles.Y<0)=0;
    elseif get(handles.erpcohbut,'value') & handles.cohtype==2 % Correct for linear coherence
        handles.Y=handles.Y./(sqrt(handles.N1).*sqrt(handles.N2));
    elseif get(handles.itpcbut,'value') & handles.cohtype==2   % Correct for linear coherence
        handles.Y=handles.Y./sqrt(handles.nepoch*handles.N1);
    end
end
guidata(hObject,handles);
% post normalize data
postnormalize(hObject);
% Calculate confidence if this is selected
if get(handles.confbut,'value')
    calconf(hObject);
end
% Update topographic map and Montageplot
channels_Callback(hObject, 1, handles)




% --------------------------------------------------------------------
function CalculateY(hObject)
% Internal function assisting in calculating the current measure. Updates
% the structure handles.Y and if linear coherence selected also handles.N1
% and handles.N2.

handles=guidata(hObject);
ss=getmeasure(hObject);
if get(handles.epochbut,'Value')
    handles.Y=calepochmeas(handles,get(handles.ch2pop,'Value'));
else
    cop=getCohInfo(handles);
    [handles.Y, handles.N1, handles.N2]=calcmeasure(handles.WT,ss,cop);
end
guidata(hObject,handles);



% --------------------------------------------------------------------
function Plotmontage(hObject,nr)
% Internal function updating the Montageplot in the GUI

% if nr~=0 the montageplot is given in a separate figure
% if nr=10 no topographic montageplot is given
if nargin<2
    nr=0;
end

% Extract ROI in hObject (handles.Fa_c and handles.tim_c)
setTimFa(hObject)
handles=guidata(hObject);
% Get region of interest (ROI)
tp1=m2mp(handles.tim,str2num(get(handles.fromt,'String')));
tp2=m2mp(handles.tim,str2num(get(handles.tot,'String')));
fp1=m2mp(handles.Fa,str2num(get(handles.fromf,'String')));
fp2=m2mp(handles.Fa,str2num(get(handles.tof,'String')));

ss=get(handles.rejectERPCOHphase,'Checked');
ss2=get(handles.rejectERPCOHphase,'enable');
% Check for plotting mode
if get(handles.anovabut,'value') % Test of diff.
    handles.X=handles.Y;
elseif  get(handles.erpcohbut,'value') & ss(2)=='n' & ss2(2)=='n' ~get(handles.sfase,'value') & handles.cohtype~=3
    % Check ERPCOH for 0 and 180 degrees if selected
    if get(handles.dstrmax,'value')
        ncomp=prod(nr_points_disp(hObject));
    else
        ncomp=1;
    end
    handles.Y(handles.Y>1)=1; % Correct linear coherence for impressions such that it can not be larger than 1
    handles.X=abs(vonMises(handles.Y,handles.nrepoch,str2num(get(handles.slevel,'String')),ncomp));
else
    if get(handles.sfase,'value')   % Show phase
        handles.X=imag(log(handles.Y));
    else    % Display regular measure
        if handles.cohtype==3 & get(handles.erpcohbut,'value')  % measure is AmpCorr
            handles.X=handles.Y;
        else
            handles.X=abs(handles.Y);
        end
    end
end


% Create significance regions in plot if 'confidence' is selected.
TU=[]; % Montageplot image of upper significant regions
TL=[]; % Montageplot image of lower significant regions
if get(handles.confbut,'value') & ~get(handles.sfase,'value') & ~get(handles.epochbut,'value')
  ss=get(handles.nbcka,'checked');
  % Correct significance for background activity normalization if selected
  if ss(2)=='n'
      QnU=handles.QnU./handles.pnormfact;
      QnL=handles.QnL./handles.pnormfact;
  else
      QnU=handles.QnU;
      QnL=handles.QnL;
  end
  % One tailed significance analysis for ITPC and ERPCOH,
  if get(handles.itpcbut,'value') | get(handles.erpcohbut,'value') & handles.cohtype~=3
      TU=handles.X-repmat(QnU,[1,1,size(handles.X,3)]);
      if ss(2)=='n'
          handles.X(TU<0)=1;
      else
          handles.X(TU<0)=0;
      end
      TU=[];
      if ~(get(handles.erpcohbut,'value') & get(handles.sITPC,'value')) 
          set(handles.sleveltxt,'visible','on');
          if get(handles.laxis,'value')
               set(handles.sleveltxt,'String',['Cut off:' num2str(log(QnU(1))) ]); 
          else
              set(handles.sleveltxt,'String',['Cut off:' num2str(QnU(1)) ]); 
          end
      else
          set(handles.sleveltxt,'visible','off');
      end
  else
   % two tailed analysis for other measures
    TU=handles.X-repmat(QnU,[1,1,size(handles.X,3)]);
    TL=handles.X-repmat(QnL,[1,1,size(handles.X,3)]);
    if ss(2)=='n'
        I=find(TU<0 & TL>0);
        handles.X(I)=1;
        TU=[];
        TL=[];
    end
  end
end
X=handles.X(handles.act_chan_ind,fp1:fp2,tp1:tp2);

% Log transform if log axis is selected
if get(handles.laxis,'value')
    X=log2(X+eps);
end

% Display colorregion correctly
handles.minmax=[min(X(:)) max(X(:))];
c1=get(handles.cmin,'string');
if isempty(c1) | get(handles.a2lim,'Value')
    if get(handles.a2lim,'Value')
         c1=num2str(handles.minmax(1));
         set(handles.cmin,'String',c1);
    else
        set(handles.cmin,'String','0');
        c1='0';
    end
end
c2=get(handles.cmax,'String');
if isempty(c2) | get(handles.a2lim,'Value')
    c2=num2str(handles.minmax(2));
    set(handles.cmax,'String',c2);
end
if str2num(c2)<=str2num(c1) % Invalid axis definition
   c2=num2str(str2num(c1)+0.01);
   set(handles.cmax,'String',c2);
end
% Define the final axis
ax=[str2num(c1) str2num(c2)];

    
% Extract number of rows and columns in Montageplot
y1=str2num(get(handles.rows,'String'));
y2=str2num(get(handles.columns,'String'));

% Create separate figure if necessary
if nr==1
     figure;
else
    axes(handles.Montageplot);
end
% Use correct colormap
if get(handles.sfase,'value')
    colormap('hsv');
else
    colormap('jet');
end


if get(handles.mfsch,'value') % Montageplot is to be started from selected channel
    H=montageplot(X,handles.chanlocs(handles.act_chan_ind),y1,y2,get(handles.ch,'Value'),TU,TL);
else
    H=montageplot(X,handles.chanlocs(handles.act_chan_ind),y1,y2,1,TU,TL);
end
% Enable to inspect channel-frequency-time regions in the Montageplot
set(H,'ButtonDownFcn',{@Montageplot_mousepress,hObject});
% Set the coloraxis
caxis(ax);
axis off;
if get(handles.clb,'Value')==1
    colorbar;
end

% Check if Topographic montage is to be displayed
if get(handles.inctopmont,'value') & nr~=10
    tw=str2num(get(handles.tw,'String'));
    th=str2num(get(handles.th,'String'));
    topmontageplot(X,handles.chanlocs(handles.act_chan_ind),tw,th,ax,handles.tim(tp1:tp2),handles.Fa(fp1:fp2),TU,TL);
    if get(handles.sfase,'value')
        colormap('hsv');
    else
        colormap('jet');
    end
end
guidata(hObject,handles);


% --------------------------------------------------------------------
function Topheadplot(hObject)
% Internal function to update topographic plots and value of current
% measure
handles=guidata(hObject);

% Get the location of the current inspected point
f=m2mp(handles.Fa, str2num(get(handles.fr,'String')));
t=m2mp(handles.tim, str2num(get(handles.tm,'String')));
ch=get(handles.ch,'Value');
ch=handles.act_chan_ind(ch);

% Update value of the current measure
Y=handles.Y(ch,f,t);

% Update phase plot of current measure if this is complex
if imag(Y)~=0
    set(handles.val,'String',num2str(abs(Y)));
    set(handles.angleplot,'visible','on');
    axes(handles.angleplot);
    cla;
    r=linspace(0,2*pi,1000);
    a=exp(i*r);
    hold on;
    axis equal;
    axis off;
    plot(real(a),imag(a),'k-');
    plot(real(Y./abs(Y)),imag(Y./abs(Y)),'.');
    plot([0, real(Y./abs(Y))],[0 imag(Y./abs(Y))],'-','linewidth',2);
    plot([-1.2 1.2],[0 0],'k-');
    plot([0 0],[-1.2 1.2],'k-');
else
    set(handles.val,'String',num2str(Y));
    axes(handles.angleplot);
    cla;
    axis off;
end

% Extract values to be displayed in topographic plot
axes(handles.Topoplot);
if get(handles.epochbut,'Value'); % Epoch mode
    Y=abs(calepochmeaschannel(handles,f,t,get(handles.ch,'value')));
    chanl=handles.chanlocs;
    handles.chanlocs=handles.chanlocsold;
    actchanind=handles.act_chan_ind;
    handles.act_chan_ind=1:length(handles.chanlocs);
else  % regular mode
    Y=squeeze(handles.X(:,f,t));
end
% Log transform if necessary
if get(handles.laxis,'Value')
    Y=log(Y+eps);
end

% Update topographic plot
if ~isempty(get(handles.cmin,'String')) & ~isempty(get(handles.cmax,'String'))
    c1=str2num(get(handles.cmin,'String'));
    c2=str2num(get(handles.cmax,'String'));
    topoplot(Y(handles.act_chan_ind),handles.chanlocs(handles.act_chan_ind),'maplimits',[c1 c2]);
else
    topoplot(Y(handles.act_chan_ind),handles.chanlocs(handles.act_chan_ind),'maplimits',handles.minmax);
end
% Enable to select channels in topographic plot
V=get(handles.Topoplot,'Children');
set(V(1),'ButtonDownFcn',{@topplot_mousepress,hObject})

% Plot a circle on channel curretnly selected
radius=[handles.chanlocs(:).radius];
r=max(radius);
if get(handles.epochbut,'Value');
    n=get(handles.ch2pop,'value');
    hold on;
    chloc1=handles.chanlocs(handles.act_chan_ind(n));
    if r>0.5
        radius=chloc1.radius/r*0.5;
    end
    X1=[radius*sin(chloc1.theta/180*pi)];
	Y1=[radius*cos(chloc1.theta/180*pi)];
    plot(X1,Y1,'or','linewidth',2);
    hold off;
    handles.chanlocs=chanl;
    handles.act_chan_ind=actchanind;
else
    n=get(handles.ch,'value');
    hold on;
    chloc1=handles.chanlocs(handles.act_chan_ind(n));
    if r>0.5
        radius=chloc1.radius/r*0.5;
    end
    X1=[radius*sin(chloc1.theta/180*pi)];
	Y1=[radius*cos(chloc1.theta/180*pi)];
    plot(X1,Y1,'or','linewidth',2);   
    
    if get(handles.erpcohbut,'value') % Plot channel at which ERPCOH measure was generated in green circle
        fch=find(handles.chantoanal==handles.plotsit(1));
        chloc1=handles.chanlocs(handles.act_chan_ind(fch));
        if r>0.5
            radius=chloc1.radius/r*0.5;
        end
        X1=[radius*sin(chloc1.theta/180*pi)];
        Y1=[radius*cos(chloc1.theta/180*pi)];
        plot(X1,Y1,'og','linewidth',2);   
    end

end

% If spline file is defined plot also 3D headplot
if exist(handles.splnfile,'file')
    axes(handles.Headplot);
    if ~isempty(get(handles.cmin,'String')) & ~isempty(get(handles.cmax,'String')) 
        headplot(Y,handles.splnfile,'electrodes','off','maplimits',[c1 c2]);
    else
        headplot(Y,handles.splnfile,'electrodes','off','maplimits',handles.minmax);
    end
    V=get(handles.Headplot,'Children');
    set(V(1),'ButtonDownFcn',{@headplot_mousepress,hObject});
    rotate3d off;
end
% Fix matlab bug that happens to change color of GUI background
c=192/255;
set(handles.ERPWAVELAB,'color',[c c c]);
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function postnmlz_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function rows_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function rows_Callback(hObject, eventdata, handles)
% hObject    handle to rows (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rows as text
%        str2double(get(hObject,'String')) returns contents of rows as a double
guidata(hObject,handles);
Plotmontage(hObject)

% --- Executes during object creation, after setting all properties.
function columns_CreateFcn(hObject, eventdata, handles)
% hObject    handle to columns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function columns_Callback(hObject, eventdata, handles)
% hObject    handle to columns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of columns as text
%        str2double(get(hObject,'String')) returns contents of columns as a double
guidata(hObject,handles);
Plotmontage(hObject)

% --- Executes during object creation, after setting all properties.
function fromf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fromf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fromf_Callback(hObject, eventdata, handles)
% hObject    handle to fromf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fromf as text
%        str2double(get(hObject,'String')) returns contents of fromf as a double
if isempty(get(handles.fromt,'String'))
    set(handles.fromf,'string',num2str(handles.Fa(1)));
end
a=str2num(get(handles.fromf,'string'));
fp=m2mp(handles.Fa,a);
set(handles.fromf,'string',num2str(handles.Fa(fp)));
guidata(hObject,handles);
Plotmontage(hObject);

% --- Executes during object creation, after setting all properties.
function tof_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tof (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tof_Callback(hObject, eventdata, handles)
% hObject    handle to tof (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tof as text
%        str2double(get(hObject,'String')) returns contents of tof as a double
if isempty(get(handles.fromt,'String'))
    set(handles.tof,'string',num2str(handles.Fa(end)));
end
a=str2num(get(handles.tof,'string'));
fp=m2mp(handles.Fa,a);
set(handles.tof,'string',num2str(handles.Fa(fp)));
guidata(hObject,handles);
Plotmontage(hObject)

% --- Executes during object creation, after setting all properties.
function fromt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fromt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function fromt_Callback(hObject, eventdata, handles)
% hObject    handle to fromt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fromt as text
%        str2double(get(hObject,'String')) returns contents of fromt as a double
if isempty(get(handles.fromt,'String'))
    set(handles.fromt,'string',num2str(handles.tim(1)));
end
a=str2num(get(handles.fromt,'string'));
tp=m2mp(handles.tim,a);
set(handles.fromt,'string',num2str(handles.tim(tp)));
guidata(hObject,handles);
Plotmontage(hObject)

% --- Executes during object creation, after setting all properties.
function tot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tot_Callback(hObject, eventdata, handles)
% hObject    handle to tot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tot as text
%        str2double(get(hObject,'String')) returns contents of tot as a double
if isempty(get(handles.tot,'String'))
    set(handles.tot,'string',num2str(handles.tim(end)));
end
a=str2num(get(handles.tot,'string'));
tp=m2mp(handles.tim,a);
set(handles.tot,'string',num2str(handles.tim(tp)));
guidata(hObject,handles);
Plotmontage(hObject)


% --- Executes on mouse press over axes background.
function Montageplot_mousepress(src,event,hObject)
handles=guidata(hObject);
cp=get(handles.Montageplot,'CurrentPoint');
vc=floor(cp(1)-0.5);
vr=floor(cp(3)-0.5);
sX=[length(handles.act_chan_ind) length(handles.Fa_c) length(handles.tim_c)];
ch1=floor(vr/sX(2));
ch2=floor(vc/sX(3));
if get(handles.mfsch,'value')
   ch=ch1*str2num(get(handles.columns,'String'))+ch2+get(handles.ch,'value');
else
   ch=ch1*str2num(get(handles.columns,'String'))+ch2+1;
end
t=rem(vc,sX(3));
t=t+1;
fr=rem(vr,sX(2));
fr=fr+1;
set(handles.ch,'Value',ch);
set(handles.fr,'String',num2str(handles.Fa_c(fr)));
set(handles.tm,'String',num2str(handles.tim_c(t)));
guidata(hObject,handles);
if get(handles.mfsch,'value')
    Plotmontage(hObject);
end
Topheadplot(hObject);




% --- Executes on button press in clickpoint.
function clickpoint_Callback(hObject, eventdata, handles)
% hObject    handle to clickpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in erpcoh.
function erpcohbut_Callback(hObject, eventdata, handles)
% hObject    handle to erpcoh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.measure='ERPCOH';
handles=setmeasurebut(handles);
guidata(hObject,handles);
CalculateYh(hObject);

% --------------------------------------------------------------------
function options_Callback(hObject, eventdata, handles)
% hObject    handle to options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function itpcbut_Callback(hObject, eventdata, handles)
% hObject    handle to itpc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.measure='ITPC';
handles=setmeasurebut(handles);
guidata(hObject,handles);
CalculateYh(hObject);


% --------------------------------------------------------------------
function mfigure_Callback(hObject, eventdata, handles)
% hObject    handle to mfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function mheadplot_Callback(hObject, eventdata, handles)
% hObject    handle to mheadplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Display topography in separate figure
ss=get(handles.erpcohbut,'Value');
f=m2mp(handles.Fa, str2num(get(handles.fr,'String')));
t=m2mp(handles.tim, str2num(get(handles.tm,'String')));
Y=abs(squeeze(handles.Y(:,f,t)));
figure;
a{1}=[ get(handles.fr,'String') ' Hz ' get(handles.tm,'string') ' ms'];
if length(handles.splnfile)>0
    headplot(Y,handles.splnfile,'electrodes','off');
    caxis(handles.minmax);
else
    topoplot(Y,handles.chanlocs(handles.chantoanal),'maplimits',handles.minmax);
end

if ss==1
    a{2}=['ERPCOH ch: ' get(handles.cch,'String') ' ' get(handles.cfr,'String') ' Hz ' get(handles.ctm,'string') ' ms'];
end
title(a);

% --------------------------------------------------------------------
function chfrtim_Callback(hObject, eventdata, handles)
% hObject    handle to chfrtim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Plotmontage(hObject,1);
title([ get(handles.fromf,'String') '-' get(handles.tof,'String') ' Hz ' get(handles.fromt,'String') '-' get(handles.tot,'String') ' ms']);
ss=get(handles.itpcbut,'value');
if ss==1
    xlabel(['ITPC']);
else
    xlabel(['ERPCOH ch: ' get(handles.cch,'String') ' ' get(handles.cfr,'String') ' Hz ' get(handles.ctm,'string') ' ms']);
end
    




% --- Executes during object creation, after setting all properties.
function files_CreateFcn(hObject, eventdata, handles)
% hObject    handle to files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in files.
function files_Callback(hObject, eventdata, handles)
% hObject    handle to files (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns files contents as cell array
%        contents{get(hObject,'Value')} returns selected item from files
if get(handles.epochbut,'value')
    set(handles.epochbut,'value',0);
    guidata(hObject,handles);
    epochbut_Callback(hObject, eventdata, handles);
end

% Remove calculated sigma value since this might no longer be valid
if isfield(handles,'sigma') 
    rmfield(handles,'sigma');
end
handles=guidata(hObject);
set(handles.anovabut,'value',0);
nr=get(handles.files,'Value');
handles.filename=handles.filenamelist{nr};
handles.pathname=handles.pathnamelist{nr};
set(handles.sleveltxt,'visible','off');
guidata(hObject,handles);
loadit(hObject);
CalculateYh(hObject);

% --- Executes on button press in add.
function add_Callback(hObject, eventdata, handles)
% hObject    handle to add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LoadF_Callback(hObject, eventdata, handles);


% --- Executes on button press in remove.
function remove_Callback(hObject, eventdata, handles)
% hObject    handle to remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ss=get(handles.files,'Value');

handles.rec(ss:end-1)=handles.rec(ss+1:end);
handles.rec=handles.rec(1:end-1);
handles.filenamelist(ss:end-1)=handles.filenamelist(ss+1:end);
handles.filenamelist=handles.filenamelist(1:end-1);
handles.pathnamelist(ss:end-1)=handles.pathnamelist(ss+1:end);
handles.pathnamelist=handles.pathnamelist(1:end-1);
if length(handles.filenamelist)<ss & ss~=1
    ss=ss-1;
end
set(handles.files,'Value',ss);
set(handles.files,'String',handles.filenamelist);
guidata(hObject,handles);
if length(handles.filenamelist)==0
    setguiasopening(hObject);
end
    


% --- Executes on button press in useall.
function useall_Callback(hObject, eventdata, handles)
% hObject    handle to useall (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of useall
files_Callback(hObject, eventdata, handles)

% --------------------------------------------
function loadit(hObject)
% Internal function for loading datasets 

 handles=guidata(hObject);
 filenm=[handles.pathname handles.filename];

 if strcmp(filenm(end-3:end),'.mat') | strcmp(filenm(end-3:end),'.MAT')
     load('-mat',filenm);
 else
     filenm=[filenm '.mat'];
      load('-mat',filenm);
 end

 
 handles.Fs=Fs; 
 ss=get(handles.optramuse,'Checked');
 if ss(2)=='n'  % Minimize ram usage by only storing ROI in memory
    t1=m2mp(tim,str2num(get(handles.fromt,'String')));
    t2=m2mp(tim,str2num(get(handles.tot,'String')));
    fr1=m2mp(Fa,str2num(get(handles.fromf,'String')));
    fr2=m2mp(Fa,str2num(get(handles.tof,'String')));
    handles.tim=tim(t1:t2);     
    handles.Fa=Fa(fr1:fr2);
    chans=str2num(get(handles.channels,'String'));
    chantoanal=1:size(WT,1);
    act_chan_ind=getChannels(chantoanal,chans);
    chantoanal=chantoanal(act_chan_ind);
    chanlocs=chanlocs(act_chan_ind);
    handles.chanlocs=chanlocs;
    handles.wavetyp=wavetyp;
    guidata(hObject,handles);
    updateGuiforDataset(hObject)
    normalize(hObject);
    handles=guidata(hObject);
    handles.WT=WT(act_chan_ind,fr1:fr2,t1:t2,:);
    handles.act_chan_ind=1:size(handles.WT,1);
 else % Do not minimize ram usage
    handles.tim=tim;
    handles.Fa=Fa;
    handles.WT=WT;
    handles.chanlocs=chanlocs;
    handles.wavetyp=wavetyp;
    guidata(hObject,handles);
    updateGuiforDataset(hObject)
    normalize(hObject);
    handles=guidata(hObject);
 end
 if size(handles.WT,4)==1
     handles.nepoch=nepoch;
 else
     handles.nepoch=size(handles.WT,4);
 end 

guidata(hObject,handles);

 


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in erpcohbut.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to erpcohbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of erpcohbut


% --------------------------------------------------------------------
function erspbut_Callback(hObject, eventdata, handles)
% hObject    handle to ersp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.measure='ERSP';
handles=setmeasurebut(handles);
guidata(hObject,handles);
CalculateYh(hObject);


% --------------------------------------------------------------------
function zoom_Callback(hObject, eventdata, handles)
% hObject    handle to zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom on;



% --------------------------------------------------------------------
function optramuse_Callback(hObject, eventdata, handles)
% hObject    handle to optramuse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ss=get(handles.optramuse,'Checked');
if ss(2)=='n'
    set(handles.optramuse,'checked','off');
else
    set(handles.optramuse,'checked','on');
end
guidata(hObject,handles);
% Make sure datafile exist in ERPWAVELAB
if isfield(handles,'pathname')
    loadit(hObject);
end


% --- Executes on button press in clb.
function clb_Callback(hObject, eventdata, handles)
% hObject    handle to clb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of clb
Plotmontage(hObject);


% --------------------------------------------------------------------
function saveses_Callback(hObject, eventdata, handles)
% hObject    handle to saveses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname, pname] = uiputfile('*.ses', 'File in which to save session');
if fname(1)~=0 & pname(1)~=0
    erspbut=get(handles.erspbut,'Value');
    itpcbut=get(handles.itpcbut,'Value');
    erpcohbut=get(handles.erpcohbut,'Value');
    inducedbut=get(handles.erpcohbut,'Value');
    avWTbut=get(handles.avWTbut,'Value');
    WTavbut=get(handles.avWTbut,'Value');

    useall=get(handles.useall,'Value');
    
    tm=get(handles.tm,'String');
    fr=get(handles.fr,'String');
    ch=get(handles.ch,'value');
    
    fromt=get(handles.fromt,'String');
    tot=get(handles.tot,'String');
    fromf=get(handles.fromf,'String');
    tof=get(handles.tof,'String');
    channels=get(handles.channels,'String');
    
    act_chan_ind=handles.act_chan_ind;
    
    rec=handles.rec;
    filenamelist=handles.filenamelist;
    pathnamelist=handles.pathnamelist;
    plotsithist=handles.plotsithist;
    
    nonorm=get(handles.nonorm,'Checked');
    finv2=get(handles.finv,'Checked');
    normback=get(handles.normback,'Checked');
    nbcka=get(handles.nbcka,'Checked');
    nonormpost=get(handles.nonormpost,'Checked');

    slevel=get(handles.slevel,'string');
    confbut=get(handles.confbut,'value');
    bstrp=get(handles.bstrp,'value');
    rayleigh=get(handles.rayleigh,'value');
    dstrmax=get(handles.dstrmax,'value');
    bsize=get(handles.bsize,'String');
    
    a2lim=get(handles.a2lim,'Value');
    cmin=get(handles.cmin,'String');
    cmax=get(handles.cmax,'String');
    laxis=get(handles.laxis,'Value');
    
    noc=get(handles.noc,'String');
    maxiter=get(handles.maxiter,'String');
    cmax=get(handles.cmax,'String');
    cmin=get(handles.cmin,'String');
    sC=get(handles.sC,'String');
    sCH=get(handles.sCH,'String');
    sFT=get(handles.sFT,'String');
    sSC=get(handles.sSC,'String');
    nrdec=get(handles.nrdec,'String');
    
    tw=get(handles.tw,'String');
    th=get(handles.th,'String');
    columns=get(handles.columns,'String');
    rows=get(handles.rows,'String');
    inctopmont=get(handles.inctopmont,'value');
   
    optramuse=get(handles.optramuse,'Checked');
    phasecoh=get(handles.phasecoh,'Checked');
    lincoh=get(handles.lincoh,'Checked');
    
    sITPC=get(handles.sITPC,'value');
    utfpoint=get(handles.utpoint,'value');
    mfsch=get(handles.mfsch,'value');
    sfase=get(handles.sfase,'value');
    
    splnfile=handles.splnfile;
    
    
    save([pname,fname],'erspbut','itpcbut','erpcohbut','inducedbut','avWTbut','WTavbut','useall','tm','fr','ch',...
    'fromt','fromf','tof','tot','channels','act_chan_ind','rec','filenamelist','pathnamelist','plotsithist', 'nonorm', 'finv2', 'normback','nbcka',...
    'nonormpost','slevel','confbut','bstrp','rayleigh','bsize','dstrmax','a2lim','cmin','cmax','laxis','noc','maxiter','cmax','cmin',...
    'sC','sCH','sFT','sSC','nrdec','tw','th','columns','rows','inctopmont','optramuse','phasecoh','lincoh','sITPC','utfpoint','mfsch','sfase','splnfile');
end

% --------------------------------------------------------------------
function loadses_Callback(hObject, eventdata, handles)
% hObject    handle to loadses (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile('*.ses', 'Select session to load');
load([pathname,filename],'-mat');

set(handles.erspbut,'Value',erspbut);
set(handles.itpcbut,'Value',itpcbut);
set(handles.erpcohbut,'Value',erpcohbut);
set(handles.inducedbut,'Value',erspbut);
set(handles.WTavbut,'Value',itpcbut);
set(handles.avWTbut,'Value',erpcohbut);

set(handles.useall,'Value',useall);
set(handles.tm,'String',tm);
set(handles.fr,'String',fr);
set(handles.ch,'Value',ch);

set(handles.fromt,'String',fromt);
set(handles.tot,'String',tot);
set(handles.fromf,'String',fromf);
set(handles.tof,'String',tof);
set(handles.channels,'String',channels);

handles.filenamelist(end+1:end+length(filenamelist))=filenamelist;
handles.pathnamelist(end+1:end+length(pathnamelist))=pathnamelist;
handles.plotsithist(end+1:end+length(plotsithist))=plotsithist;
set(handles.files,'String',handles.filenamelist);
nr=get(handles.files,'value');
handles.pathname=handles.pathnamelist{nr};
handles.filename=handles.filenamelist{nr};
if isfield(handles,'rec')
    handles.rec(end+1:end+length(rec))=rec;
else
    handles.rec=rec;
end
handles.act_chan_ind=act_chan_ind;

set(handles.nonorm,'Checked',nonorm);
set(handles.finv,'Checked',finv2);
set(handles.normback,'Checked',normback);
set(handles.nbcka,'Checked',nbcka);
set(handles.nonormpost,'Checked',nonormpost);

set(handles.slevel,'string',slevel);
set(handles.confbut,'value',confbut);
set(handles.bstrp,'value',bstrp);
set(handles.rayleigh,'value',rayleigh);
set(handles.dstrmax,'value',dstrmax);
set(handles.bsize,'String',bsize);

set(handles.a2lim,'Value',a2lim);
set(handles.cmin,'String',cmin);
set(handles.cmax,'String',cmax);
set(handles.laxis,'Value',laxis);

set(handles.noc,'String',noc);
set(handles.maxiter,'String',maxiter);
set(handles.cmax,'String',cmax);
set(handles.cmin,'String',cmin);
set(handles.sC,'String',sC);
set(handles.sCH,'String',sCH);
set(handles.sFT,'String',sFT);
set(handles.sSC,'String',sSC);
set(handles.nrdec,'String',nrdec);

set(handles.tw,'String',tw);
set(handles.th,'String',th);
set(handles.columns,'String',columns);
set(handles.rows,'String',rows);
set(handles.inctopmont,'value',inctopmont);

set(handles.optramuse,'Checked',optramuse);
set(handles.phasecoh,'Checked',phasecoh);
set(handles.lincoh,'Checked',lincoh);

set(handles.sITPC,'value',sITPC);
set(handles.utpoint,'value',utfpoint);
set(handles.mfsch,'value',mfsch);
set(handles.sfase,'value',sfase);

handles.splnfile=splnfile;
if ~isempty(splnfile)
    set(handles.loadsplnfile,'String',splnfile(max([length(splnfile)-8 1]):end));
end

guidata(hObject,handles);
loadit(hObject);
CalculateYh(hObject)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pos_size = get(handles.ERPWAVELAB,'Position');
% Call modaldlg with the argument 'Position'.
user_response = exitdiag('Title','Confirm Exit');
switch user_response
case {'No'}
    % take no action
case 'Yes'
    % Prepare to close GUI application window
    delete(handles.ERPWAVELAB)
end



% --- Executes on button press in NMFbut.
function NMFbut_Callback(hObject, eventdata, handles)
% hObject    handle to NMFbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Perform NMF decomposition of Ch x Fr-Time

% Make sure measure is not log-transformed
if get(handles.laxis,'value')
   set(handles.laxis,'value',0);
   guidata(hObject,handles);
   Plotmontage(hObject);
   Topheadplot(hObject);
   handles=guidata(hObject);
end

% Check what type of measure is to be decomposed
if get(handles.anovabut,'value')
    X=abs(handles.Y);
    t1=str2num(get(handles.fromt,'String'));
    t2=str2num(get(handles.tot,'String'));
    fr1=str2num(get(handles.fromf,'String'));
    fr2=str2num(get(handles.tof,'String'));
else
    t1=str2num(get(handles.fromt,'String'));
    t2=str2num(get(handles.tot,'String'));
    fr1=str2num(get(handles.fromf,'String'));
    fr2=str2num(get(handles.tof,'String'));
    X=abs(handles.Y(:,m2mp(handles.Fa,fr1):m2mp(handles.Fa,fr2),m2mp(handles.tim,t1):m2mp(handles.tim,t2)));
end
fre=handles.Fa(m2mp(handles.Fa,fr1):m2mp(handles.Fa,fr2));
tim=handles.tim(m2mp(handles.tim,t1):m2mp(handles.tim,t2));

% Set algortihm parameters
X=matrizicing(X,1);
cm1=str2num(get(handles.cmin,'String'));
lsv=get(handles.LS,'value');
if lsv==1
    meth.costfcn='ls';
else
    meth.costfcn='kl';
end
meth.lambda(1)=str2num(get(handles.sC,'String'));
meth.lambda(2)=str2num(get(handles.sCH,'String'));
meth.lambda(3)=str2num(get(handles.sFT,'String'));
meth.lambda(4)=str2num(get(handles.sSC,'String'));
if get(handles.Tucker,'Value')
    meth.type='HONMF';
else
    meth.type='NMWF';
end
meth.maxiter=str2num(get(handles.maxiter,'String'));
ss=get(handles.optramuse,'Checked');
if ss(2)=='n'
    meth.minRAM=1;
else
    meth.minRAM=0;
end
% subtract values below display treshold in Montageplot
X=X-cm1;
X(X<0)=0;
% Analyze by NMF
if exist(handles.splnfile) & length(handles.act_chan_ind)==length(handles.chantoanal)
     analyzenmf(X,str2num(get(handles.noc,'String')),handles.chanlocs(1:size(X,1)),tim,fre, meth, handles.splnfile);
 else
      analyzenmf(X(handles.act_chan_ind,:),str2num(get(handles.noc,'String')),handles.chanlocs(handles.act_chan_ind),tim,fre, meth,[]);
 end


% --- Executes on button press in parafacbut.
function parafacbut_Callback(hObject, eventdata, handles)
% hObject    handle to parafacbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% PARAFAC/TUCKER decomposition of Ch x Fr-Time x Subj/cond 

% Correct if data is log-transformed 
if get(handles.laxis,'value')
   set(handles.laxis,'value',0);
   guidata(hObject,handles);
   Plotmontage(hObject);
   Topheadplot(hObject);
   handles=guidata(hObject);
end

% Extract ROI
t1=str2num(get(handles.fromt,'String'));
t2=str2num(get(handles.tot,'String'));
fr1=str2num(get(handles.fromf,'String'));
fr2=str2num(get(handles.tof,'String'));
fre=handles.Fa(m2mp(handles.Fa,fr1):m2mp(handles.Fa,fr2));
tim=handles.tim(m2mp(handles.tim,t1):m2mp(handles.tim,t2));

% Create 3-way dataset
if ~get(handles.epochbut,'value')
    Yold=handles.Y;
    handles=guidata(hObject);
    Y=createarray(hObject,handles);
    handles.Y=Yold;
    clear Yold;
else
    Y=calepochmeas(handles);
    Y=Y(handles.act_chan_ind,:,:,:);
    Y=abs(permute(Y,[4 2 3 1]));
    Y=reshape(Y,[size(Y,1), size(Y,2)*size(Y,3), size(Y,4)])-str2num(get(handles.cmin,'String'));
    Y(Y<0)=0;
end

% Set algorithm parameters
d=str2num(get(handles.noc,'String'));
lsv=get(handles.LS,'value');
if lsv==1
    meth.costfcn='ls';
else
    meth.costfcn='kl';
end
meth.lambda(1)=str2num(get(handles.sC,'String'));
meth.lambda(2)=str2num(get(handles.sCH,'String'));
meth.lambda(3)=str2num(get(handles.sFT,'String'));
meth.lambda(4)=str2num(get(handles.sSC,'String'));
if get(handles.Tucker,'Value')
    meth.type='HONMF';
else
    meth.type='NMWF';
end
meth.maxiter=str2num(get(handles.maxiter,'String'));
ss=get(handles.optramuse,'Checked');
if ss(2)=='n'
    meth.minRAM=1;
else
    meth.minRAM=0;
end
% Analyze the dataset
if ~get(handles.epochbut,'value')
    datasetname=handles.filenamelist;
    if exist(handles.splnfile,'file') & length(handles.act_chan_ind)==length(handles.chantoanal)
        analyzeallcond(Y,d,handles.chanlocs,tim,fre,  meth, handles.splnfile, datasetname);
    else       
        analyzeallcond(Y,d,handles.chanlocs(handles.act_chan_ind),tim,fre, meth,[], datasetname);
    end
else
    datasetname=num2cell(handles.chantoanal);
    if exist(handles.splnfile,'file')
        analyzeallcond(Y,d,handles.chanlocsold,tim,fre,  meth, handles.splnfile,datasetname);
    else
        analyzeallcond(Y,d,handles.chanlocsold,tim,fre, meth,[],datasetname);
    end
end






% --------------------------------------------------------------------
function nmfm_Callback(hObject, eventdata, handles)
% hObject    handle to nmfm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NMFbut_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function parafacm_Callback(hObject, eventdata, handles)
% hObject    handle to parafacm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
parafac_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function BDFfil_Callback(hObject, eventdata, handles)
% hObject    handle to BDFfil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
BDFCreate;


% --------------------------------------------------------------------
function EEGLABfil_Callback(hObject, eventdata, handles)
% hObject    handle to EEGLABfil (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global EEG;
if size(EEG.data,3)==1
    disp('EEGLAB dataset has not been epoched');
elseif isempty(EEG.chanlocs)
    disp('Channel locations has not been defined');
else
    h=EEGCreate;
    uiwait(h);
    hand=guidata(h);
    delete(hand.figure1);
    handles.pathnamelist(end+1:end+length(hand.pathnames))=hand.pathnames;
    handles.filenamelist(end+1:end+length(hand.pathnames))=hand.filenames;
    if isfield(handles,'rec')
        handles.rec(end+1:end+length(hand.pathnames))=cell(length(hand.pathnames),1);
    else
        handles.rec=cell(length(hand.pathnames),1);
    end
    set(handles.files,'String',handles.filenamelist);
    set(handles.files,'Value',length(handles.filenamelist));
    guidata(hObject,handles);
    files_Callback(hObject, eventdata, handles)
end



% --------------------------------------------------------------------
function inducedbut_Callback(hObject, eventdata, handles)
% hObject    handle to induced (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.measure='INDUCED';
handles=setmeasurebut(handles);
guidata(hObject,handles);
CalculateYh(hObject);



% --------------------------------------------------------------------
function avWTbut_Callback(hObject, eventdata, handles)
% hObject    handle to avWT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.measure='avWT';
handles=setmeasurebut(handles);
guidata(hObject,handles);
CalculateYh(hObject);


% --------------------------------------------------------------------
function WTavbut_Callback(hObject, eventdata, handles)
% hObject    handle to WTav (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.measure='WTav';
handles=setmeasurebut(handles);
guidata(hObject,handles);
CalculateYh(hObject);


% --- Executes on button press in utpoint.
function utpoint_Callback(hObject, eventdata, handles)
% hObject    handle to utpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of utpoint

ss=get(handles.erpcohbut,'Value');
if get(handles.utpoint,'Value') & ss
    set(handles.ctm,'Visible','on');
    set(handles.erpcohpt,'Visible','on');
else
    set(handles.ctm,'Visible','off');
end
guidata(hObject,handles);
checkRejectPhase(hObject);
CalculateYh(hObject);


% --- Executes on button press in ufpoint.
function ufpoint_Callback(hObject, eventdata, handles)
% hObject    handle to ufpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ufpoint


ss=get(handles.erpcohbut,'Value');
if get(handles.ufpoint,'Value') & ss
    set(handles.cfr,'Visible','on');
    set(handles.erpcohpt,'Visible','on');
else
    set(handles.cfr,'Visible','off');
end
guidata(hObject,handles);
checkRejectPhase(hObject);
CalculateYh(hObject);




% --------------------------------------------------------------------
function plotchloc_Callback(hObject, eventdata, handles)
% hObject    handle to plotchloc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure; 
topoplot([],handles.chanlocs, 'style', 'blank', 'electrodes', 'labelpoint');



% --- Executes on button press in loadsplinefile.
function loadsplinefile_Callback(hObject, eventdata, handles)
% hObject    handle to loadsplinefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fname, pathname, filterindex]=uigetfile('*.spl;*.SPL','Spline file to load');
if filterindex==1 & exist([pathname,fname],'file')
    handles.splnfile=[pathname, fname];
    set(handles.loadsplinefile,'String',fname);
    guidata(hObject, handles);
    if isfield(handles,'Y')
        Topheadplot(hObject);
    end
elseif filterindex==0
    set(handles.loadsplinefile,'String','Load 3D spline file');
    handles.splnfile=[];
     guidata(hObject, handles);
     axes(handles.Headplot);
     cla;
end


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function rcc_Callback(hObject, eventdata, handles)
% hObject    handle to rcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ch=handles.act_chan_ind(get(handles.ch,'Value'));
fr=str2num(get(handles.fr,'String'));
tm=str2num(get(handles.tm,'String'));
val=str2num(get(handles.val,'String'));
cch=get(handles.cch,'String');
for k=1:length(handles.chanlocs)
    if strcmp(cch,handles.chanlocs(k).labels)
        ch2=k;
    end
end
if get(handles.utpoint,'value')
    ctm=str2num(get(handles.ctm,'String'));
else
    ctm=tm;
end
if get(handles.ufpoint,'value')
    cfr=str2num(get(handles.cfr,'String'));
else  
    cfr=fr;
end

nr=get(handles.files,'Value');
[sl, handles.sigma]=crosscohsignificance(hObject,val);

ss=get(handles.rejectERPCOHphase,'Checked');
ss2=get(handles.rejectERPCOHphase,'enable');
if ss(2)=='n' & ss2(2)=='n'
    Y=getCoef(hObject);
    if get(handles.dstrmax,'value')
        npnt=prod(nr_points_disp(hObject));
    else
        npnt=1;
    end
    [x,p]=vonMises(Y,handles.nrepoch,0.5,npnt);
else
    p=[];
end
handles.rec{nr}{end+1}=[ch fr tm val ch2 cfr ctm sl p];
set(handles.vrcc,'enable','on');
H=crosscohrec;
pause(0.5)
close('crosscohrec')

guidata(hObject,handles);

% --------------------------------------------------------------------
function vrcc_Callback(hObject, eventdata, handles)
% hObject    handle to vrcc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nr=get(handles.files,'Value');
rect=handles.rec{nr};
plotcoh(handles.chanlocs(handles.act_chan_ind),rect)

% --- Executes on button press in rembc.
function rembc_Callback(hObject, eventdata, handles)
% hObject    handle to rembc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rembc

if ~get(handles.rembc,'value')
    set(handles.cmin,'string',0);
    set(handles.cmax,'string',num2str(max(abs(handles.Y(:)))));
    set(handles.a2lim,'Value',0);
else
    sigma=calcsigma(hObject);
    set(handles.cmin,'string',num2str(sigma*sqrt(pi/2)));
    set(handles.cmax,'string',num2str(max(abs(handles.Y(:)))));
    set(handles.a2lim,'Value',0);
end
guidata(hObject,handles);
ss=get(handles.nonorm,'Checked');
if ss(2)~='n'
    nonorm_Callback(hObject, eventdata, handles)
else
    Plotmontage(hObject);
end


% --------------------------------------------------------------------
function cmax_Callback(hObject, eventdata, handles)
% hObject    handle to cmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cmax as text
%        str2double(get(hObject,'String')) returns contents of cmax as a double

set(handles.a2lim,'value',0);
if ~isempty(get(handles.cmin,'string'))
    Plotmontage(hObject);
    Topheadplot(hObject);
end


% --- Executes during object creation, after setting all properties.
function cmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --------------------------------------------------------------------
function cmin_Callback(hObject, eventdata, handles)
% hObject    handle to cmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cmin as text
%        str2double(get(hObject,'String')) returns contents of cmin as a double
set(handles.a2lim,'value',0);
if ~isempty(get(handles.cmax,'string'))
    Plotmontage(hObject);
    Topheadplot(hObject);
end



% --- Executes during object creation, after setting all properties.
function cmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on button press in fadd.
function fadd_Callback(hObject, eventdata, handles)
% hObject    handle to fadd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
LoadD_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function fastfile_Callback(hObject, eventdata, handles)
% hObject    handle to fastfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

t1=str2num(get(handles.fromt,'String'));
t2=str2num(get(handles.tot,'String'));
fr1=str2num(get(handles.fromf,'String'));
fr2=str2num(get(handles.tof,'String'));


ss=get(handles.optramuse,'Checked');
if ss(2)=='n'
    WT=handles.Y;
    Fa=handles.Fa;
    tim=handles.tim;
else
    WT=handles.Y(handles.act_chan_ind, m2mp(handles.Fa,fr1):m2mp(handles.Fa,fr2),m2mp(handles.tim,t1):m2mp(handles.tim,t2));
    Fa=handles.Fa(m2mp(handles.Fa,fr1):m2mp(handles.Fa,fr2));
    tim=handles.tim(m2mp(handles.tim,t1):m2mp(handles.tim,t2));
end
nepoch=handles.nrepoch;
Fs=handles.Fs;
wavetyp=handles.wavetyp;
chanlocs=handles.chanlocs(handles.act_chan_ind);
chantoanal=handles.act_chan_ind;
 
[fname, pname] = uiputfile('*.*', 'File in which to save FAST ERPWAVELAB File to',[handles.filename(1:end-4) '-' handles.measure '.mat']);
if fname(1)~=0
    save([pname, fname],'nepoch','wavetyp','chanlocs','WT','Fs','tim','Fa','chantoanal');
end


 
% --- Executes on button press in nmf2.
function nmf2_Callback(hObject, eventdata, handles)
% hObject    handle to nmf2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Decomposition by Ch x Fr-Time-Subj/cond

% Correct for log-transformation
if get(handles.laxis,'value')
   set(handles.laxis,'value',0);
   guidata(hObject,handles);
   Plotmontage(hObject);
   Topheadplot(hObject);
   handles=guidata(hObject);
end


nrdec=str2num(get(handles.nrdec,'String'));
% Get ROI
t1=str2num(get(handles.fromt,'String'));
t2=str2num(get(handles.tot,'String'));
fr1=str2num(get(handles.fromf,'String'));
fr2=str2num(get(handles.tof,'String'));
if ~get(handles.epochbut,'value') % make sure GUI is not in epoch mode
    YY=abs(handles.Y(:,m2mp(handles.Fa,fr1):m2mp(handles.Fa,fr2),m2mp(handles.tim,t1):m2mp(handles.tim,t2)));
    Yold=handles.Y;
    nrepoch=0;
    handles=guidata(hObject);
    for k=1:length(handles.filenamelist) % load all datasets and create analyzable array Y.
        clear handles.WT;
        clear handles.Y;
        handles.filename=handles.filenamelist{k};
        handles.pathname=handles.pathnamelist{k};
        disp(['Processing: ' handles.filename]);
        guidata(hObject,handles);
        loadit(hObject)
        handles=guidata(hObject);
        clear handles.X;
        guidata(hObject,handles);
        CalculateY(hObject);
        handles=guidata(hObject);
        pause(0.001);
        Y(:,:,k)=matrizicing(abs(handles.Y(:,m2mp(handles.Fa,fr1):m2mp(handles.Fa,fr2),m2mp(handles.tim,t1):m2mp(handles.tim,t2))),1);
    end
    handles.Y=Yold;
    clear Yold;
    guidata(hObject,handles);
else
    Y=calepochmeas(handles);
    Y=Y(handles.act_chan_ind,:,:,:);
    Y=permute(Y,[4 2 3 1]);
    Y=abs(matrizicing(Y,1));
end
cm1=get(handles.cmin,'String');
Y=Y-str2num(cm1);
Y(Y<0)=0;

% Set algorithm parameters
d=str2num(get(handles.noc,'String'));
tim=handles.tim(m2mp(handles.tim,t1):m2mp(handles.tim,t2));
fre=handles.Fa(m2mp(handles.Fa,fr1):m2mp(handles.Fa,fr2));
lsv=get(handles.LS,'value');
if lsv==1
    meth.costfcn='ls';
else
    meth.costfcn='kl';
end
meth.lambda(1)=str2num(get(handles.sC,'String'));
meth.lambda(2)=str2num(get(handles.sCH,'String'));
meth.lambda(3)=str2num(get(handles.sFT,'String'));
meth.lambda(4)=str2num(get(handles.sSC,'String'));
if get(handles.Tucker,'Value')
    meth.type='HONMF';
else
    meth.type='NMWF';
end
meth.maxiter=str2num(get(handles.maxiter,'String'));
ss=get(handles.optramuse,'Checked');
if ss(2)=='n'
    meth.minRAM=1;
else
    meth.minRAM=0;
end



% Analyze dataset
if ~get(handles.epochbut,'value')
    datasetname=handles.filenamelist;
    if exist(handles.splnfile,'file') & length(handles.act_chan_ind)==length(handles.chantoanal)
          analyzeallcond2(Y,d,handles.chanlocs,tim,fre, nrdec, meth, handles.splnfile,datasetname);
    else
         analyzeallcond2(Y(handles.act_chan_ind,:,:),d,handles.chanlocs(handles.act_chan_ind),tim,fre, nrdec,meth,[],datasetname);
    end
else
    datasetname=num2cell(handles.chantoanal);
    if exist(handles.splnfile,'file')
          analyzeallcond2(Y,d,handles.chanlocsold,tim,fre, nrdec, meth, handles.splnfile,datasetname);
    else
         analyzeallcond2(Y,d,handles.chanlocsold,tim,fre, nrdec,meth,[],datasetname);
    end
end



function nrdec_Callback(hObject, eventdata, handles)
% hObject    handle to nrdec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nrdec as text
%        str2double(get(hObject,'String')) returns contents of nrdec as a double


% --- Executes during object creation, after setting all properties.
function nrdec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nrdec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton18.
function anovabut_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Test of difference ANOVA or Kruskall-Wallis

f1=get(handles.fromf,'String');
f2=get(handles.tof,'String');
t1=get(handles.fromt,'String');
t2=get(handles.tot,'String');

set(handles.fromf,'String',num2str(handles.Fa(1)));
set(handles.tof,'String',num2str(handles.Fa(end)));
set(handles.fromt,'String',num2str(handles.tim(1)));
set(handles.tot,'String',num2str(handles.tim(end)));

varargin.files=handles.filenamelist;
if exist('handles.groupclass','var')
    varargin.groupclass=handles.groupclass;
end

% Open window enabling specifying design matrix
H=designmatrix(varargin);
uiwait(H);
handlesd=guidata(H);
close('designmatrix')
handles.groupclass=handlesd.groupclass;
handles.testtype=handlesd.testtype;

% Create data array
carray=createarray(hObject,handles,1);
% Make it an array of rank if Kruskal-Wallis test
if strcmp(handles.testtype,'KW')
    [Y,I]=sort(carray,4);
    for i=1:size(carray,1)
        for j=1:size(carray,2) 
            for k=1:size(carray,3)
                carray(i,j,k,I(i,j,k,:))=1:size(I,4);
            end
        end
    end    
end

gr=unique(handles.groupclass);
S=length(handles.groupclass)/length(gr);
K=length(gr);
% Calculate group mean and overal means
for k=1:length(gr)
    ind=find(gr(k)==handles.groupclass);
    WGM(:,:,:,k)=mean(carray(:,:,:,ind),4);
    WWGM(:,:,:,ind)=repmat(WGM(:,:,:,k),[1,1,1,S]);
end
GM=mean(WGM,4);

% Access significance level
SL=str2num(get(handles.slevel,'String'));
if get(handles.dstrmax,'value')
    SL=SL^(1/prod(nr_points_disp(hObject)));
end    

% Calculate test values
if strcmp(handles.testtype,'ANOVA')
    T=sum((WGM-repmat(GM,[1,1,1,size(WGM,4)])).^2,4)/(K-1);
    W=sum((carray-WWGM).^2,4)/(K*(S-1));
    if exist('finv.m','file') % Statistics toolbox installed
        X=finv(SL,K-1,K*(S-1));
    else
        X=0
    end
else
    GMt=repmat(GM,[1,1,1,size(WGM,4)]);
    T=sum((WGM-GMt).^2,4)*S;
    W=S*K*(S*K+1)/12;    
    if exist('chi2inv.m','file') % Statistics toolbox installed
        X = chi2inv(SL,K-1);
    else
        X=0
    end
end


handles.K=K;
handles.S=S;
handles.Y=T./(W+eps);
set(handles.cmin,'String',num2str(X));
set(handles.cmax,'String',num2str(max(handles.Y(:))));
set(handles.a2lim,'value',0);

set(handles.fromf,'String',f1);
set(handles.tof,'String',f2);
set(handles.fromt,'String',t1);
set(handles.tot,'String',t2);

guidata(hObject,handles);
Plotmontage(hObject);
Topheadplot(hObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function carray=createarray(hObject,handles,anova)
% For NMF, NMWF decomposition and Test of diff.

if nargin<3
    anova=0;
end
% Extract ROI
t1=str2num(get(handles.fromt,'String'));
t2=str2num(get(handles.tot,'String'));
fr1=str2num(get(handles.fromf,'String'));
fr2=str2num(get(handles.tof,'String'));
for k=1:length(handles.filenamelist)
    clear handles.WT;
    clear handles.Y;
    handles.filename=handles.filenamelist{k};
    handles.pathname=handles.pathnamelist{k};
    disp(['Processing: ' handles.filename]);
    guidata(hObject,handles);
    loadit(hObject)
    handles=guidata(hObject);
    clear handles.X;
    guidata(hObject,handles);
    CalculateY(hObject);
    handles=guidata(hObject);
    pause(0.001);
    handles.Y=abs(handles.Y)-str2num(get(handles.cmin,'String'));
    ind=find(handles.Y<0);
    handles.Y(ind)=0;
    if anova
        carray(:,:,:,k)=abs(handles.Y(handles.act_chan_ind,m2mp(handles.Fa,fr1):m2mp(handles.Fa,fr2),m2mp(handles.tim,t1):m2mp(handles.tim,t2)));
    else
        carray(:,:,k)=matrizicing(abs(handles.Y(handles.act_chan_ind,m2mp(handles.Fa,fr1):m2mp(handles.Fa,fr2),m2mp(handles.tim,t1):m2mp(handles.tim,t2))),1);
    end 
    
end
 guidata(hObject,handles);

 
 % --- Executes on button press in LS.
function LS_Callback(hObject, eventdata, handles)
% hObject    handle to LS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LS
set(handles.KL,'value',0)
set(handles.LS,'value',1)


% --- Executes on button press in KL.
function KL_Callback(hObject, eventdata, handles)
% hObject    handle to KL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of KL
set(handles.KL,'value',1)
set(handles.LS,'value',0)



% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function NMFopts_Callback(hObject, eventdata, handles)
% hObject    handle to NMFopts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function chfts_Callback(hObject, eventdata, handles)
% hObject    handle to chfts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nmf2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function slevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in fget.
function fget_Callback(hObject, eventdata, handles)
% hObject    handle to fget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of fget


% --- Executes on button press in dget.
function dget_Callback(hObject, eventdata, handles)
% hObject    handle to dget (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dget


% --------------------------------------------------------------------
function LoadD_Callback(hObject, eventdata, handles)
% hObject    handle to LoadD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pathname=uigetdir('*.*','Directory to load');
if pathname~=0
if exist(pathname,'dir')
    files=dir(pathname);
    for k=3:length(files)
        handles.pathname=[pathname '/'];
        handles.filename=files(k).name;
        handles.filenamelist{end+1}=files(k).name;
        handles.pathnamelist{end+1}=[pathname '/']; 
        handles.rec{length(handles.filenamelist)}={};
    end
    set(handles.files,'String',handles.filenamelist);
    set(handles.files,'Value', length(handles.filenamelist));
    guidata(hObject,handles);
    loadit(hObject);
    CalculateYh(hObject);      
end
end



% --- Executes on button press in laxis.
function laxis_Callback(hObject, eventdata, handles)
% hObject    handle to laxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of laxis

Plotmontage(hObject);
Topheadplot(hObject)



function sFT_Callback(hObject, eventdata, handles)
% hObject    handle to sFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sFT as text
%        str2double(get(hObject,'String')) returns contents of sFT as a double


% --- Executes during object creation, after setting all properties.
function sFT_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sFT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function norms_Callback(hObject, eventdata, handles)
% hObject    handle to norms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of norms as text
%        str2double(get(hObject,'String')) returns contents of norms as a double


% --- Executes during object creation, after setting all properties.
function norms_CreateFcn(hObject, eventdata, handles)
% hObject    handle to norms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in a2lim.
function a2lim_Callback(hObject, eventdata, handles)
% hObject    handle to a2lim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of a2lim
Plotmontage(hObject)



% --------------------------------------------------------------------
function swavelet_Callback(hObject, eventdata, handles)
% hObject    handle to swavelet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure;
fb=[];
k=length(handles.wavetyp);
while handles.wavetyp(k)~='-'
    fb=[handles.wavetyp(k) fb ];
    k=k-1;
end

plotwavelet(handles.wavetyp(1:k-1),str2num(fb));
title(handles.wavetyp);




function channels_Callback(hObject, eventdata, handles)
% hObject    handle to channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of channels as text
%        str2double(get(hObject,'String')) returns contents of channels as a double

% Updating what channels (epochs in epoch mode) are removed
handles=guidata(hObject);
ss=get(handles.optramuse,'Checked');
if ss(2)=='n' & isempty(eventdata)
    loadit(hObject);
    CalculateYh(hObject);
else
    handles=guidata(hObject);
    chans=str2num(get(handles.channels,'string'));
    if isfield(handles,'act_chan_ind') & handles.act_chan_ind(get(handles.ch,'Value'))<=length(handles.chanlocs)
        curch=handles.chanlocs(handles.act_chan_ind(get(handles.ch,'Value'))).labels;     
    else
        curch='';
    end
    handles.act_chan_ind=getChannels(handles.chantoanal, chans);
    id=0;
    for k=1:length(handles.act_chan_ind)
        channels{k}=handles.chanlocs(handles.act_chan_ind(k)).labels;
        if strcmp(channels{k},curch)
            id=1;
            set(handles.ch,'Value',k);
        end
    end
    if id==0
        set(handles.ch,'Value',1);
    end
    set(handles.ch,'String',channels);
    guidata(hObject,handles);
end
Plotmontage(hObject);
Topheadplot(hObject);

% --- Executes during object creation, after setting all properties.
function channels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --------------------------------------------------------------------
function rejecttrials_Callback(hObject, eventdata, handles)
% hObject    handle to rejecttrials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if size(handles.WT,4)>1
    global EEG;
    reject=max([EEG.reject.rejmanual ; zeros(1,size(EEG.data,3))],[],1)+max([EEG.reject.rejjp ; zeros(1,size(EEG.data,3))],[],1)+max([EEG.reject.rejkurt ; zeros(1,size(EEG.data,3))],[],1)+...
        max([EEG.reject.rejthresh ; zeros(1,size(EEG.data,3))],[],1)+max([EEG.reject.rejconst  ; zeros(1,size(EEG.data,3))],[],1)+max([EEG.reject.rejfreq ; zeros(1,size(EEG.data,3))],[],1)+...
        max([EEG.reject.icarejjp ; zeros(1,size(EEG.data,3))],[],1)+max([EEG.reject.icarejkurt; zeros(1,size(EEG.data,3))],[],1)+max([EEG.reject.icarejmanual ; zeros(1,size(EEG.data,3))],[],1)+...
        max([EEG.reject.icarejthresh ; zeros(1,size(EEG.data,3))],[],1)+max([EEG.reject.icarejconst ; zeros(1,size(EEG.data,3))],[],1)+max([EEG.reject.icarejfreq ; zeros(1,size(EEG.data,3))],[],1)+...
        max([EEG.reject.rejglobal ; zeros(1,size(EEG.data,3))],[],1);
    ind=find(reject==0);
    if get(handles.epochbut,'value')
         WT=handles.WT(ind,:,:,:);
         handles.chantoanal=handles.chantoanal(ind);
         handles.act_chan_ind=getchannels(handles.chantoanal,num2str(get(handles.channels,'string')));
         nepoch=size(WT,1);
    else
        WT=handles.WT(:,:,:,ind);
        nepoch=size(WT,4);
        [filename, pathname]=uiputfile('*.mat','Save dataset with rejected trials')
        save([pathname filename], 'WT', 'chanlocs','Fs','Fa','wavetyp', 'tim','nepoch'); 
        handles.pathname=pathname;
        handles.filename=filename;
        nr=get(handles.files,'Value');
        handles.filenamelist{nr}=filename;
        handles.pathnamelist{nr}=pathname;
        set(handles.files,'String',handles.filenamelist);
        guidata(hObject,handles);
        loadit(hObject);
        CalculateYh(hObject);
    end
    Plotmontage(hObject);
    Topheadplot(hObject);
end

% --- Executes on button press in sfase.
function sfase_Callback(hObject, eventdata, handles)
% hObject    handle to sfase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sfase
Plotmontage(hObject);
Topheadplot(hObject);



% --------------------------------------------------------------------
function coefpoint_Callback(hObject, eventdata, handles)
% hObject    handle to coefpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Distplayes the distribution of epoch at currently selected point
figure;

% Extract epoch values at currently inspected point
if ~get(handles.useall,'value')
    f=m2mp(handles.Fa, str2num(get(handles.fr,'String')));
    t=m2mp(handles.tim, str2num(get(handles.tm,'String')));
    if get(handles.epochbut,'value')
        ch=get(handles.ch2pop,'Value');
        Y=squeeze(handles.WT(:,f,t,ch));
    else
        ch=get(handles.ch,'Value');
        Y=squeeze(handles.WT(ch,f,t,:));
    end
else    
    Y=[];
    for k=1:length(handles.filenamelist)
        clear handles.WT;
        clear handles.Y;
        handles.filename=handles.filenamelist{k};
        handles.pathname=handles.pathnamelist{k};
        disp(['Processing: ' handles.filename]);
        guidata(hObject,handles);
        loadit(hObject)
        handles=guidata(hObject);
        clear handles.X;
        guidata(hObject,handles);
        CalculateY(hObject);
        handles=guidata(hObject);   
        f=m2mp(handles.Fa, str2num(get(handles.fr,'String')));
        t=m2mp(handles.tim, str2num(get(handles.tm,'String')));
        ch=get(handles.ch,'Value');
        Y(end+1:end+size(handles.WT,4))=handles.WT(ch,f,t,:);
    end
end

% Plot the distribution of these extracted values
subplot(2,2,1)
        plot(real(Y),imag(Y),'.');
        hold on;
        plot([min(real(Y)) max(real(Y))],[0 0],'k--');
        plot([0 0],[min(imag(Y)) max(imag(Y))],'k--');
        for k=1:length(Y)
            text(real(Y(k)),imag(Y(k)),num2str(k),'FontSize',7);
        end
        hold off
        T{1}='Un-normalized directions';
        T{2}=['max radius: ' num2str(max(abs(Y)))];
        title(T);
        axis equal;
        axis off;
subplot(2,2,2)
        hold on;
        r=linspace(0,2*pi,1000);
        a=exp(i*r);
        plot(real(a),imag(a),'k-');
        plot(real(Y./abs(Y)),imag(Y./abs(Y)),'.');
        for k=1:length(Y)
            text(real(Y(k))./abs(Y(k)),imag(Y(k))./abs(Y(k)),num2str(k),'FontSize',7);        
            plot([0, real(Y(k)./abs(Y(k)))],[0 imag(Y(k)./abs(Y(k)))],'-');
        end
        plot([-1.2 1.2],[0 0],'k--');
        plot([0 0],[-1.2 1.2],'k--');
        title(['Normalized directions'])
        axis equal;
        axis tight;
        axis off;
subplot(2,2,3)
        hist(abs(Y));
        title('Distribution of amplitudes');
        axis tight;
subplot(2,2,4)
        hist(imag(log(Y)));
        title('Distribution of angles');
        axis tight;        




% --- Executes on button press in dstrmax.
function dstrmax_Callback(hObject, eventdata, handles)
% hObject    handle to dstrmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of dstrmax
confbut_Callback(hObject, eventdata, handles)



% --- Executes on button press in sITPC.
function sITPC_Callback(hObject, eventdata, handles)
% hObject    handle to sITPC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of sITPC
erpcohbut_Callback(hObject, eventdata, handles);



% --- Executes on button press in Nospline.
function Nospline_Callback(hObject, eventdata, handles)
% hObject    handle to Nospline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Nospline




% --- Executes on button press in Tucker.
function Tucker_Callback(hObject, eventdata, handles)
% hObject    handle to Tucker (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Tucker




% --------------------------------------------------------------------
function Dendrogram_Callback(hObject, eventdata, handles)
% hObject    handle to Dendrogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

carray=createarray(hObject,handles,0);
carray=matrizicing(carray,3);

% create distance
for i=1:size(carray,1);
    disp(['Create distance metrik ' num2str(i) '/' num2str(size(carray,1))]);
    for j=i:size(carray,1)
        D(i,j)=norm(carray(i,:)-carray(j,:),'fro');
    end
end
Y=[];
for k=1:(size(D,1)-1)
    Y=[Y,D(k,(k+1):size(D,1))];
end
Z=linkage(Y,'average');
figure;
[H,T]=dendrogram(Z,size(D,1),'orientation','right','labels', handles.filenamelist);




function maxiter_Callback(hObject, eventdata, handles)
% hObject    handle to maxiter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxiter as text
%        str2double(get(hObject,'String')) returns contents of maxiter as a double


% --- Executes during object creation, after setting all properties.
function maxiter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxiter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in inctopmont.
function inctopmont_Callback(hObject, eventdata, handles)
% hObject    handle to inctopmont (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of inctopmont
Plotmontage(hObject);


function tw_Callback(hObject, eventdata, handles)
% hObject    handle to tw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tw as text
%        str2double(get(hObject,'String')) returns contents of tw as a double


% --- Executes during object creation, after setting all properties.
function tw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%-------------------------------------------------------------------------
function th_Callback(hObject, eventdata, handles)
% hObject    handle to th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of th as text
%        str2double(get(hObject,'String')) returns contents of th as a double


% --- Executes during object creation, after setting all properties.
function th_CreateFcn(hObject, eventdata, handles)
% hObject    handle to th (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%-------------------------------------------------------------------------
function calconf(hObject)
% Internal function to calculate confidence
handles=guidata(hObject);
measure=getmeasure(hObject);

SL=str2num(get(handles.slevel,'string'));
% Correct significance level for distribution of max
if get(handles.dstrmax,'value')
    SL=SL^(1/prod(nr_points_disp(hObject)));
end

if get(handles.anovabut,'value') % Check if significance is given for test diff.
    if strcmp(handles.testtype,'ANOVA')
        X=finv(SL,handles.K-1,handles.K*(handles.S-1));
    else
        X = chi2inv(SL,handles.K*(handles.S-1));
    end
    set(handles.a2lim,'value',0);
    set(handles.cmin,'String',num2str(X));
    set(handles.cmax,'String',num2str(max(handles.Y(:))));
    guidata(hObject,handles);
    Plotmontage(hObject);
    Topheadplot(hObject);
else % Significance of other measures
    if (measure(1)==1 | measure(3)==1) & get(handles.rayleigh,'value')
        % Theoretical Rayleigh distribution
        if ~isfield(handles,'sigma') 
          handles.sigma=calcsigma(hObject);  
        end
        handles.QnU=sqrt(-2*handles.sigma^2*log(1-SL));
        handles.QnU=handles.QnU*ones(size(handles.Y,1),size(handles.Y,2));
        handles.QnL=0*handles.QnU;
        set(handles.sleveltxt,'String',['Cut off ' num2str(handles.QnU(1))]);
        set(handles. sleveltxt,'visible','on');
        guidata(hObject,handles);   
    else % Bootstrap
       set(handles.sleveltxt,'visible','off');
       calcbootstrap(hObject);
    end
end

%-------------------------------------------------------------------------
function slevel_Callback(hObject, eventdata, handles)
% hObject    handle to slevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of slevel as text
%        str2double(get(hObject,'String')) returns contents of slevel as a double
ss=get(handles.rejectERPCOHphase,'Checked');
if get(handles.erpcohbut,'value') & ss(2)=='n'
    CalculateYh(hObject);
end
if get(handles.confbut,'value')
    calconf(hObject);
end
Plotmontage(hObject);
Topheadplot(hObject);



function bsize_Callback(hObject, eventdata, handles)
% hObject    handle to bsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bsize as text
%        str2double(get(hObject,'String')) returns contents of bsize as a double


% --- Executes during object creation, after setting all properties.
function bsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in confbut.
function confbut_Callback(hObject, eventdata, handles)
% hObject    handle to confbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.confbut,'value')
    slevel_Callback(hObject, eventdata, handles);
else
    set(handles.sleveltxt,'visible','off');
end
Plotmontage(hObject);
Topheadplot(hObject);



% --------------------------------------------------------------------
function mail_Callback(hObject, eventdata, handles)
% hObject    handle to mail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web http://www.erpwavelab.org/Page460.htm

% --------------------------------------------------------------------
function tutorial_Callback(hObject, eventdata, handles)
% hObject    handle to tutorial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=which('ERPWAVELAB.m');
s=s(1:end-length('ERPWAVELAB.m'));
tutpath = [s 'Tutorial' s(end) 'index.htm'];
web(tutpath,'-helpbrowser')

% --------------------------------------------------------------------
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=which('ERPWAVELAB.m');
s=s(1:end-length('ERPWAVELAB.m'));
helppath = [s 'Help' s(end) 'index.htm'];
web(helppath,'-helpbrowser')

% --------------------------------------------------------------------
function noresp_Callback(hObject, eventdata, handles)
% hObject    handle to noresp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function sC_Callback(hObject, eventdata, handles)
% hObject    handle to sC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sC as text
%        str2double(get(hObject,'String')) returns contents of sC as a double


% --- Executes during object creation, after setting all properties.
function sC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function sCH_Callback(hObject, eventdata, handles)
% hObject    handle to sCH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sCH as text
%        str2double(get(hObject,'String')) returns contents of sCH as a double


% --- Executes during object creation, after setting all properties.
function sCH_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sCH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sSC_Callback(hObject, eventdata, handles)
% hObject    handle to sSC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sSC as text
%        str2double(get(hObject,'String')) returns contents of sSC as a double


% --- Executes during object creation, after setting all properties.
function sSC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sSC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in mfsch.
function mfsch_Callback(hObject, eventdata, handles)
% hObject    handle to mfsch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mfsch

Plotmontage(hObject,10);


% --------------------------------------------------------------------
function distrcurppoint_Callback(hObject, eventdata, handles)
% hObject    handle to distrcurppoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Displays the distribution of the curretnly selected measure at current
% point
measure=getmeasure(hObject);
ss=get(handles.sITPC,'Value');
if measure(3) & ss % Substract ITPC activity from ERPCOH
    measure(3)=2; 
end

if ~get(handles.useall,'value') % Measure over multiple files
    f=m2mp(handles.Fa, str2num(get(handles.fr,'String')));
    t=m2mp(handles.tim, str2num(get(handles.tm,'String')));
    ch=get(handles.ch,'value');
    if get(handles.utpoint,'Value') & isfield(handles,'plotsit')
        f2=m2mp(handles.Fa, handles.plotsit(2));
        t2=m2mp(handles.tim, handles.plotsit(3));
    else
        f2=f;
        t2=t;
    end
    if isfield(handles,'plotsit')
         ch2=find(handles.chantoanal==handles.plotsit(1));
    else
        ch2=ch;
    end
    if get(handles.epochbut,'value')
        Y=squeeze(handles.WT(:,f,t,ch));
        Y2=squeeze(handles.WT(:,f2,t2,ch2));
    else
        Y=squeeze(handles.WT(ch,f,t,:));
        Y2=squeeze(handles.WT(ch2,f2,t2,:));
    end
    bootstrapjknife(Y,measure,str2num(get(handles.bsize,'String')),Y2);
else % Measure taken on single file   
    Y=[];
    Y2=[];
    for k=1:length(handles.filenamelist)
        clear handles.WT;
        clear handles.Y;
        handles.filename=handles.filenamelist{k};
        handles.pathname=handles.pathnamelist{k};
        disp(['Processing: ' handles.filename]);
        guidata(hObject,handles);
        loadit(hObject)
        handles=guidata(hObject);
        clear handles.X;
        guidata(hObject,handles);
        CalculateY(hObject);
        handles=guidata(hObject);   
        f=m2mp(handles.Fa, str2num(get(handles.fr,'String')));
        t=m2mp(handles.tim, str2num(get(handles.tm,'String')));
        ch=get(handles.ch,'Value');
        if get(handles.utpoint,'Value') & isfield(handles,'plotsit')
            f2=m2mp(handles.Fa, handles.plotsit(2));
            t2=m2mp(handles.tim, handles.plotsit(3));
        else
            f2=f;
            t2=t;
        end
        if isfield(handles,'plotsit')
            ch2=find(handles.chantoanal==handles.plotsit(1));
        else
            ch2=ch;
        end
        Y(end+1:end+size(handles.WT,4))=handles.WT(ch,f,t,:);
        Y2(end+1:end+size(handles.WT,4))=handles.WT(ch2,f2,t2,:);
    end
    bootstrapjknife(Y,measure,str2num(get(handles.bsize,'String')),Y2);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function measure=getmeasure(hObject)
% Internal function extracting what measure is selected

handles=guidata(hObject);
measure(1)=get(handles.itpcbut,'value');
measure(2)=get(handles.erspbut,'value');
measure(3)=get(handles.erpcohbut,'value');
measure(4)=get(handles.avWTbut,'value');
measure(5)=get(handles.inducedbut,'value');
measure(6)=get(handles.WTavbut,'value');
if handles.cohtype==2
    measure(7)=1;
elseif handles.cohtype==3
    measure(7)=2;    
else
    measure(7)=0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sigma=calcsigma(hObject)
% Internal function calculating sigma of the Rayleigh distribution by
% bootstrapping over random samples.
handles=guidata(hObject);
if handles.nrepoch<1000
    N=500;
else
    N=100;
end
for k=1:20
    sample=abs(mean(exp(i*2*pi*rand(N,handles.nrepoch)),2));
    sigma(k)=sqrt(1/(2*N)*sum(sample.^2));
end
sigma=mean(sigma);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nsamplepoint=nr_points_disp(hObject);
% Internal function extracting the number of sample points present in the
% Montageplot used for distribution of Max.
handles=guidata(hObject);
t1=str2num(get(handles.fromt,'String'));
t2=str2num(get(handles.tot,'String'));
fr1=str2num(get(handles.fromf,'String'));
fr2=str2num(get(handles.tof,'String'));
tm1=m2mp(handles.tim,t1);
tm2=m2mp(handles.tim,t2);
ntim=(tm2-tm1+1);
f1=m2mp(handles.Fa,fr1);
f2=m2mp(handles.Fa,fr2);
nfre=(f2-f1+1);
nch=min([length(handles.act_chan_ind),str2num(get(handles.rows,'String'))*str2num(get(handles.columns,'String'))]);
if get(handles.mfsch,'value')
    nch=nch-get(handles.ch,'value')+1;
end
nsamplepoint=[nch nfre ntim];


% --------------------------------------------------------------------
function normal_Callback(hObject, eventdata, handles)
% hObject    handle to normal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function finv_Callback(hObject, eventdata, handles)
% hObject    handle to finv (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
unnormalize(hObject);
handles=guidata(hObject);
set(handles.finv,'Checked','on');
set(handles.normback,'Checked','off');
set(handles.nonorm,'Checked','off');
guidata(hObject,handles);
normalize(hObject);
CalculateYh(hObject);
Plotmontage(hObject);
Topheadplot(hObject);


% --------------------------------------------------------------------
function normback_Callback(hObject, eventdata, handles)
% hObject    handle to normback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

unnormalize(hObject);
handles=guidata(hObject);
set(handles.finv,'Checked','off');
set(handles.normback,'Checked','on');
set(handles.nonorm,'Checked','off');
a.tim=handles.tim;
a.txt='Define background region';
if isfield(handles,'bt1')
    a.v1=handles.bt1;
    a.v2=handles.bt2;
end
H=defbackground(a);
uiwait(H);
handlesd=guidata(H);
handles.bt1=handlesd.s1;
handles.bt2=handlesd.s2;
close('defbackground')
guidata(hObject,handles);
normalize(hObject);
CalculateYh(hObject);
Plotmontage(hObject);
Topheadplot(hObject);


% --------------------------------------------------------------------
function nonorm_Callback(hObject, eventdata, handles)
% hObject    handle to nonorm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
unnormalize(hObject);
handles=guidata(hObject);
set(handles.finv,'Checked','off');
set(handles.normback,'Checked','off');
set(handles.nonorm,'Checked','on');
guidata(hObject,handles);
CalculateYh(hObject);
Plotmontage(hObject);
Topheadplot(hObject);

% --------------------------------------------------------------------
function normalize(hObject);

% Internal function performing Pre-normalization

handles=guidata(hObject);
ss1=get(handles.finv,'Checked');
ss2=get(handles.normback,'Checked');
ss3=get(handles.nonorm,'Checked');
measure=getmeasure(hObject);
if ss1(2)=='n'
    handles.WT=handles.WT.*repmat(handles.Fa,[size(handles.WT,1) 1 size(handles.WT,3) size(handles.WT,4)]); 
elseif ss2(2)=='n'
    if ~isfield(handles,'bt1')
        a.tim=handles.tim;
        a.txt='Define background region';
        H=defbackground(a);
        uiwait(H);
        handlesd=guidata(H);
        handles.bt1=handlesd.s1;
        handles.bt2=handlesd.s2;
        close('defbackground')
    end
    handles.normQ=mean(abs(handles.WT(:,:,handles.bt1:handles.bt2,:)),3);
    handles.WT=handles.WT./repmat(handles.normQ,[1,1,size(handles.WT,3), 1]);      
end
guidata(hObject,handles);

% --------------------------------------------------------------------
function unnormalize(hObject);
% Internal function undoing normalization (function right above) to reduce
% computation time by avoiding to have to reload dataset.
handles=guidata(hObject);
ss1=get(handles.finv,'Checked');
ss2=get(handles.normback,'Checked');
ss3=get(handles.nonorm,'Checked');
measure=getmeasure(hObject);
if ss1(2)=='n'
    handles.WT=handles.WT./repmat(handles.Fa,[size(handles.WT,1) 1 size(handles.WT,3) size(handles.WT,4)]); 
elseif ss2(2)=='n'
    set(handles.finv,'Checked','off');
    set(handles.normback,'Checked','off');
    set(handles.nonorm,'Checked','on');
    handles.WT=handles.WT.*repmat(handles.normQ,[1,1,size(handles.WT,3), 1]);
end
guidata(hObject,handles);

% --- Executes on button press in epochbut.
function epochbut_Callback(hObject, eventdata, handles)
% hObject    handle to epochbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of epochbut
if ~get(handles.epochbut,'value')
	set(handles.postnmlz,'enable','on')
    epochs=str2num(get(handles.channels,'String'));
    if ~isempty(epochs)
        pos_size = get(handles.ERPWAVELAB,'Position');
        % Call modaldlg with the argument 'Position'.
        user_response = rejectepochs('Title','Do you want to remove marked epochs');
        switch user_response
        case {'No'}
            % take no action
        case 'Yes'
            % Prepare to close GUI application window
            chanlocs=handles.chanlocsold;
            guidata(hObject,handles);
            unnormalize(hObject);
            handles=guidata(hObject);
            tim=handles.tim;
            Fs=handles.Fs;
            Fa=handles.Fa;
            WT=permute(handles.WT,[4 2 3 1]);
            ep=getChannels(handles.chantoanal,epochs);
            WT=WT(:,:,:,ep);
            nepoch=handles.nepoch;
            wavetyp=handles.wavetyp;
            [fname, pname]=uiputfile('.mat','Save new dataset as');
            save([pname fname],'chanlocs','tim','Fs','Fa','tim','WT','nepoch','wavetyp');
            handles.filename=fname;
            handles.pathname=pname;
            n=get(handles.files,'value');
            handles.filenamelist{n}=handles.filename;        % list of name of files
            handles.pathnamelist{n}=handles.pathname;        % list of path to files
            set(handles.files,'String',handles.filenamelist);
        end 
    end
    set(handles.NMFbut,'Visible','on');
    set(handles.nmf2,'String','Ch x Fr-Time-Subj/cond');
    set(handles.parafacbut,'String','Ch x Fr-Time x Subj/cond');
    set(handles.erpcohbut,'String','ERPCOH');
    set(handles.inducedbut,'String','Induced');
    set(handles.itpcbut,'String','ITPC');
    handles=setmeasurebut(handles);
    set(handles.confbut,'enable','on');
    set(handles.slevel,'enable','on');
    set(handles.itpcbut,'Visible','on');
    set(handles.anovabut,'Visible','on');
    set(handles.text23,'Visible','on');
    set(handles.text24,'Visible','on');
    set(handles.tw,'Visible','on');
    set(handles.th,'Visible','on');
    set(handles.erpcohbut,'Visible','on');
    set(handles.erspbut,'Visible','on');
    set(handles.avWTbut,'Visible','on');
    set(handles.WTavbut,'Visible','on');
    set(handles.inducedbut,'Visible','on');
    set(handles.utpoint,'Visible','on');
    set(handles.sfase,'Visible','on');
    set(handles.sITPC,'Visible','on');
    set(handles.chepoch,'Visible','off');
    set(handles.mfsch,'String','Start montage from selected channel');
    set(handles.rmch,'String','Remove Channels');
    set(handles.chtxt,'String','Channel');
    set(handles.ch2pop,'Visible','off');
    set(handles.inctopmont,'enable','on');
    set(handles.useall,'enable','on');
    set(handles.distrcurppoint,'enable','on');
    set(handles.saveses,'enable','on');
    set(handles.loadses,'enable','on');
    set(handles.Dendrogram,'enable','on');
    set(handles.channels,'String',handles.chrem);
    if isfield(handles,'normQ')
       handles.normQ=permute(handles.normQ,[4 2 3 1]);
    end
    if length(handles.filenamelist)>1
        set(handles.parafacbut,'enable','on')
        set(handles.nmf2,'enable','on')
    else
        set(handles.parafacbut,'enable','off')
        set(handles.nmf2,'enable','off')
    end
    handles.measure=handles.measureold;
    handles=setmeasurebut(handles);
    guidata(hObject,handles);
    files_Callback(hObject,[],handles);   
else
    set(handles.confbut,'value',0);
    set(handles.NMFbut,'Visible','off');
    set(handles.nmf2,'String','Ch x Fr-Time-Epoch');
    set(handles.parafacbut,'String','Ch x Fr-Time x Epoch');
    set(handles.erpcohbut,'String','Amplitude');
    set(handles.erpcohbut,'Value',1);
    set(handles.inducedbut,'Value',0);
    set(handles.itpcbut,'Value',0);
    set(handles.inducedbut,'String','abs(STD)');
    set(handles.itpcbut,'String','POWER');
    set(handles.confbut,'enable','off');
    set(handles.slevel,'enable','off');
  	set(handles.postnmlz,'enable','off')
    set(handles.mfsch,'String','Start montage from selected epoch');
    set(handles.anovabut,'Visible','off');
    set(handles.text23,'Visible','off');
    set(handles.text24,'Visible','off');
    set(handles.tw,'Visible','off');
    set(handles.th,'Visible','off');
    set(handles.erspbut,'Visible','off');
    set(handles.avWTbut,'Visible','off');
    set(handles.WTavbut,'Visible','off');
    set(handles.sfase,'Visible','off');
    set(handles.chepoch,'Visible','on');
    set(handles.utpoint,'Visible','off');
    set(handles.sITPC,'Visible','off');
    set(handles.distrcurppoint,'enable','off');
    set(handles.rmch,'String','Remove epochs');
    handles.chrem=get(handles.channels,'String');
    set(handles.channels,'String','')
    handles.WT=permute(handles.WT,[4,2,3,1]);
    handles.act_chan_ind=1:size(handles.WT,1);
    handles.chantoanal=handles.act_chan_ind;
    handles.chanlocsold=handles.chanlocs;
    handles.chvalold=get(handles.ch,'value');
    handles.measureold=handles.measure;
    set(handles.parafacbut,'enable','on')
    set(handles.nmf2,'enable','on')
    set(handles.useall,'enable','off');
    set(handles.useall,'value',0);
    set(handles.saveses,'enable','off');
    set(handles.loadses,'enable','off');
    set(handles.Dendrogram,'enable','off');
    
    for k=1:size(handles.WT,1)
        handles.chanlocs(k).labels=num2str(k);
        epochs{k}=handles.chanlocs(k).labels;
    end
    for k=1:length(handles.chanlocsold)
        channels{k}=handles.chanlocsold(k).labels;
    end
    set(handles.ch,'Value',1);
    set(handles.ch,'String',epochs);
    set(handles.chtxt,'String','Epoch');
    set(handles.ch2pop,'Visible','on');
    set(handles.ch2pop,'String',channels);
    set(handles.inctopmont,'Value',0);
    set(handles.inctopmont,'enable','off');
    if isfield(handles,'normQ')
       handles.normQ=permute(handles.normQ,[4 2 3 1]);
    end
    guidata(hObject,handles);
    CalculateYh(hObject);
    Plotmontage(hObject);
    Topheadplot(hObject);
end


% --- Executes on selection change in ch2pop.
function ch2pop_Callback(hObject, eventdata, handles)
% hObject    handle to ch2pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ch2pop contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ch2pop
CalculateYh(hObject);
Plotmontage(hObject)


% --- Executes during object creation, after setting all properties.
function ch2pop_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch2pop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --------------------------------------------------------------------
function nbcka_Callback(hObject, eventdata, handles)
% hObject    handle to nbcka (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.nbcka,'checked','on');
set(handles.nonormpost,'checked','off');
set(handles.rayleigh,'enable','off');
set(handles.rayleigh,'value',0);
set(handles.bstrp,'value',1);

guidata(hObject,handles);
checkRejectPhase(hObject);
CalculateYh(hObject);
Plotmontage(hObject);
Topheadplot(hObject);


% --------------------------------------------------------------------
function nonormpost_Callback(hObject, eventdata, handles)
% hObject    handle to nonormpost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.nbcka,'checked','off');
set(handles.nonormpost,'checked','on');
if strcmp(handles.measure,'ITPC') | strcmp(handles.measure,'ITLC') strcmp(handles.measure,'ERPCOH') | strcmp(handles.measure,'ERLCOH')
    set(handles.rayleigh,'enable','on');
end

guidata(hObject,handles);
checkRejectPhase(hObject);
CalculateYh(hObject);
Plotmontage(hObject);
Topheadplot(hObject);


% --------------------------------------------------------------------
function postnormalize(hObject);

% Internal function post normalizing each measure, i.e. normalizing it
% according to activity of specified background region
handles=guidata(hObject);
ss1=get(handles.nbcka,'checked');
if ss1(2)=='n' & ~get(handles.epochbut,'value')
    a.tim=handles.tim;
    a.txt='Background sample region';
    if isfield(handles,'bt1')
        a.v1=handles.bt1;
        a.v2=handles.bt2;
    end
    H=defbackground(a);
    uiwait(H);
    handlesd=guidata(H);
    handles.bt1=handlesd.s1;
    handles.bt2=handlesd.s2;
    close('defbackground')
    handles.pnormfact=mean(abs(handles.Y(:,:,handles.bt1:handles.bt2)),3);
    handles.Y=handles.Y./repmat(handles.pnormfact,[1 1 size(handles.Y,3)]);
    guidata(hObject,handles);
else
    guidata(hObject,handles);
end

% --------------------------------------------------------------------
function calcbootstrap(hObject);
% Internal function performing the boostrapping
measure=getmeasure(hObject);
handles=guidata(hObject);
% Define background region
a.tim=handles.tim;
a.txt='Bootstrap sample region';
if isfield(handles,'boot1')
    a.v1=handles.boot1;
    a.v2=handles.boot2;
    if isfield(handles,'chpboot')
        a.chpboot=handles.chpboot;
    end
end
H=defbackground(a);
uiwait(H);
handlesd=guidata(H);
handles.boot1=handlesd.s1;
handles.boot2=handlesd.s2;
handles.chpboot=get(handlesd.chpboot,'value');
close('defbackground')

Bsize=str2num(get(handles.bsize,'String'));
SL=str2num(get(handles.slevel,'String'));
if get(handles.dstrmax,'value')
    SL=SL^(1/prod(nr_points_disp(hObject)));
end
sITPC=get(handles.sITPC,'Value');
nbcka=get(handles.nbcka,'Checked');
if nbcka(2)=='n'
    NW=handles.pnormfact;
else
    sWT=size(handles.WT);
    NW=ones(sWT(1:2));
end
cop=getCohInfo(handles);

[handles.QnU, handles.QnL]=bootstrapSL(handles.WT(:,:,handles.boot1:handles.boot2,:),measure,Bsize,SL,handles.chpboot,handles.nrepoch,cop,sITPC);
guidata(hObject,handles);




% --------------------------------------------------------------------
function normalization_Callback(hObject, eventdata, handles)
% hObject    handle to normalization (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --------------------------------------------------------------------
function savecurrROI_Callback(hObject, eventdata, handles)
% hObject    handle to savecurrROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
unnormalize(hObject);
handles=guidata(hObject);
t1p=m2mp(handles.tim,str2num(get(handles.fromt,'String')));
t2p=m2mp(handles.tim,str2num(get(handles.tot,'String')));
fr1p=m2mp(handles.Fa,str2num(get(handles.fromf,'String')));
fr2p=m2mp(handles.Fa,str2num(get(handles.tof,'String')));
tim=handles.tim(t1p:t2p);
Fs=handles.Fs;
Fa=handles.Fa(fr1p:fr2p);
WT=handles.WT(handles.act_chan_ind,fr1p:fr2p,t1p:t2p,:);
chanlocs=handles.chanlocs(handles.act_chan_ind);
nepoch=handles.nepoch;
wavetyp=handles.wavetyp;
[fname, pname]=uiputfile('.mat','Save new dataset as')
save([pname fname],'chanlocs','tim','Fs','Fa','tim','WT','nepoch','wavetyp');
handles.filename=fname;
handles.pathname=pname;
n=get(handles.files,'value');
handles.filenamelist{n}=handles.filename;        % list of name of files
handles.pathnamelist{n}=handles.pathname;        % list of path to files
set(handles.files,'String',handles.filenamelist);
guidata(hObject,handles);
files_Callback(hObject,[],handles);   




%----------------------------------------------------------------------
function topplot_mousepress(src,event,hObject)
handles=guidata(hObject);
if get(handles.epochbut,'value')
    radius=handles.chanlocsold(1).radius;    
    radius=0.7*[handles.chanlocsold(:).radius];
    x=[radius.*sin([handles.chanlocsold(:).theta]/180*pi)];
    y=[radius.*cos([handles.chanlocsold(:).theta]/180*pi)];
else
    radius=handles.chanlocs(1).radius;    
    radius=0.7*[handles.chanlocs(:).radius];
    x=[radius.*sin([handles.chanlocs(handles.act_chan_ind).theta]/180*pi)];
    y=[radius.*cos([handles.chanlocs(handles.act_chan_ind).theta]/180*pi)];
end
ppl=[x' y'];
cp=get(handles.Topoplot,'CurrentPoint');
pos=cp([1,3]);
dist=sum((ppl-repmat(pos,[size(ppl,1) ,1])).^2,2);
[Y,k]=min(dist);
if get(handles.epochbut,'value')
     set(handles.ch2pop,'value',k);
     guidata(hObject,handles);
     CalculateYh(hObject);
else
    set(handles.ch,'value',k);    
    guidata(hObject,handles);
    ch_Callback(hObject, [], handles)
end

%------------------------------------------------------------
function headplot_mousepress(src,event,hObject)
handles=guidata(hObject);
V=get(handles.Headplot,'Children');
axes(V(1));
rotate3d on;



% --- Executes on button press in rayleigh.
function rayleigh_Callback(hObject, eventdata, handles)
% hObject    handle to rayleigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rayleigh
set(handles.rayleigh,'value',1);
set(handles.bstrp,'value',0);
if get(handles.confbut,'value')
    slevel_Callback(hObject, eventdata, handles)
end

% --- Executes on button press in bstrp.
function bstrp_Callback(hObject, eventdata, handles)
% hObject    handle to bstrp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bstrp
set(handles.rayleigh,'value',0);
set(handles.bstrp,'value',1);
if get(handles.confbut,'value')
    slevel_Callback(hObject, eventdata, handles)
end

%-----------------------------------------------------------
function handles=setmeasurebut(handles)
% Internal function that sets the button in GUI to handles.measure
set(handles.erpcohbut,'value',0)
set(handles.anovabut,'value',0)
set(handles.itpcbut,'Value',0);
set(handles.erspbut,'Value',0);
set(handles.inducedbut,'Value',0);
set(handles.avWTbut,'Value',0);
set(handles.WTavbut,'Value',0);


if strcmp(handles.measure,'ANOVA')
    set(handles.distrcurppoint,'enable','off');
    set(handles.confbut,'enable','off')
    set(handles.confbut,'value',0)
    set(handles.nbcka,'enable','on')
    set(handles.anovabut,'value',1);
    set(handles.rcc,'enable','off');
    set(handles.sleveltxt,'visible','off');
elseif strcmp(handles.measure,'ITPC')
    set(handles.distrcurppoint,'enable','on');    
    set(handles.confbut,'enable','on')
    set(handles.itpcbut,'Value',1);
    set(handles.nbcka,'enable','on');
%   set(handles.nbcka,'checked','off');
%    set(handles.nonormpost,'checked','on');
    set(handles.rcc,'enable','off');
    set(handles.rayleigh,'enable','on');
    if ~get(handles.epochbut,'value')
        set(handles.cch,'Visible','off');
        set(handles.cfr,'Visible','off');
        set(handles.ctm,'Visible','off');
        set(handles.erpcohpt,'Visible','off');
    end

elseif strcmp(handles.measure,'INDUCED');
    set(handles.distrcurppoint,'enable','on');
    set(handles.confbut,'enable','on')
    set(handles.inducedbut,'Value',1);
    set(handles.rcc,'enable','off');
    set(handles.sleveltxt,'visible','off');
    set(handles.nbcka,'enable','on');
    set(handles.rayleigh,'enable','off');
    set(handles.bstrp,'Value',1)
    if ~get(handles.epochbut,'value')
        set(handles.cch,'Visible','off');
        set(handles.cfr,'Visible','off');
        set(handles.ctm,'Visible','off');
        set(handles.erpcohpt,'Visible','off');
    end

elseif strcmp(handles.measure,'avWT')
    set(handles.distrcurppoint,'enable','on');
    set(handles.confbut,'enable','on')
    set(handles.nbcka,'enable','on');
    set(handles.avWTbut,'Value',1);
    set(handles.rcc,'enable','off');
    set(handles.sleveltxt,'visible','off');
    set(handles.rayleigh,'enable','off');
    set(handles.bstrp,'Value',1)
    set(handles.cch,'Visible','off');
    set(handles.cfr,'Visible','off');
    set(handles.ctm,'Visible','off');
    set(handles.erpcohpt,'Visible','off');

elseif strcmp(handles.measure,'WTav')
    set(handles.distrcurppoint,'enable','on');
    set(handles.confbut,'enable','on')
    set(handles.nbcka,'enable','on');
    set(handles.WTavbut,'Value',1);
    set(handles.rcc,'enable','off');
    set(handles.sleveltxt,'visible','off');
    set(handles.rayleigh,'enable','off');
    set(handles.bstrp,'Value',1)
    set(handles.cch,'Visible','off');
    set(handles.cfr,'Visible','off');
    set(handles.ctm,'Visible','off');
    set(handles.erpcohpt,'Visible','off');

elseif strcmp(handles.measure,'ERPCOH')
    if handles.cohtype==3
        set(handles.confbut,'enable','off')
        set(handles.confbut,'value',0)
        set(handles.distrcurppoint,'enable','off');
    else
        set(handles.confbut,'enable','on')
        set(handles.distrcurppoint,'enable','on');
    end
    set(handles.nbcka,'enable','on');
%    set(handles.nbcka,'checked','off');
%    set(handles.nonormpost,'checked','on');
    set(handles.erpcohbut,'value',1);
    set(handles.rcc,'enable','on');
    if ~get(handles.epochbut,'value')    
        if get(handles.sITPC,'value')
            set(handles.bstrp,'value',1);
            set(handles.rayleigh,'value',0);
            set(handles.rayleigh,'enable','off');
        else
            set(handles.rayleigh,'enable','on');    
        end
        set(handles.cch,'Visible','on');
        set(handles.erpcohpt,'Visible','on');
        if get(handles.utpoint,'Value')
            set(handles.ctm,'Visible','on');
        end
        if get(handles.ufpoint,'Value')    
            set(handles.cfr,'Visible','on');
        end
        set(handles.cch,'String',handles.chanlocs(handles.act_chan_ind(get(handles.ch,'Value'))).labels);
        if get(handles.utpoint,'Value')
            set(handles.cfr,'String',get(handles.fr,'String'));
            set(handles.ctm,'String',get(handles.tm,'String'));
        end
        handles.plotsit=[get(handles.ch,'Value') str2num(get(handles.fr,'String')) str2num(get(handles.tm,'String'))];
        handles.plotsithist{end+1}=handles.plotsit;
    end

elseif strcmp(handles.measure,'ERSP')
    set(handles.distrcurppoint,'enable','on');
    set(handles.confbut,'enable','on')
    set(handles.nbcka,'enable','on');
    set(handles.erspbut,'Value',1);    
    set(handles.rcc,'enable','off');
    set(handles.sleveltxt,'visible','off');
    set(handles.rayleigh,'enable','off');
    set(handles.bstrp,'Value',1);
    set(handles.cch,'Visible','off');
    set(handles.cfr,'Visible','off');
    set(handles.ctm,'Visible','off');
    set(handles.erpcohpt,'Visible','off');
end

%----------------------------------------------------------------
function Y=calepochmeas(handles,ch)
% Internal function, help function to CalculateY specialized for when epochbut is active
if nargin<2
    ch=1:size(handles.WT,4);
end
if get(handles.erpcohbut,'value')
    Y=handles.WT(:,:,:,ch);
elseif get(handles.inducedbut,'value')
    T=abs(handles.WT(:,:,:,ch));
    Y=(T-repmat(mean(T,1),[size(T,1), 1, 1, 1]))./(repmat(std(T(handles.act_chan_ind,:,:,:),[],1),[size(T,1), 1, 1, 1])+eps);
elseif get(handles.itpcbut,'value')
    Y=handles.WT(:,:,:,ch).*conj(handles.WT(:,:,:,ch));
end

%----------------------------------------------------------------
function Y=calepochmeaschannel(handles,fr,tm,epoch)
% Internal function, help function to CalculateY specialized for when epochbut is active to
% plot channel activation in Topheadplot
if get(handles.erpcohbut,'value')
    Y=handles.WT(epoch,fr,tm,:);
elseif get(handles.inducedbut,'value')
    T=squeeze(abs(handles.WT(:,fr,tm,:)));
    Y=(T(epoch,:)-mean(T,1))./squeeze(std(T(handles.act_chan_ind,:),[],1)+eps);
elseif get(handles.itpcbut,'value')
    Y=handles.WT(epoch,fr,tm,:).*conj(handles.WT(epoch,fr,tm,:));
end

%----------------------------------------------------------------
function [sl, sigma]=crosscohsignificance(hObject,val)
% Internal function that calculates significance of ERPCOH coherence arrows
handles=guidata(hObject);
if ~isfield(handles,'sigma') 
  handles.sigma=calcsigma(hObject);  
end
sl=exp(-val^2/(2*handles.sigma^2));
if get(handles.dstrmax,'value')
    sl=sl^(1/prod(nr_points_disp(hObject)));
end
sigma=handles.sigma;


% --------------------------------------------------------------------
function lincoh_Callback(hObject, eventdata, handles)
% hObject    handle to lincoh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lincoh,'Checked','on');
set(handles.phasecoh,'Checked','off');
set(handles.ampcorr,'checked','off');
handles.cohtype=2;
set(handles.itpcbut,'String','ITLC');
set(handles.erpcohbut,'String','ERLCOH');
set(handles.sITPC,'enable','off');
set(handles.rayleigh,'enable','on');
handles=setmeasurebut(handles);
guidata(hObject,handles);
checkRejectPhase(hObject);
if (get(handles.erpcohbut,'value') | get(handles.itpcbut,'value')) & isfield(handles,'WT')
     CalculateYh(hObject);
end        


% --------------------------------------------------------------------
function phasecoh_Callback(hObject, eventdata, handles)
% hObject    handle to phasecoh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.lincoh,'Checked','off');
set(handles.phasecoh,'Checked','on');
set(handles.ampcorr,'checked','off');
handles.cohtype=1;
set(handles.itpcbut,'String','ITPC');
set(handles.erpcohbut,'String','ERPCOH');
set(handles.sITPC,'enable','on');
if get(handles.sITPC,'value')
    set(handles.rayleigh,'enable','off');
else
    set(handles.rayleigh,'enable','on');
end
handles=setmeasurebut(handles);
guidata(hObject,handles);
checkRejectPhase(hObject);
if (get(handles.erpcohbut,'value') | get(handles.itpcbut,'value')) & isfield(handles,'WT')
     CalculateYh(hObject);
end        


% --------------------------------------------------------------------
function ampcorr_Callback(hObject, eventdata, handles)
% hObject    handle to ampcorr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.lincoh,'Checked','off');
set(handles.phasecoh,'Checked','off');
set(handles.ampcorr,'checked','on');
handles.cohtype=3;
set(handles.itpcbut,'String','ITPC');
set(handles.erpcohbut,'String','AmpCorr');
set(handles.sITPC,'enable','off');
handles=setmeasurebut(handles);
guidata(hObject,handles);
checkRejectPhase(hObject);
if (get(handles.erpcohbut,'value') | get(handles.itpcbut,'value')) & isfield(handles,'WT')
     CalculateYh(hObject);
end        



% --------------------------------------------------------------------
function contERPWAVELAB_Callback(hObject, eventdata, handles)
% hObject    handle to contERPWAVELAB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('www.erpwavelab.org');

% --------------------------------------------------------------------
function rejectERPCOHphase_Callback(hObject, eventdata, handles)
% hObject    handle to rejectERPCOHphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nn=get(handles.rejectERPCOHphase,'Checked');
if nn(2)=='n'
    set(handles.rejectERPCOHphase,'Checked','off');
    set(handles.sITPC,'enable','on');
else
    set(handles.rejectERPCOHphase,'Checked','on');
    set(handles.sITPC,'enable','off');
    set(handles.sITPC,'value',0);
end
guidata(hObject,handles);
if get(handles.erpcohbut,'value')
    Plotmontage(hObject);
end


% --------------------------------------------------------------------
function Y=getCoef(hObject)
% Get the coefficient of the current inspected point
handles=guidata(hObject);
f=m2mp(handles.Fa, str2num(get(handles.fr,'String')));
t=m2mp(handles.tim, str2num(get(handles.tm,'String')));
ch=get(handles.ch,'Value');
Y=handles.Y(ch,f,t);

% --------------------------------------------------------------------
function setTimFa(hObject)
% Set handles.tim_c and handles.Fa_c to only contain the ROI
handles=guidata(hObject);
tp1=m2mp(handles.tim,str2num(get(handles.fromt,'String')));
tp2=m2mp(handles.tim,str2num(get(handles.tot,'String')));
fp1=m2mp(handles.Fa,str2num(get(handles.fromf,'String')));
fp2=m2mp(handles.Fa,str2num(get(handles.tof,'String')));
handles.tim_c=handles.tim(tp1:tp2);
handles.Fa_c=handles.Fa(fp1:fp2);
guidata(hObject,handles);



% --------------------------------------------------------------------
function updateGuiforDataset(hObject)
% Sets the available GUI buttons to match type of dataset
handles=guidata(hObject);
if length(handles.filenamelist)>1
     set(handles.parafacbut,'enable','on')
     set(handles.nmf2,'enable','on')
 else
     set(handles.parafacbut,'enable','off')
     set(handles.nmf2,'enable','off')
 end
 if length(handles.filenamelist)>2
    set(handles.Dendrogram,'enable','on');
 else
    set(handles.Dendrogram,'enable','off');
 end
 if length(handles.filenamelist)>5
    set(handles.anovabut,'enable','on');
 else
    set(handles.anovabut,'enable','off');
 end
 
 handles.chantoanal=1:size(handles.WT,1);

 if size(handles.WT,4)==1  % Loaded file is a specific measure
     set(handles.normback,'enable','off');
     set(handles.normback,'checked','off');
     set(handles.nonorm,'enable','on');
     set(handles.nonorm,'checked','on');
     set(handles.rejecttrials,'enable','off');
     set(handles.phasecoh,'enable','off');
     set(handles.lincoh,'enable','off');
     set(handles.ampcorr,'enable','off');
     set(handles.confbut,'value',0);
     set(handles.confbut,'enable','off');
     set(handles.bstrp,'enable','off');
     set(handles.rayleigh,'enable','off');
     set(handles.dstrmax,'enable','off');
     set(handles.showmeasures,'enable','off');
 else % Loaded file contains epoch information
     set(handles.showmeasures,'enable','on');
     set(handles.normback,'enable','on');
     set(handles.nonorm,'enable','on');
     set(handles.rejecttrials,'enable','on');
     set(handles.phasecoh,'enable','on');
     set(handles.ampcorr,'enable','on');
     set(handles.lincoh,'enable','on');
     set(handles.itpcbut,'enable','on');
     set(handles.erspbut,'enable','on');
     set(handles.erpcohbut,'enable','on');
     set(handles.avWTbut,'enable','on');
     set(handles.WTavbut,'enable','on');    
     set(handles.inducedbut,'enable','on');
     set(handles.epochbut,'enable','on');
     set(handles.confbut,'enable','on');
     set(handles.bstrp,'enable','on');
     set(handles.dstrmax,'enable','on');
 end
  % Enable to display wavelet if this is a complex morlet
 if strcmp(handles.wavetyp(1:4),'cmor')
     set(handles.swavelet,'enable','on');
 else
     set(handles.swavelet,'enable','off');
 end
     
% Set ROI if this is not already defined
 if isempty(get(handles.fromf,'String'))
     set(handles.fromf,'string',num2str(handles.Fa(1)));
 end
 if isempty(get(handles.tof,'String'))
    set(handles.tof,'string',num2str(handles.Fa(end)));
 end
 if isempty(get(handles.fromt,'String'))
    set(handles.fromt,'string',num2str(handles.tim(1)));
 end
 if isempty(get(handles.tot,'String'))
    set(handles.tot,'string',num2str(handles.tim(end)));
 end
 if isempty(get(handles.ch,'String'))
    set(handles.ch,'string',num2str(1));
 end
 if isempty(get(handles.fr,'String'))
     set(handles.fr,'string',num2str(handles.Fa(1)));
 end
 if isempty(get(handles.tm,'String'))
     set(handles.tm,'string',num2str(handles.tim(1)));
 end
 
 % Make various file menu options available
 set(handles.savecurrROI,'enable','on'); 
 set(handles.fastfile,'enable','on');
 set(handles.options,'enable','on');
 set(handles.tools,'enable','on');
 set(handles.normalization,'enable','on');
 if isempty(handles.rec{get(handles.files,'value')})
     set(handles.vrcc,'enable','off');
 else
     set(handles.vrcc,'enable','on');
 end

% Check for specific measures by the appended end name of the measure to
% the ERPWAVELAB file
if strcmp(handles.filename(end-3:end),'.mat') |  strcmp(handles.filename(end-3:end),'.MAT')
    fnam=['    ' handles.filename];
else
    fnam=['    ' handles.filename '.mat'];
end
if strcmp(fnam(end-7:end-4),'ERSP')
    handles.measure='ERSP';
    set(handles.itpcbut,'Value',0);
    set(handles.erspbut,'Value',1);
    set(handles.erpcohbut,'Value',0);
    set(handles.avWTbut,'Value',0);
    set(handles.WTavbut,'Value',0);    
    set(handles.inducedbut,'Value',0);
    set(handles.itpcbut,'enable','off');
    set(handles.erspbut,'enable','on');
    set(handles.erpcohbut,'enable','off');
    set(handles.avWTbut,'enable','off');
    set(handles.WTavbut,'enable','off');    
    set(handles.inducedbut,'enable','off');
    set(handles.epochbut,'enable','off');
    set(handles.rayleigh,'enable','off');
    set(handles.bstrp,'Value',1)
    set(handles.rayleigh,'Value',0)

elseif strcmp(fnam(end-7:end-4),'PCOH')
    handles.measure='ERPCOH';
    set(handles.itpcbut,'Value',0);
    set(handles.erspbut,'Value',0);
    set(handles.erpcohbut,'Value',1);
    set(handles.avWTbut,'Value',0);
    set(handles.WTavbut,'Value',0);    
    set(handles.inducedbut,'Value',0);
    set(handles.itpcbut,'enable','off');
    set(handles.erspbut,'enable','off');
    set(handles.erpcohbut,'enable','on');
    set(handles.avWTbut,'enable','off');
    set(handles.WTavbut,'enable','off');    
    set(handles.inducedbut,'enable','off');
    set(handles.epochbut,'enable','off');
    set(handles.rayleigh,'enable','on');
elseif strcmp(fnam(end-7:end-4),'avWT')   
    handles.measure='avWT';
    set(handles.itpcbut,'Value',0);
    set(handles.erspbut,'Value',0);
    set(handles.erpcohbut,'Value',0);
    set(handles.avWTbut,'Value',1);
    set(handles.WTavbut,'Value',0);    
    set(handles.inducedbut,'Value',0);
    set(handles.itpcbut,'enable','off');
    set(handles.erspbut,'enable','off');
    set(handles.erpcohbut,'enable','off');
    set(handles.avWTbut,'enable','on');
    set(handles.WTavbut,'enable','off');    
    set(handles.inducedbut,'enable','off');
    set(handles.epochbut,'enable','off');
elseif strcmp(fnam(end-7:end-4),'WTav')
    handles.measure='WTav';
    set(handles.itpcbut,'Value',0);
    set(handles.erspbut,'Value',0);
    set(handles.erpcohbut,'Value',0);
    set(handles.avWTbut,'Value',0);
    set(handles.WTavbut,'Value',1);    
    set(handles.inducedbut,'Value',0);
    set(handles.itpcbut,'enable','off');
    set(handles.erspbut,'enable','off');
    set(handles.erpcohbut,'enable','off');
    set(handles.avWTbut,'enable','off');
    set(handles.WTavbut,'enable','on');    
    set(handles.inducedbut,'enable','off');
    set(handles.epochbut,'enable','off');
    set(handles.rayleigh,'enable','off');
    set(handles.bstrp,'Value',1)
    set(handles.rayleigh,'Value',0)

elseif strcmp(fnam(end-7:end-4),'uced') |strcmp(fnam(end-7:end-4),'UCED')
    handles.measure='INDUCED';
    set(handles.itpcbut,'Value',0);
    set(handles.erspbut,'Value',0);
    set(handles.erpcohbut,'Value',0);
    set(handles.avWTbut,'Value',0);
    set(handles.WTavbut,'Value',0);    
    set(handles.inducedbut,'Value',1);
    set(handles.itpcbut,'enable','off');
    set(handles.erspbut,'enable','off');
    set(handles.erpcohbut,'enable','off');
    set(handles.avWTbut,'enable','off');
    set(handles.WTavbut,'enable','off');    
    set(handles.inducedbut,'enable','on');
    set(handles.epochbut,'enable','off');
    set(handles.rayleigh,'enable','off');
    set(handles.bstrp,'Value',1)
    set(handles.rayleigh,'Value',0)

elseif strcmp(fnam(end-7:end-4),'ITLC')
    handles.measure='ITLC';
    set(handles.itpcbut,'Value',1);
    set(handles.erspbut,'Value',0);
    set(handles.erpcohbut,'Value',0);
    set(handles.avWTbut,'Value',0);
    set(handles.WTavbut,'Value',0);    
    set(handles.inducedbut,'Value',0);
    set(handles.itpcbut,'enable','on');
    set(handles.erspbut,'enable','off');
    set(handles.erpcohbut,'enable','off');
    set(handles.avWTbut,'enable','off');
    set(handles.WTavbut,'enable','off');    
    set(handles.inducedbut,'enable','off');
    set(handles.epochbut,'enable','off');
    set(handles.itpcbut,'String','ITLC');
    set(handles.erpcohbut,'String','ERLCOH');
    set(handles.phasecoh,'checked','off');
    set(handles.lincoh,'checked','on');
    set(handles.ampcorr,'enable','off');
    set(handles.itpcbut,'String','ITLC');
    set(handles.erpcohbut,'String','ERLCOH');
    set(handles.confbut,'enable','on');
%    set(handles.bstrp,'Value',0)
%    set(handles.rayleigh,'Value',1)
%    set(handles.bstrp,'enable','off')
    set(handles.rayleigh,'enable','on');
    set(handles.dstrmax,'enable','on');

elseif strcmp(fnam(end-7:end-4),'ITPC')  | size(handles.WT,4)==1
    handles.measure='ITPC';
    set(handles.itpcbut,'Value',1);
    set(handles.erspbut,'Value',0);
    set(handles.erpcohbut,'Value',0);
    set(handles.avWTbut,'Value',0);
    set(handles.WTavbut,'Value',0);    
    set(handles.inducedbut,'Value',0);
    set(handles.itpcbut,'enable','on');
    set(handles.erspbut,'enable','off');
    set(handles.erpcohbut,'enable','off');
    set(handles.avWTbut,'enable','off');
    set(handles.WTavbut,'enable','off');    
    set(handles.inducedbut,'enable','off');
    set(handles.epochbut,'enable','off');
    set(handles.confbut,'enable','on');
    set(handles.phasecoh,'checked','on');
    set(handles.lincoh,'checked','off');
    set(handles.ampcorr,'enable','off');
    set(handles.itpcbut,'String','ITPC');
    set(handles.erpcohbut,'String','ERPCOH');

%    set(handles.bstrp,'Value',0)
%    set(handles.rayleigh,'Value',1)
%    set(handles.bstrp,'enable','off')
    set(handles.rayleigh,'enable','on');
    set(handles.dstrmax,'enable','on');
end
guidata(hObject,handles);

% --------------------------------------------------------------------
function cop=getCohInfo(handles)
% Extracts information regarding how cross coherence is calculated
cop=zeros(1,5);
if get(handles.erpcohbut,'value')
    cop(1)=find(handles.chantoanal==handles.plotsit(1));
    cop(2)=m2mp(handles.Fa, handles.plotsit(2));
    cop(3)=m2mp(handles.tim, handles.plotsit(3));
    cop(4)=get(handles.utpoint,'Value');
    cop(5)=get(handles.ufpoint,'Value');
end



% --------------------------------------------------------------------
function showmeasures_Callback(hObject, eventdata, handles)
% hObject    handle to showmeasures (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ch=handles.act_chan_ind(get(handles.ch,'value'));
ss=get(handles.nbcka,'Checked');
if ss(2)=='n'
    bt=[handles.bt1:handles.bt2];
else
    bt=[];
end

% Extract time and frequency region
tp1=m2mp(handles.tim,str2num(get(handles.fromt,'String')));
tp2=m2mp(handles.tim,str2num(get(handles.tot,'String')));
fp1=m2mp(handles.Fa,str2num(get(handles.fromf,'String')));
fp2=m2mp(handles.Fa,str2num(get(handles.tof,'String')));

plotMeasuresInChannel(handles.WT,ch,handles.chanlocs(ch).labels,bt,handles.tim(tp1:tp2),handles.Fa(fp1:fp2),[tp1,tp2],[fp1,fp2]);


% --------------------------------------------------------------------
function checkRejectPhase(hObject);
handles=guidata(hObject);
ss=get(handles.ampcorr,'checked');
ss2=get(handles.nbcka,'Checked');
if ~get(handles.ufpoint,'value') & ~get(handles.utpoint,'value') & ss(2)=='f' &  ss2(2)=='f'
   set(handles.rejectERPCOHphase,'enable','on');
else
   set(handles.rejectERPCOHphase,'enable','off');
   set(handles.rejectERPCOHphase,'checked','off');
end