function o = ddeget(options,name,default,flag)
%DDEGET  Get DDE OPTIONS parameters.
%   VAL = DDEGET(OPTIONS,'NAME') extracts the value of the named property
%   from integrator options structure OPTIONS, returning an empty matrix if
%   the property value is not specified in OPTIONS. It is sufficient to type
%   only the leading characters that uniquely identify the property. Case is
%   ignored for property names. [] is a valid OPTIONS argument.
%   
%   VAL = DDEGET(OPTIONS,'NAME',DEFAULT) extracts the named property as
%   above, but returns VAL = DEFAULT if the named property is not specified
%   in OPTIONS. For example
%   
%       val = ddeget(opts,'RelTol',1e-4);
%   
%   returns val = 1e-4 if the RelTol property is not specified in opts.
%   
%   See also DDESET, DDE23, DDESD, DDENSD.

%   Copyright 1984-2010 The MathWorks, Inc.

% undocumented usage for fast access with no error checking
if (nargin == 4) && isequal(flag,'fast')
   o = getknownfield(options,name,default);
   return
end

if nargin < 2
  error(message('MATLAB:ddeget:NotEnoughInputs'));
end
if nargin < 3
  default = [];
end

if ~isempty(options) && ~isa(options,'struct')
  error(message('MATLAB:ddeget:Arg1NotStruct'));
end

if isempty(options)
  o = default;
  return;
end

Names = [
         'AbsTol      '    
         'Events      '
         'InitialStep '
         'InitialY    '
         'Jumps       '
         'MaxStep     '
         'NormControl '
         'OutputFcn   '
         'OutputSel   '
         'Refine      '
         'RelTol      '
         'Stats       '         
                       ];

names = lower(Names);

lowName = lower(name);
j = strmatch(lowName,names);
if isempty(j)               % if no matches
  error(message('MATLAB:ddeget:InvalidPropName', name));
elseif length(j) > 1            % if more than one match
  % Check for any exact matches (in case any names are subsets of others)
  k = strmatch(lowName,names,'exact');
  if length(k) == 1
    j = k;
  else
    msg = sprintf('Ambiguous property name ''%s'' ', name);
    msg = [msg '(' deblank(Names(j(1),:))];
    for k = j(2:length(j))'
      msg = [msg ', ' deblank(Names(k,:))];
    end
    error(message('MATLAB:ddeget:AmbiguousPropName', msg));
  end
end

if any(strcmp(fieldnames(options),deblank(Names(j,:))))
  o = options.(deblank(Names(j,:)));
  if isempty(o)
    o = default;
  end
else
  o = default;
end

% --------------------------------------------------------------------------
function v = getknownfield(s, f, d)
%GETKNOWNFIELD  Get field f from struct s, or else yield default d.

if isfield(s,f)   % s could be empty.
  v = s.(f);
  if isempty(v)
    v = d;
  end
else
  v = d;
end

