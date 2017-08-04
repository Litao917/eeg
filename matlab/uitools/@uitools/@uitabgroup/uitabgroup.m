function h = uitabgroup(varargin)
%Constructor for the uitabgroup class.

%   Copyright 2004-2012 The MathWorks, Inc.

hg = findpackage('hg');
pc=  hg.findclass('uiflowcontainer');

% Cycle through parameter list and separate the P/V paires into two groups.
% Those acceptable by super class and those only acceptable by this class
argin = varargin;
len = length(varargin);

% If the input is a p-v structure, then break it up into a p-v array.
if (len == 1 && isstruct(argin{:}))
    props = argin{:};
    fields = fieldnames(props);
    pvals = {};
    for i = 1:length(fields)
        pvals{end+1} = fields{i};
        pvals{end+1} = props.(fields{i});
    end
    argin = pvals(:);
    len = length(argin);
end

propsToPass = {};
propsToSet = {};


if len > 0 
  % must be even number for param-value syntax
  if mod(len,2)>0 
      argin = {'Parent' argin{:}};
  end
    
  idxsuper = []; 
  idxthis = []; 
  for i = 1:2:len     
      passtosuper = 0;
      try
         % property accepted by super class
         p = pc.findprop(argin{i});
         if ~isempty(p)
             passtosuper =1;
         end
      catch
      end
      
      if passtosuper
         idxsuper = [idxsuper, i, i+1];
      else
         idxthis = [idxthis, i, i+1];
      end
  end % for
  
  propsToPass = {argin{idxsuper}};
  propsToSet = {argin{idxthis}};
end

urlCSHelpWindow = 'matlab:helpview([docroot,''/matlab/helptargets.map''],''uitabgroup_migration'',''CSHelpWindow'')';
warning(message('MATLAB:uitabgroup:OldVersion', urlCSHelpWindow));
% create object with possibly 'Parent' and 'CreateFcn'
h = uitools.uitabgroup(propsToPass{:});

% set properties only recognized by subclass
if length(propsToSet)>1
   set(double(h),propsToSet{:});
end
