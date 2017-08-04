function output = timerfind(varargin)
%TIMERFIND Find visible timer objects with specified property values.
%
%    OUT = TIMERFIND returns all visible timer objects that exist in
%    memory.  Visible timer object are timer objects that have the
%    OBJECTVISIBILITY parameter set to 'on'.  The visible timer objects
%    are returned as an array to OUT.
%
%    OUT = TIMERFIND('P1', V1, 'P2', V2,...) returns an array, OUT, of
%    visible timer objects whose property names and property values match 
%    those passed as param-value pairs, P1, V1, P2, V2,... The param-value
%    pairs can be specified as a cell array. 
%
%    OUT = TIMERFIND(S) returns an array, OUT, of visible timer objects
%    whose property values match those defined in structure S whose field
%    names are timer object property names and the field values are the
%    requested property values.
%   
%    OUT = TIMERFIND(OBJ, 'P1', V1, 'P2', V2,...) restricts the search for 
%    matching param-value pairs to the timer objects listed in OBJ. 
%    OBJ can be an array of timer objects.
%
%    Note that it is permissible to use param-value string pairs, structures,
%    and param-value cell array pairs in the same call to TIMERFIND.
%
%    When a property value is specified, it must use the same format as
%    GET returns. For example, if GET returns the Name as 'MyObject',
%    TIMERFIND will not find an object with a Name property value of
%    'myobject'. However, properties which have an enumerated list data type
%    will not be case sensitive when searching for property values. For
%    example, TIMERFIND will find an object with a ExecutionMode property value
%    of 'singleShot' or 'singleshot'. 
%
%    Example:
%      t1 = timer('Tag', 'broadcastProgress', 'Period', 5);
%      t2 = timer('Tag', 'displayProgress');
%      out1 = timerfind('Tag', 'displayProgress')
%      out2 = timerfind({'Period', 'Tag'}, {5, 'broadcastProgress'})
%
%    See also TIMER/GET.

%    RDD 11-20-2001
%    Copyright 2001-2013 The MathWorks, Inc.

if isa(varargin{1}, 'timer')
    % Check to see if the given object is all invalid
    if all(~isvalid(varargin{1}))
        output = []; % Return empty if all input timer handles are invalid
        return;
    end
    jobjs = varargin{1}.jobject;
    % set the remaining 
    findparam = varargin(2:end);
else
    error(message('MATLAB:timer:invalid'));
end

% call find on the java objects
% filter invalid java timer & find ('find' overloaded built-in in TimerTask)
if ~isempty(findparam)    
    try
        jobjs = find(jobjs(isJavaTimer(jobjs)),findparam); 
    catch exception
        throw(fixexception(exception));
    end
end

% if nothing found, return empty set, otherwise return the timer object.
if (isempty(jobjs))
    output = [];
else
    output = timer.wrapJavaTimerObjs(jobjs);
end