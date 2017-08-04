function set_dxpl_multi(dxpl_id, memb_dxpl)
%H5P.set_dxpl_multi  Set data transfer property list for multi-file driver.
%   H5P.set_dxpl_multi(dxpl_id, memb_dxpl) sets the data transfer property
%   list dxpl_id to use the multi-file driver. memb_dxpl is an array of
%   data access property lists.
%
%   See also H5P, H5P.get_dxpl_multi.

%   Copyright 2006-2013 The MathWorks, Inc.

id = H5ML.unwrap_ids(dxpl_id);
memb_dxp = zeros(1,numel(memb_dxpl));
for i = 1 : length(memb_dxpl) 
   memb_dxp(i) = H5ML.unwrap_ids(memb_dxpl(i));
end
H5ML.hdf5lib2('H5Pset_dxpl_multi', id, memb_dxp);            
