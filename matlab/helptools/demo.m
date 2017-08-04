function demo(action,categoryArg) 
% DEMO Access examples via Help browser. 
%
%   DEMO opens the Help browser to MATLAB Examples.
%
%   DEMO TYPE NAME opens the examples for the product matching NAME of
%   and TYPE, as defined in that product's info.xml or demos.xml
%   file.
%   
%   Examples:
%       demo 'matlab'
%       demo 'toolbox' 'signal'
%
%   See also DOC.

%   Copyright 1984-2012 The MathWorks, Inc.

error(javachk('mwt',mfilename))
import com.mathworks.mlservices.MLHelpServices;
if nargin < 1
    MLHelpServices.showDemos;
elseif nargin == 1
    MLHelpServices.showDemos(action);
elseif nargin == 2
    MLHelpServices.showDemos(action, categoryArg);
end
