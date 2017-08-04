function hh = stem3(varargin)
    %STEM3  3-D stem plot.
    %   STEM3(Z) plots the discrete surface Z as stems from the xy-plane
    %   terminated with circles for the data value.
    %
    %   STEM3(X,Y,Z) plots the surface Z at the values specified
    %   in X and Y.
    %
    %   STEM3(...,'filled') produces a stem plot with filled markers.
    %
    %   STEM3(...,LINESPEC) uses the linetype specified for the stems and
    %   markers.  See PLOT for possibilities.
    %
    %   STEM3(AX,...) plots into AX instead of GCA.
    %
    %   H = STEM3(...) returns a stem object.
    %
    %   See also STEM, QUIVER3.
    
    %   Copyright 1984-2011 The MathWorks, Inc.
    
    % First we check which HG plotting API should be used.
    if ishg2parent( varargin{:} )
        [~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
        try
            h = stem3HGUsingMATLABClasses(cax, args{:});
        catch me
            throw(me)
        end
        if nargout>0, hh = h; end
    else
        [v6, args] = usev6plotapi(varargin{:},'-mfilename',mfilename);
        [cax, args] = axescheck(args{:});
        if v6
            h = Lstem3v6(cax, args{:});
        else
            nargs = length(args);
            error(nargchk(1,inf,nargs,'struct'));
            [pvpairs,args,nargs,msg] = parseargs(args);
            if ~isempty(msg), error(msg); end
            error(nargchk(1,3,nargs,'struct'));
            
            % create xdata,ydata if necessary
            [msg,x,y,z] = xyzchk(args{1:nargs});
            if ~isempty(msg), error(msg); end
            
            % 'hold on' support
            cax = newplot(cax);
            next = lower(get(cax,'NextPlot'));
            hold_state = ishold(cax);
            
            autoColor = ~any(strcmpi('Color',pvpairs(1:2:end)));
            autoStyle = ~any(strcmpi('LineStyle',pvpairs(1:2:end)));
            
            % Reshape to vectors
            x = reshape(x,[1,numel(x)]);
            y = reshape(y,[1,numel(y)]);
            z = reshape(z,[1,numel(z)]);
            datapairs = {'XData',datachk(x),'YData',datachk(y),'ZData',datachk(z)};
            
            [l,c,m] = nextstyle(cax,autoColor,autoStyle,true);
            if ~isempty(m) && ~strcmpi(m,'none')
                pvpairs =  {'Marker',m,pvpairs{:}};
            end
            h = specgraph.stemseries(datapairs{:},...
                'Color',c,'LineStyle',l,...
                pvpairs{:},'Parent',cax);
            
            % flag code generation properties
            if autoColor
                set(h,'CodeGenColorMode','auto');
            end
            if autoStyle
                set(h,'CodeGenLineStyleMode','auto');
            end
            if ~any(strcmpi('marker',pvpairs(1:2:end)))
                set(h,'CodeGenMarkerMode','auto');
            end
            set(h,'RefreshMode','auto');
            h = double(h);
            
            % 3-D view
            if ~ishold(cax), view(cax,3); grid(cax,'on'); end
            
            % hold support
            if ~hold_state, set(cax,'NextPlot',next); end
            
        end
        
        if nargout>0, hh = h; end
        
    end
end

function [pvpairs,args,nargs,msg] = parseargs(args)
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
n = 1;
extrapv = {};

% Loop through args, check for 'filled' or LINESPEC
while length(pvpairs) >= 1 && n < 4 && ischar(pvpairs{1})
    arg = lower(pvpairs{1});
    argn = length(arg);
    if strncmp(arg, 'filled', argn)
        pvpairs(1) = [];
        extrapv = {'MarkerFaceColor','auto',extrapv{:}};
        
        % LINESPEC (i.e. 'r*')
    else
        [l,c,m,tmsg]=colstyle(pvpairs{1});
        if isempty(tmsg)
            pvpairs(1) = [];
            if ~isempty(l)
                extrapv = {'LineStyle',l,extrapv{:}};
            end
            if ~isempty(c)
                extrapv = {'Color',c,extrapv{:}};
            end
            if ~isempty(m)
                extrapv = {'Marker',m,extrapv{:}};
            end
        end
    end
    n = n+1;
end
pvpairs = [extrapv pvpairs];
msg = checkpvpairs(pvpairs);
nargs = length(args);

end


function hh = Lstem3v6(cax,varargin)
    args = varargin;
    nin = length(args);
    
    fill = 0;
    ls = '-';
    ms = 'o';
    col = '';
    
    % Parse the string inputs
    while ischar(args{nin}),
        v = args{nin};
        vn = length(v);
        if ~isempty(v) && strncmpi(v, 'filled', vn)
            fill = 1;
            nin = nin-1;
        else
            [l,c,m,msg] = colstyle(v);
            if ~isempty(msg),
                error(message('MATLAB:stem3:UnknownOption', v));
            end
            if ~isempty(l), ls = l; end
            if ~isempty(c), col = c; end
            if ~isempty(m), ms = m; end
            nin = nin-1;
        end
    end
    
    error(nargchk(1,3,nin,'struct'));
    
    [msg,x,y,z] = xyzchk(args{1:nin});
    if ~isempty(msg), error(msg); end
    
    qargs = {x,y,z,zeros(size(x)),zeros(size(x)),-z,0,[col,ls,ms]};
    
    if fill,
        qargs = {qargs{:},'filled'};
    end
    if ~isempty(cax)
        qargs = {cax,qargs{:}};
    end
    
    % STEM3 calls the 'v6' version of QUIVER3, and temporarily modifies global
    % state by turning the MATLAB:quiver3:DeprecatedV6Argument and
    % MATLAB:quiver3:IgnoringV6Argument warnings off and on again.
    oldWarn(1) = warning('off','MATLAB:quiver3:DeprecatedV6Argument');
    oldWarn(2) = warning('off','MATLAB:quiver3:IgnoringV6Argument');
    try
        h = quiver3('v6',qargs{:});
    catch err
        warning(oldWarn); 
        rethrow(err);
    end
    warning(oldWarn); 
    
    if nargout>0, hh = h; end
end
