function varargout = helpdlg(HelpString,DlgName)
%HELPDLG Help dialog box.
%  HANDLE = HELPDLG(HELPSTRING,DLGNAME) displays the 
%  message HelpString in a dialog box with title DLGNAME.  
%  If a Help dialog with that name is already on the screen, 
%  it is brought to the front.  Otherwise a new one is created.
%
%  HelpString will accept any valid string input but a cell
%  array is preferred.
%
%   Example:
%       h = helpdlg('This is a help string','My Help Dialog');
%
%  See also DIALOG, ERRORDLG, INPUTDLG, LISTDLG, MSGBOX,
%    QUESTDLG, WARNDLG.

%  Author: L. Dean
%  Copyright 1984-2006 The MathWorks, Inc.

if nargin==0,
   HelpString ={getString(message('MATLAB:uistring:popupdialogs:HelpDialogDefaultString'))};
end
if nargin<2,
   DlgName = getString(message('MATLAB:uistring:popupdialogs:HelpDialogTitle'));
end

HelpStringCell = dialogCellstrHelper(HelpString);

handle = msgbox(HelpStringCell,DlgName,'help','replace');

if nargout==1,varargout(1)={handle};end
