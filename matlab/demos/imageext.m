function imageext(action)
% IMAGEEXT   Examples of images with a variety of colormaps
%   demonstrates loading images, available MATLAB colormaps
%   and spinning colormaps

%   Rewritten for V5 demo by Kelly Liu, 1-8-96; jae Roh, 10-15-96
%   Copyright 1984-2012 The MathWorks, Inc.
%   Date: 2012/06/19 01:46:41 $

% play= 1;
% stop=-1;

if nargin<1,
   action='initialize';
end;

if strcmp(action,'initialize'),
   oldFigNumber=watchon;
   
   figNumber=figure( ...
      'Name',getString(message('MATLAB:demos:imageext:TitleImageAndColorMap')), ...
      'Color', [.8 .8 .8], ...
      'NumberTitle','off', ...
      'Color', 'black', ...
      'DoubleBuffer', 'on', ...
      'Visible','off');
      
   axes( ...
      'Units','normalized', ...
      'Color', [.8 .8 .8], ...
      'Position',[0.05 0.10 0.75 0.87], ...
      'Visible','off');
   
   axis([0 1 0 1]);
   
   %===================================
   % Information for all buttons
   labelColor=[0.8 0.8 0.8];
   top=0.95;
   bottom=0.05;
   
   % yInitLabelPos=0.90;
   left=0.825;
   labelWid=0.15;
   labelHt=0.05;
   btnWid=0.15;
   btnHt=0.05;
   % Spacing between the label and the button for the same command
   btnOffset=0.003;
   % Spacing between the button and the next command's label
   spacing=0.05;
   %====================================
   % The CONSOLE frame
   frmBorder=0.02;
   yPos=0.05-frmBorder;
   frmPos=[left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
   h=uicontrol( ...
      'Style','frame', ...
      'Units','normalized', ...
      'Position',frmPos, ...
      'BackgroundColor',[0.50 0.50 0.50]);
   %====================================
   
   %====================================
   % The number popup button
   btnNumber=1;
   yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
   labelStr=['          ',getString(message('MATLAB:demos:imageext:PopupImages'))];
   popupStr=str2mat(getString(message('MATLAB:demos:imageext:PopupFluidJet')), getString(message('MATLAB:demos:imageext:PopupBone')),...
      getString(message('MATLAB:demos:imageext:PopupGatlinburg')),...
      getString(message('MATLAB:demos:imageext:PopupDurer')),...
      getString(message('MATLAB:demos:imageext:PopupDurerDetail')),...
      getString(message('MATLAB:demos:imageext:PopupCapeCod')),...
      getString(message('MATLAB:demos:imageext:PopupClown')),...
      getString(message('MATLAB:demos:imageext:PopupEarth')),...
      getString(message('MATLAB:demos:imageext:PopupMandrill')));
   imglist = {'flujet', 'spine',...
         'gatlin',...
         'durer',...
         'detail',...
         'cape',...
         'clown',...
         'earth',...
         'mandrill',...
         'spiral'};
   ClbkStr='imageext(''start'')';
   
   % Generic label information
   labelPos=[left yLabelPos-labelHt labelWid labelHt];
   uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',labelPos, ...
      'BackgroundColor',labelColor, ...
      'HorizontalAlignment','left', ...
      'String',labelStr);
   % Generic popup button information
   btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
   popupHndl=uicontrol( ...
      'Style','popup', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'String',popupStr, ...
      'Callback',ClbkStr);
   %=============================================
   % The view popup button
   btnNumber=2;
   yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
   labelStr=['        ',getString(message('MATLAB:demos:imageext:LabelColormap'))];
   
   popupStr=str2mat('default', 'hsv', 'hot', 'pink', 'cool', 'bone', 'prism', 'flag', 'gray', 'rand', 'jet');
   
   
   % Generic button information
   ClbkStr = 'imageext(''color'')';
   labelPos=[left yLabelPos-labelHt labelWid labelHt];
   VpopupHndl=uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',labelPos, ...
      'BackgroundColor',labelColor, ...
      'HorizontalAlignment','left', ...
      'String',labelStr);
   btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
   VpopupHndl=uicontrol( ...
      'Style','popup', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'String',popupStr, ...
      'Call', ClbkStr);   
   
   %====================================
   % The Spin button
   btnNumber=3;  
   labelStr=getString(message('MATLAB:demos:imageext:LabelSpinmap'));
   callbackStr='spinmap';
   yLabelPos=top-(btnNumber-1)*(btnHt+labelHt+spacing);
   btnPos=[left yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
   infoHndl=uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'position',btnPos, ...
      'string',labelStr, ...
      'call',callbackStr);
   if (get(0, 'screendepth')>8)
      set(infoHndl, 'Visible', 'off');
   end
   %====================================
   % The INFO button
   labelStr=getString(message('MATLAB:demos:shared:LabelInfo'));
   callbackStr='imageext(''info'')';
   infoHndl=uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'position',[left bottom+2*btnHt+spacing btnWid 2*btnHt], ...
      'string',labelStr, ...
      'call',callbackStr);
   
   %====================================
   % The CLOSE button
   labelStr=getString(message('MATLAB:demos:shared:LabelClose'));
   callbackStr='close(gcf)';
   closeHndl=uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'position',[left bottom btnWid 2*btnHt], ...
      'string',labelStr, ...
      'call',callbackStr);
   
   % Uncover the figure
   hndlList=[infoHndl closeHndl popupHndl VpopupHndl];
   passPrmt.handle=hndlList;
   passPrmt.clmap=[];
   passPrmt.imgfile=imglist;
   set(figNumber,'Visible','on', ...
      'UserData',passPrmt);
   watchoff(oldFigNumber);
   figure(figNumber);
   shwimg('flujet', passPrmt)
elseif strcmp(action,'start'),
   figNumber=gcf;
   passPrmt=get(figNumber, 'UserData');
   hndlList=passPrmt.handle;
   imglist=passPrmt.imgfile;
   popupHndl=hndlList(3);
   ClpopupHndl=hndlList(4);
   n=get(popupHndl, 'Value');
   set(ClpopupHndl, 'Value', 1);
   filename=char(imglist(n));
   shwimg(filename, passPrmt);
elseif strcmp(action,'color'),
   colorlabels ={'default', 'hsv','hot','pink','cool','bone',...
         'prism','flag','gray',...
         'rand', 'jet'};
   figNumber=gcf;
   passPrmt=get(figNumber, 'UserData');
   hndlList=passPrmt.handle;
   VpopupHndl=hndlList(4);
   colr=get(VpopupHndl, 'Value');
   if colr==10
      colormap(rand(64,3)); 
   elseif colr==1
      colormap(passPrmt.clmap);
   else    
      colormap(char(colorlabels(colr)));
   end;
   
elseif strcmp(action,'info');
   helpwin(mfilename);
   
end;    % if strcmp(action, ...

function shwimg(filename, psprmt)
load(filename,'X','map');
image(X)
if exist('caption')==0
   caption = [ ];
end;
axis('equal');
axis off;
colormap(map);

imtext(.5,-.08,caption);
psprmt.clmap=map;
set(gcf, 'UserData', psprmt);

