function h = contourgroup(varargin)
%CONTOURGROUP contourgroup constructor
%  H = CONTOURGROUP(PARAM1, VALUE1, PARAM2, VALUE2, ...) creates
%  a contour plot in the current axes with given param-value pairs.
%  This function is an internal helper function for Handle Graphics
%  and shouldn't be called directly.
  
%   Copyright 1984-2008 The MathWorks, Inc. 

args = varargin;
args(1:2:end) = lower(args(1:2:end));
parentind = find(strcmp(args,'parent'));
if isempty(parentind)
  parent = gca;
else
  parent = args{parentind(end)+1}; % take last parent specified
  args(unique([parentind parentind+1]))=[];
end
h = specgraph.contourgroup('parent',parent);
h.initialized = 1;
setLegendInfo(h);
% Allow the series to participate in legends:
hA = get(double(h),'Annotation');
hA.LegendInformation.IconDisplayStyle = 'On';
if ~isempty(args)
  set(h,args{:})
end

% Call the create function:
hgfeval(h.CreateFcn,double(h),[]);
