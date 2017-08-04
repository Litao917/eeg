function attr_name = get_name(attr_id)
%H5A.get_name  Retrieve attribute name.
%   attr_name = H5A.get_name(attr_id) returns the name of the attribute
%   specified by attr_id. 
%
%   Example:
%       fid = H5F.open('example.h5');
%       gid = H5G.open(fid,'/g1/g1.1');
%       idx_type = 'H5_INDEX_NAME';
%       order = 'H5_ITER_INC';
%       attr_id = H5A.open_by_idx(gid,'dset1.1.1',idx_type,order,0);
%       name = H5A.get_name(attr_id);
%       H5A.close(attr_id);
%       H5G.close(gid);
%       H5F.close(fid);
%
%   See also H5A, H5A.open_by_idx.

%   Copyright 2006-2013 The MathWorks, Inc.

attr_name = H5ML.hdf5lib2('H5Aget_name', attr_id);            
