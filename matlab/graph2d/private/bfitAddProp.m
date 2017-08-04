function bfitAddProp(obj, propName, serialize)
%BFITADDPROP Adds an instance property to a BasicFit/DataStats object 
%
%   BFITADDPROP(OBJ, PROPNAME) BFITADDPROP(OBJ, PROPNAME, SERIALIZE)
%
%   Note: This function creates an "HGUsingMATLABClasses" version or a
%   "non-HGUsingMATLABClasses" version instance property with the following
%   properties:
%       Hidden = true; 
%       Copy = off  (There is no built-in copy method in the
%  HGUsingMATLABClasses version.)
%  SERIALIZE, if specified, should be 'on' or 'off', which is translated to
%  false or true in the "HGUsingMATLABClasses" case. If SERIALIZE is not
%  specified, Transient is true for the "HGUsingMATLABClasses" version.
%  Serialize is 'off' for "non-HGUsingMATLABClasses" version".

%   Copyright 2008-2010 The MathWorks, Inc.
    
    if nargin < 3
        serialize = 'off';
        transient = true;
    else
        transient = strcmp(serialize, 'off');
    end
    obj = handle(obj);
    if isobject(obj) % HGUsingMATLABClasses
        p = addprop(obj, propName);
        p.Transient = transient;
        p.Hidden = true;
    else % non-HGUsingMATLABClasses
        p = schema.prop(obj, propName, 'MATLAB array');
        p.AccessFlags.Serialize = serialize;
        p.AccessFlags.Copy = 'off';
        p.Visible = 'off';
    end
end
