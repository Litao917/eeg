function hh = barh(varargin)
%BARH Horizontal bar graph.
%   BARH(X,Y) draws the columns of the M-by-N matrix Y as M groups of
%   N horizontal bars. The vector X must not have duplicate values.
%
%   BARH(Y) uses the default value of X=1:M.  For vector inputs,
%   BARH(X,Y) or BARH(Y) draws LENGTH(Y) bars.  The colors are set by
%   the colormap.
%
%   BARH(X,Y,WIDTH) or BARH(Y,WIDTH) specifies the width of the
%   bars. Values of WIDTH > 1, produce overlapped bars.  The
%   default value is WIDTH=0.8.
%
%   BARH(...,'grouped') produces the default horizontal grouped bar chart.
%   BARH(...,'stacked') produces a horizontal stacked bar chart.
%   BARH(...,LINESPEC) uses the line color specified (one of 'rgbymckw').
%
%   BARH(AX,...) plots into AX instead of GCA.
%
%   H = BARH(...) returns a vector of handles to barseries objects.
%
%   Use SHADING FACETED to put edges on the bars.  Use SHADING FLAT to
%   turn them off.
%
%   Examples: subplot(3,1,1), barh(rand(10,5),'stacked'), colormap(cool)
%             subplot(3,1,2), barh(0:.25:1,rand(5),1)
%             subplot(3,1,3), barh(rand(2,3),.75,'grouped')
%
%   See also PLOT, BAR, BAR3, BAR3H.

%   Copyright 1984-2010 The MathWorks, Inc.

% First we check which HG plotting API should be used.

if ishg2parent( varargin{:} )
    [~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
    try 
        h = barhHGUsingMATLABClasses(cax, args{:});
    catch me
        throw(me)
    end
else
    [v6, args] = usev6plotapi(varargin{:},'-mfilename',mfilename);
    [cax, args] = axescheck(args{:});
    if v6 || ((length(args) > 1) && ...
            isa(args{end},'char') && ...
            (length(args{end}) > 3) && ...
            (strcmp(args{end}(1:4),'hist')))
        h = barhV6(cax, args{:});
    else
        nargs = length(args);
        error(nargchk(1,inf,nargs,'struct'));
        [args,pvpairs,msg] = parseargs(args);
        if ~isempty(msg), error(msg); end
        nargs = length(args);
        
        [msg,x,y] = xychk(args{1:nargs},'plot');
        if ~isempty(msg), error(msg); end
        hasXData = nargs ~= 1;
        if hasXData && length(x)>1
            sortedx = sort(x);
            if any(sortedx(2:end)-sortedx(1:end-1) == 0)
                error(message('MATLAB:barh:DuplicateXValue'));
            end
        end
        if min(size(x))==1, x = x(:); end
        if min(size(y))==1, y = y(:); end
        n = size(y,2);
        
        % handle vectorized data sources and display names
        extrapairs = cell(n,0);
        if ~isempty(pvpairs) && (n > 1)
            [extrapairs, pvpairs] = vectorizepvpairs(pvpairs,n,...
                {'XDataSource','YDataSource','DisplayName'});
        end
        
        % Create plot
        if isempty(cax) || isa(handle(cax),'hg.axes')
            cax = newplot(cax);
            parax = cax;
            hold_state = ishold(cax);
        else
            parax = cax;
            cax = ancestor(cax,'Axes');
            hold_state = true;
        end
        
        h = [];
        xdata = {};
        pkg = findpackage('specgraph');
        findclass(pkg,'barseries');
        listeners = getappdata(0,'SpecgraphBarListeners');
        seriesListeners = getappdata(0,'Graph2dSeriesListeners');
        % 2 is the index for the peer listener
        set(listeners(2),'enable','off');
        set(seriesListeners(end),'enable','off');
        err = [];
        try
            for k=1:n
                % extract data from vectorizing over columns
                if hasXData
                    xdata = {'XData', datachk(x(:,k))};
                end
                h = [h specgraph.barseries('YData',datachk(y(:,k)), ...
                    xdata{:}, pvpairs{:},...
                    'horizontal','on',...
                    extrapairs{k,:}, 'Parent', parax)];
            end
            set(h,'BarPeers',h);
            if ~hold_state
                % Turn off edges when they start to overwhelm the colors
                if numel(y) > 150,
                    set(h,{'edgecolor'},get(h,{'facecolor'}));
                end
            end
            if n > 1
                set(h(2:end),'RefreshMode','auto');
            end
        catch err
        end
        set(listeners(2),'enable','on');
        set(seriesListeners(end),'enable','on');
        if ~isempty(err)
            rethrow(err);
        end
        set(h(1),'RefreshMode','auto');
        plotdoneevent(cax,h);
        h = double(h);
    end
end

if nargout>0, hh = h; end



function [args,pvpairs,msg] = parseargs(args)
msg = '';
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
% check for LINESPEC or bar layout
done = false;
while ~isempty(pvpairs) && ~done
    arg = pvpairs{1};
    [l,c,m,tmsg]=colstyle(arg,'plot');
    if isempty(tmsg)
        pvpairs = pvpairs(2:end);
        if ~isempty(l)
            pvpairs = {pvpairs{:},'LineStyle',l};
        end
        if ~isempty(c)
            pvpairs = {pvpairs{:},'FaceColor',c}; % note FaceColor, not Color
        end
        if ~isempty(m)
            pvpairs = {pvpairs{:},'Marker',m};
        end
    elseif any(strcmpi(arg(1:min(4,length(arg))),{'grou','stac'}))
        pvpairs = {pvpairs{2:end},'BarLayout',arg};
    else
        done = true; % stop looping
    end
end
% check for bar width
if length(args) > 1 && length(args{end}) == 1 && ...
        ~((length(args) == 2) && (length(args{1}) == 1) && (length(args{2}) == 1))
    pvpairs = {'BarWidth',args{end},pvpairs{:}};
    args(end) = [];
end
if isempty(args)
    msg.identifier = message('MATLAB:barh:NoDataInputs');
else
    msg = checkpvpairs(pvpairs,false);
end


