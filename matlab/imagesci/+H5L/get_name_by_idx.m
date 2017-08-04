function name = get_name_by_idx(varargin)
%H5L.get_name_by_idx  Retrieve information about link specified by index.
%   name = H5L.get_name_by_idx(loc_id,group_name,idx_type,order,n,lapl_id)
%   retrieves information about a link at index n present in the group
%   group_name at location loc_id. lapl_id specifies the link access
%   property list for querying the group.
%
%   idx_type is the type of index and valid values include the following: 
%  
%      'H5_INDEX_NAME'      - alpha-numeric index on name
%      'H5_INDEX_CRT_ORDER' - index on creation order
% 
%   order specifies the index traversal order. Valid values include the
%   following: 
%  
%      'H5_ITER_INC'    - iteration is from beginning to end
%      'H5_ITER_DEC'    - iteration is from end to beginning
%      'H5_ITER_NATIVE' - iteration is in the fastest available order
%
%   Example:
%       fid = H5F.open('example.h5');
%       idx_type = 'H5_INDEX_NAME';
%       order = 'H5_ITER_DEC';
%       lapl_id = 'H5P_DEFAULT';
%       name = H5L.get_name_by_idx(fid,'g3',idx_type,order,0,lapl_id);
%       H5F.close(fid);
%
%   See also H5L.

%   Copyright 2009-2013 The MathWorks, Inc.

name = H5ML.hdf5lib2('H5Lget_name_by_idx', varargin{:});            
