%EVENT.LISTENER    Listener object
%    The EVENT.LISTENER class defines listener objects.  Listener objects
%    listen for a specific event and identify the callback function to 
%    invoke when the event is triggered.
%    
%    el = EVENT.LISTENER(obj,'EventName',@CallbackFunction) creates a 
%    listener object for the event named 'EventName' on the specified 
%    object and specifies a function handle to the callback function.  If 
%    obj is an array of objects, the listener responds to the named event
%    on any handle in the array.
%
%    The listener callback function must be defined to accept at least two
%    input arguments, as in: 
%
%        function CallbackFunction(source, eventData)
%           ...
%        end
%
%    where source is the object that is the source of the event and
%    eventData is an event.EventData instance.
%
%    Event listeners can also be created using addlistener.
%
%    See also ADDLISTENER, NOTIFY, EVENT.EVENTDATA, EVENT.PROPLISTENER

%   Copyright 2008-2013 The MathWorks, Inc. 
%   Built-in class.