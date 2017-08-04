function toMCode(hCode, hText)
% Generates code based on input codeblock object
% The code will adhere to the following template:
%
%  pre_function1(...)
%  pre_function2(...)
%  h = constructor_name(...)
%  post_function1(...)
%  post_function2(...)

% Copyright 2006-2012 The MathWorks, Inc.

code_name = get(hCode,'Name');

% Generate code for pre constructor helper functions
hPreFuncList = get(hCode,'PreConstructorFunctions');
for n = 1:length(hPreFuncList)
   hPreFuncList(n).toMCode(hText);
end

% Generate code for constructor
hConstructor = get(hCode,'Constructor');
if ~isempty(hConstructor)
    constructor_name = get(hConstructor,'Name');
    if ~isempty(constructor_name)
        if isempty(get(hConstructor,'Comment'))
            % Add comment
            strCreateCodeName = getString(message('MATLAB:codetools:codegen:codeblock:toMCode:CreateCodeName'));
            comment = sprintf('%% %s %s',strCreateCodeName,code_name);
            set(hConstructor,'Comment',comment);
        end
        hConstructor.toMCode(hText);
    end
end

% Generate code for post constructor helper functions
hPostFuncList = get(hCode,'PostConstructorFunctions');
for n = 1:length(hPostFuncList)
    hPostFuncList(n).toMCode(hText);
end

% Add blank line if we generated code for this object
if ( ~isempty(hPostFuncList) || ...
     ~isempty(hPreFuncList) || ...
     ~isempty(hConstructor))
   hText.addln(' ');
end

% Recurse down to this node's children
kids = find(hCode,'-depth',1);
kids = kids(2:end);

if numel(kids)>1 && ~isempty(hCode.MomentoRef.ObjectRef) && ishghandle(hCode.MomentoRef.ObjectRef)
    % Make sure that we push blocks with an unsatisfied variable requirement to
    % later in the list.
    IndexOrder = getChildOrder(kids);
else
    IndexOrder = 1:numel(kids);
end

% Generate code for each child
for n = IndexOrder
    kids(n).toMCode(hText);
end
