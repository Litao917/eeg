function checkoutWin(fileName, reload)
% Opens a checkout dialog for collecting the version number
% and whether to lock it 
% See also CHECKIN, CHECKOUT, CHECKINWIN
 

% Author(s): Vaithilingam Senthil
% Copyright 1998-2004 The MathWorks, Inc.

com.mathworks.mlwidgets.mlservices.scc.CheckOutDlg(fileName, reload); 
