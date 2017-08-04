function  compConfig = getCompilerConfigurations( varargin )
% mex.getCompilerConfigurations lists compiler configuration information.
%   CC  = mex.getCompilerConfigurations() returns a mex.CompilerConfiguration
%   array containing information about the default compiler configurations 
%   used by MEX. There is one configuration for each supported language.
%
%   mex.CompilerConfiguration objects have the following properties:
%       Name:         a string describing the compiler
%       Manufacturer: a string with the manufacturer of the compiler
%       Language:     a string with the language of the compiler
%       Version:      a string describing the version of the compiler
%       Location:     a string pointing to root directory of the compiler
%       ShortName:    a string identifying the options file
%       Priority:     a character indicating the priority of this compiler
%       Details:      more specific information about the configuration 
%       LinkerName:   a string describing the linker
%       LinkerVersion: a string describing the version of the linker
%       MexOpt:       a string with the name and path to the options file
%
%
%   CC  = mex.getCompilerConfigurations(LANG) returns an array 
%   of mex.CompilerConfiguration objects CC containing information 
%   about the default compiler for language LANG.
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
%     defaultC = mex.getCompilerConfigurations('C','Selected')
%     allC_CompConfs = mex.getCompilerConfigurations('C','Supported')
% 
% See also MEX

%   Copyright 2007-2014 The MathWorks, Inc. 
%   $Revision: 1.1.16.1 $  $Date: 2014/01/15 20:27:08 $
end
