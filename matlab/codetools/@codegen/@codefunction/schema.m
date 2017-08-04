function schema

% Copyright 2003-2012 The MathWorks, Inc.

% Construct class
pk = findpackage('codegen');
cls = schema.class(pk,'codefunction');

% Hidden properties
p(1) = schema.prop(cls,'Name','MATLAB array');
set(p(end),'SetFunction',{@exclusiveSet,'Name','SubFunction'});
p(end+1) = schema.prop(cls,'Argout','MATLAB array');
p(end+1) = schema.prop(cls,'Argin','MATLAB array');
p(end+1) = schema.prop(cls,'CodeRef','MATLAB array');
p(end+1) = schema.prop(cls,'Comment','MATLAB array');
p(end+1) = schema.prop(cls,'SubFunction','MATLAB array');
set(p(end),'SetFunction',{@exclusiveSet,'SubFunction','Name'});
p(end+1) = schema.prop(cls,'NeedPragma','MATLAB array');
set(p(end),'FactoryValue',false);

function newValue = exclusiveSet(hThis,valueProposed,propName,conflictName)
if ~isempty(hThis.(conflictName))
    error(message('MATLAB:codetools:codegen:IncorrectProperty', ...
        propName, conflictName));
end
newValue = valueProposed;