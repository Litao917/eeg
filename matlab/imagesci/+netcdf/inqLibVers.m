function libvers = inqLibVers()
%netcdf.inqLibVers Return netCDF library version information.
%   libvers = netcdf.inqLibVers returns a string identifying the 
%   version of the netCDF library.
%
%   This function corresponds to the "nc_inq_libvers" function in the 
%   netCDF library C API.
%
%   Example:
%       libvers = netcdf.inqLibVers();
%
%   Please read the files netcdfcopyright.txt and mexnccopyright.txt for 
%   more information.
%  
%   See also netcdf.

%   Copyright 2008-2013 The MathWorks, Inc.

libvers = netcdflib('inqLibVers');

% This cuts out the date information that is appended to the version.
libvers = libvers(1:5);
