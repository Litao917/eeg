function varargout = hdfv(varargin)
%HDFV MATLAB gateway to HDF Vgroup interface.
%   HDFV is a gateway to the HDF Vgroup (V) interface.  
%
%   The general syntax for HDFV is
%   HDFV(funcstr,param1,param2,...).  There is a one-to-one correspondence
%   between V functions in the HDF library and valid values for funcstr.
%   For example,
%   HDFV('nattrs',vgroup_id) corresponds to the C library call
%   Vnattrs(vgroup_id).
%
%   Syntax conventions
%   ------------------
%   A status or identifier output of -1 indicates that the operation
%   failed.
%
%   Access functions
%   ----------------
%   Access functions open files, initialize the Vgroup interface, and
%   access individual groups.  They also terminate access to vgroups and
%   the Vgroup interface and close HDF files.
%
%     status = hdfv('start',file_id)
%       Initializes the V interface.
%
%     vgroup_id = hdfv('attach',file_id,vgroup_ref,access)
%       Establishes access to a vgroup; access can be 'r' or 'w'.
%
%     status = hdfv('detach',vgroup_id)
%       Terminates access to a vgroup.
%
%     status = hdfv('end',file_id)
%       Terminates access to the V interface.
%
%   Create functions
%   ----------------
%   Create functions organize, label, and add data objects to
%   vgroups.
%
%     status = hdfv('setclass',vgroup_id,class)
%       Assigns a class to a vgroup.
%
%     status = hdfv('setname',vgroup_id,name)
%       Assigns a name to a vgroup.
%
%     ref = hdfv('insert',vgroup_id, id)
%       Adds a vgroup or vdata to an existing group; id can be a vdata id
%       or a vgroup id.
%
%     status = hdfv('addtagref',vgroup_id,tag,ref)
%       Adds any HDF data object to an existing vgroup.
%
%     status = hdfv('setattr',vgroup_id,name,A)
%       Sets the attribute of a vgroup.
%
%   File inquiry functions
%   ----------------------
%   File inquiry functions return information about how vgroups are stored
%   in a file.  They are useful for locating vgroups in a file.
%
%     [refs,count] = hdfv('lone',file_id,maxsize)
%       Returns the reference numbers of vgroups not included in other
%       vgroups.
%
%     next_ref = hdfv('getid',file_id,vgroup_ref)
%       Returns the reference number for the next vgroup in the HDF file.
%
%     vgroup_ref = hdfv('find',file_id,vgroup_name)
%       Returns the reference number of the vgroup with the specified name
%       if successful and zero otherwise.
%       
%     vgroup_ref = hdfv('findclass',file_id,class)
%       Returns the reference number of the vgroup with the specified
%       class.
%
%   Vgroup inquiry functions
%   ------------------------
%   Vgroup inquiry functions provide specific information about a specific
%   vgroup.  This information includes the class, name, member count, and
%   additional member information.
%
%     [class_name,status] = hdfv('getclass',vgroup_id)
%       Returns the name of the class of the specified group.
%
%     [vgroup_name,status] = hdfv('getname',vgroup_id)
%       Returns the name of the specified group.
%
%     [num_entries,name,status] = hdfv('inquire',vgroup_id)
%       Returns the number of entries and the name of a vgroup.
%
%     status = hdfv('isvg',vgroup_id,ref)
%       Checks if the object specified by ref refers to a child vgroup of
%       the vgroup specified by vgroup_id.
%
%     status = hdfv('isvs',vgroup_id,vdata_ref)
%       Checks if the object specified by vdata_ref refers to a child vdata 
%       of the vgroup specified by vgroup_id.
%
%     [tag,ref,status] = hdfv('gettagref',vgroup_id,index)
%       Retrieves a tag/reference number pair for a data object in the
%       specified vgroup.
%
%     count = hdfv('ntagrefs',vgroup_id)
%       Returns the number of tag/reference number pairs contained in the
%       specified vgroup.
%
%     [tag,refs,count] = hdfv('gettagrefs',vgroup_id,maxsize)
%       Retrieves the tag/reference pairs of all the data objects within a
%       vgroup.
%
%     tf = hdfv('inqtagref',vgroup_id,tag,ref)
%       Checks if an object belongs to a vgroup.
%
%     version = hdfv('getversion',vgroup_id)
%       Queries the vgroup version of a given vgroup.
%
%     count = hdfv('nattrs',vgroup_id)
%       Queries the total number of vgroup attributes.
%
%     [name,data_type,count,nbytes,status] = hdfv('attrinfo',vgroup_id,...
%                                                attr_index)
%       Queries information on a given vgroup attribute.
%
%     [values,status] = hdfv('getattr',vgroup_id,attr_index)
%       Queries the values of a given attribute.
%
%     ref = hdfv('Queryref',vgroup_id)
%       Returns the reference number of the specified vgroup.
%
%     tag = hdfv('Querytag',vgroup_id)
%       Returns the tag of the specified vgroup.
%
%     vdata_ref = hdfv('flocate',vgroup_id,field)
%       Returns the reference number of the vdata containing the specified
%       field name in the specified vgroup.
%
%     count = hdfv('nrefs',vgroup_id,tag)
%       Returns the number of data objects with the specified tag in the
%       specified vgroup.
%
%   Please read the file hdf4copyright.txt for more information.
%
%   See also HDF, MATLAB.IO.HDF4.SD, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, 
%            HDFHE, HDFHX, HDFML, HDFVF, HDFVH, HDFVS

%   Copyright 1984-2013 The MathWorks, Inc.

% Call HDF.MEX to do the actual work.
[varargout{1:max(1,nargout)}] = hdf('V',varargin{:});

