function h = uibuttongroup(varargin)
% Constructor for the uibuttongroup class.

% Copyright 2003-2006 The MathWorks, Inc.

hg = findpackage('hg');
pc=  hg.findclass('uipanel');

% Cycle through parameter list and separate the P/V paires into two groups.
% Those acceptable by super class and those only acceptable by this class
argin = varargin;
len = length(argin);

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
    if ishandle(argin{1})
        % Assume that the first arg is a parent.
        parent = argin{1};
        parentH = handle(parent);
        if (isa(parentH, 'figure') || isa(parentH, 'uicontainer'))
            % If it is a figure window or a container type, then use it as a
            % parent for the buttongroup. This behavior is supported for other
            % HG objects.
            propsToPass = {'Parent', parent};
            argin = argin(2:end);
            len = length(argin);
        end
    end

    % must be even number for param-value syntax
    if mod(len,2)>0
        error(message('MATLAB:uibuttongroup:InvalidInputs'));
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

    propsToPass = {propsToPass{:}, argin{idxsuper}};
    propsToSet = {argin{idxthis}};
end

% create object with possibly 'Parent' and 'CreateFcn'
h = uitools.uibuttongroup(propsToPass{:});

% set properties only recognized by subclass
if length(propsToSet)>1
    set(double(h),propsToSet{:});
end

% addListeners is called as a result of an instanceCreated event.
% See schema for details. This is so we have a single entry-point
% to addListener for new and copied objects.

end
