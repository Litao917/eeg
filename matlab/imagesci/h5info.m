function hinfo = h5info(filename,location)
%H5INFO  Return information about HDF5 file.
%   INFO = H5INFO(FILENAME) returns information about the entire HDF5 file
%   H5FILE.
%
%   INFO = H5INFO(FILENAME,LOCATION) returns information about the group,
%   dataset, or named datatype specified by location in the HDF5 file 
%   FILENAME.
%
%   The set of fields in INFO depends on the LOCATION parameter.  Fields
%   that may be present in the INFO structure are:
%   
%   File and groups:
%       Name:       Name of the group.  This is '/' if only a filename is
%                   provided, as this is the name of the root group.
%       Groups:     An array of structures describing subgroups.
%       Datasets:   An array of structures describing datasets.
%       Datatypes:  An array of structures describing named datatypes.
%       Links:      An array of structures describing soft, external,
%                   user-defined, and certain hard links.
%       Attributes: An array of structures describing group attributes.
%
%   Datasets:
%       Name:       Name of the dataset.
%       Datatype:   A struct describing the datatype.
%       Dataspace:  A struct describing the size of the dataset.
%       ChunkSize:  The extents of the dataset's chunk size, if defined.
%       FillValue:  The dataset's fill value, if defined.
%       Filter:     An array of structures describing any defined filters 
%                   such as compression.
%       Attributes: An array of structures describing dataset attributes.
%
%   Named Datatypes:
%       Name:       Name of the datatype object.
%       Class:      HDF5 class of the named datatype.
%       Type:       A string or struct further describing the datatype.
%       Size:       Size of the named datatype in bytes.
%       
%   In each case, INFO will also include 'Filename' as the first field of
%   the top-level struct.
%
%   Example:  Return all information.
%       info = h5info('example.h5');
%
%   Example:  Return information about a group and all data sets contained
%   within the group.
%       info = h5info('example.h5','/g4');
%
%   Example:  Return information about a specific dataset.
%       info = h5info('example.h5','/g4/time');
%
%   See also H5DISP.

%   Copyright 2010-2013 The MathWorks, Inc.



if nargin < 2
    location = '/';
end

validateattributes(filename,{'char'},{'row'},'h5info','FILENAME');
validateattributes(location,{'char'},{'row'},'h5info','LOCATION');

% Try to get a full pathname.  If FOPEN fails, it may be because we need to
% use the family driver, in which case the filename string does not 
% identify an actual location on disk.
fid = fopen(filename,'r');
if ( fid ~= -1 )
    filename = fopen(fid);  % get full pathname
    fclose(fid);
end

hinfo = h5infoc(filename,location);

hinfo.Filename = filename;

% If it is a dataset, remove the leading directory paths.
if isfield(hinfo,'ChunkSize')
    parts = regexp(location,'/','split');
    hinfo.Name = parts{end};
end

% Reorder the fields such that Filename is on top.
n = numel(fieldnames(hinfo));
hinfo = orderfields(hinfo, [n 1:n-1]);

return

