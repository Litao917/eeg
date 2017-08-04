function mcodeConstructor(hObj,hCode)
% Generate code for surfaceplot, called by MAKEMCODE

% Copyright 2003-2006 The MathWorks, Inc.

propsToIgnore = {};

% Determine constructor name: SURF or MESH
edgecolor = get(hObj,'EdgeColor');
facelighting = get(hObj,'FaceLighting');
edgelighting = get(hObj,'EdgeLighting');
if strcmp(edgecolor,'flat') && ...
   strcmp(facelighting,'none') && ...
   strcmp(edgelighting,'flat')  
     propsToIgnore = {propsToIgnore{:},...
                      'FaceColor','EdgeColor',...
                      'FaceLighting','EdgeLighting'};
     constructor_name = 'mesh';
else
     constructor_name = 'surf';
end
setConstructorName(hCode,constructor_name);


% Ignore new properties until this object is default
propsToIgnore = {'XDataMode','YDataMode','CDataMode',...
    'XDataSource','YDataSource','CDataSource','ZDataSource',...
    propsToIgnore{:}};
if strmatch(get(hObj,'DisplayName'),get(hObj,'ZDataSource'))
    propsToIgnore{end+1} = 'DisplayName';
end
ignoreProperty(hCode,propsToIgnore);

% Don't show xdata, ydata if auto-generated
% Determine if xdata and ydata were auto generated by
% surface at constructor time. This is basically 
% reverse engineering how the surface constructor wrt
% how it handles zdata when doing: "surface(zdata)"
xdata = get(hObj,'xdata');
ydata = get(hObj,'ydata');
zdata = get(hObj,'zdata');
cdata = get(hObj,'cdata');

m = size(zdata,1);
n = size(zdata,2);

is_default_xdata = isequal((1:n),xdata); 
is_default_ydata = isequal((1:m)',ydata);
is_default_cdata = isequal(zdata,cdata);

% Come up with names for input variables:
xName = get(hObj,'XDataSource');
xName = hCode.cleanName(xName,'xdata');
% Come up with names for input variables:
yName = get(hObj,'YDataSource');
yName = hCode.cleanName(yName,'ydata');
% Come up with names for input variables:
zName = get(hObj,'ZDataSource');
zName = hCode.cleanName(zName,'zdata');
% Come up with names for input variables:
cName = get(hObj,'CDataSource');
cName = hCode.cleanName(cName,'cdata');

ignoreProperty(hCode,{'XData','YData','ZData','CData'});
   
% SURFACE(Z,...)
if is_default_xdata && is_default_ydata && is_default_cdata
   
    % ZData
    hArg = codegen.codeargument('Value',zdata,'Name',zName,'IsParameter',true,...
        'Comment','Surface zdata');
    addConstructorArgin(hCode,hArg);

% SURFACE(Z,C,...)
elseif is_default_xdata && is_default_ydata 
   
    % ZData
    hArg = codegen.codeargument('Value',zdata,'Name',zName,'IsParameter',true,...
        'Comment','Surface zdata');
    addConstructorArgin(hCode,hArg);
    
    % CData
    hArg = codegen.codeargument('Value',cdata,'Name',cName,'IsParameter',true,...
        'Comment','Surface cdata');
    addConstructorArgin(hCode,hArg);
    
% SURFACE(X,Y,Z,...)
elseif is_default_cdata
   
    % XData
    hArg = codegen.codeargument('Value',xdata,'Name',xName,'IsParameter',true,...
        'Comment','Surface xdata');
    addConstructorArgin(hCode,hArg);
    
    % YData
    hArg = codegen.codeargument('Value',ydata,'Name',yName,'IsParameter',true,...
        'Comment','Surface ydata');
    addConstructorArgin(hCode,hArg);
    
    % ZData
    hArg = codegen.codeargument('Value',zdata,'Name',zName,'IsParameter',true,...
        'Comment','Surface zdata');
    addConstructorArgin(hCode,hArg);
    
% SURFACE(X,Y,Z,C,...)
else
    % XData
    hArg = codegen.codeargument('Value',xdata,'Name',xName,'IsParameter',true,...
        'Comment','Surface xdata');
    addConstructorArgin(hCode,hArg);
    
    % YData
    hArg = codegen.codeargument('Value',ydata,'Name',yName,'IsParameter',true,...
        'Comment','Surface ydata');
    addConstructorArgin(hCode,hArg);
    
    % ZData
    hArg = codegen.codeargument('Value',zdata,'Name',zName,'IsParameter',true,...
        'Comment','Surface zdata');
    addConstructorArgin(hCode,hArg);
    
    % CData
    hArg = codegen.codeargument('Value',cdata,'Name',cName,'IsParameter',true,...
        'Comment','Surface cdata');
    addConstructorArgin(hCode,hArg);
end

% Don't show VertexNormals if auto-generated
if strcmpi(get(hObj,'NormalMode'),'auto');
    ignoreProperty(hCode,{'VertexNormals'});
end

generateDefaultPropValueSyntax(hCode); % method