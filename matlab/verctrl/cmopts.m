function out = cmopts(variableName)
%CMOPTS Version control settings.
%   CMOPTS returns the name of your version control system. To specify the
%   version control system, select Preferences from the Home tab.
%
%   OUT=CMOPTS('VARIABLENAME') returns the setting for VARIABLENAME
%   as a string OUT.
%
%   See also CHECKIN, CHECKOUT, UNDOCHECKOUT, CUSTOMVERCTRL, CLEARCASE,
%   PVCS, and RCS.

%   Author(s): Vaithilingam Senthil
%   Copyright 1984-2008 The MathWorks, Inc.

[lwarn, lwarnid] = lastwarn;
warnState = warning('off', 'all');
try
  import com.mathworks.services.Prefs;
  m = message('MATLAB:sourceControl:none');
  prefs = char(Prefs.getStringPref(Prefs.SOURCE_CONTROL_SYSTEM, m.getString));
catch anError
  prefs = m.getString;
end
lastwarn(lwarn, lwarnid);
warning(warnState);

if nargin == 0
  out = prefs;
  return;
else
  try
	out = eval(variableName);
  catch
	error(message('MATLAB:sourceControl:variableNotDefined', variableName));
  end
end
