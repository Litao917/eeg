function schema
% Defines properties for @preprocdlg class.
%
%   Copyright 2004-2011 The MathWorks, Inc.

%% Register class 
p = findpackage('tsguis');
c = schema.class(p,'preprocdlg',findclass(p,'viewdlg'));

%% Enumerations
if isempty(findtype('detrend'))
    schema.EnumType('detrend', {'constant','linear'});
end
if isempty(findtype('filtertype'))
    schema.EnumType('filtertype', {'ideal','transfer','firstord'});
end
if isempty(findtype('filterband'))
    schema.EnumType('filterband', {'pass','stop'});
end

%% Public properties

%% Removal attributes
p = schema.prop(c, 'Rowor', 'on/off');
p.FactoryValue = 'off';

%% Interpolation attributes
schema.prop(c, 'InterptsPath', 'string');

%% Filter attributes
p = schema.prop(c, 'Detrendtype', 'detrend');
p.FactoryValue = 'constant';
p = schema.prop(c, 'Filter', 'filtertype');
p.FactoryValue = 'firstord';
p = schema.prop(c, 'Band', 'filterband');
p.FactoryValue = 'pass';
p = schema.prop(c, 'Range', 'MATLAB array');
p.Description = getString(message('MATLAB:timeseries:tsguis:preprocdlg:FrequencyRange'));
p.FactoryValue = [0 0.1];
p = schema.prop(c, 'Acoeffs', 'MATLAB array');
p.FactoryValue = [1 -0.5];
p.Description = getString(message('MATLAB:timeseries:tsguis:preprocdlg:NumeratorCoefficients'));
p = schema.prop(c, 'Bcoeffs', 'MATLAB array');
p.FactoryValue = 1;
p.Description = getString(message('MATLAB:timeseries:tsguis:preprocdlg:DenominatorCoefficients'));
p = schema.prop(c, 'Timeconst', 'double');
p.Description = getString(message('MATLAB:timeseries:tsguis:preprocdlg:TimeConstantLowerCase'));
p.FactoryValue = 10;
schema.prop(c, 'UndoButtons', 'MATLAB array');

