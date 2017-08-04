function result = setup( pj )
%SETUP Open the printer setup dialog.
%   If the device driver in the PrintJob object is setup, opens the window
%   system specific dialog for setting options for printing. Normally this 
%   dialog will affect all future printing using the window system's driver
%   (i.e. Windows drivers), not just the current Figure or model.
%
%   Ex:
%      err_code = SETUP( pj ); %returns 1 if successfully opened setup
%                               dialog, 0 if not.
%
%   See also PRINT.

%   Copyright 1984-2012 The MathWorks, Inc.

if strcmp('setup', pj.Driver)
    result = 1;
    if pj.UseOriginalHGPrinting
        hardcopy(pj.Handles{1}(1), '-dsetup');
    else
        result = 0;
    end
else
    result = 0;
end

% LocalWords:  pj dsetup
