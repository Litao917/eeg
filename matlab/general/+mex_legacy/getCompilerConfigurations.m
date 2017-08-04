function  compConfig = getCompilerConfigurations( varargin )
% mex.getCompilerConfigurations lists compiler configuration information.
%   CC  = mex.getCompilerConfigurations() returns a mex.CompilerConfiguration
%   containing information about the selected compiler configuration used by MEX.
%   The selected compiler is the compiler chosen when mex -setup is run.
%
%   mex.CompilerConfiguration objects have the following properties:
%       Name:         a string describing the compiler
%       Manufacturer: a string with the manufacturer of the compiler
%       Language:     a string with the language of the compiler
%       Version:      a string describing the version of the compiler
%       Location:     a string pointing to root directory of the compiler
%       Details:      more specific information about the configuration 
%
%   CC  = mex.getCompilerConfigurations(LANG) returns an array 
%   of mex.CompilerConfiguration objects CC containing information 
%   about the selected compiler for language LANG.  If the language of 
%   the selected compiler and LANG do not match, then CC is empty.
%
%   LANG is a string for selecting a requested language. LANG can be 'Any',
%   'C', 'C++', 'CPP', or 'Fortran'.  The default value for LANG is 'Any'.
%
%   CC  = mex.getCompilerConfigurations(LANG,LIST) returns an 
%   array of mex.CompilerConfiguration objects CC containing 
%   information about configurations for LANG and LIST.
%
%   LIST is a string for selecting a set of configurations of interest.
%   LIST can be 'Selected', 'Installed', or 'Supported'. The default
%   value for LIST is 'Selected'. 
%
%   Example:
%     compConfSelected = mex.getCompilerConfigurations
%     allC_CompConfs = mex.getCompilerConfigurations('C','Supported')
% 
% See also MEX

%   Copyright 2007-2011 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date: 2013/07/23 01:17:21 $

switch nargin 
    case 0
        lang = 'Any';
        list = 'Selected';
    case 1
        lang = varargin{1};
        list = 'Selected';
    case 2
        lang = varargin{1};
        list = varargin{2};
    otherwise
        narginchk(0, 2)
end

try
    ccF = mex_legacy.CompilerConfigurationFactory(lang,list);
    compConfig = process(ccF);
catch allCompConfigExceptions
    % Throw known errors from here to keep errors clean
    if strmatch('MATLAB:CompilerConfiguration:',allCompConfigExceptions.identifier)
        throw(allCompConfigExceptions);
    else
        rethrow(allCompConfigExceptions)
    end
end
