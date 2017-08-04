%ADDLISTENER   Add listener for event.
%   el = ADDLISTENER(hSource, 'Eventname', Callback) creates a listener
%   for the event named Eventname, the source of which is handle object 
%   hSource.  If hSource is an array of source handles, the listener
%   responds to the named event on any handle in the array.  The Callback
%   is a function handle that is invoked when the event is triggered.
%
%   el = ADDLISTENER(hSource, PropName, 'Eventname', Callback) adds a 
%   listener for a property event.  Eventname must be one of the strings 
%   'PreGet', 'PostGet', 'PreSet', and 'PostSet'.  PropName must be either
%   a single property name or cell array of property names, or a single 
%   meta.property or array of meta.property objects.  The properties must 
%   belong to the class of hSource.  If hSource is scalar, PropName can 
%   include dynamic properties.
%   
%   For all forms, addlistener returns an event.listener.  To remove a
%   listener, delete the object returned by addlistener.  For example,
%   delete(el) calls the handle class delete method to remove the listener
%   and delete it from the workspace.
%
%   See also HANDLE, NOTIFY, DELETE, EVENT.LISTENER, META.PROPERTY, EVENTS, 
%   DYNAMICPROPS
 
%   Copyright 2008-2013 The MathWorks, Inc.
%   Built-in class method.



