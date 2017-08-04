function refresh(this)
%REFRESH Refresh area plot

%   Copyright 1984-2008 The MathWorks, Inc.

if ~strcmp(this.dirty,'clean')
    try
        sibs = get(this,'AreaPeers');
        ok = false(length(sibs),1);
        for k=1:length(sibs);
            if ishandle(sibs(k))
                ok(k) = true;
            end
        end
        sibs = sibs(ok);
        ydata = get(sibs,'ydata');
        xdata = get(sibs,'xdata');
        if length(sibs) > 1
            % create a single matrix from all the vectors, adjusting for lengths
            ylen = max(cellfun('length',ydata));
            xlen = max(cellfun('length',xdata));
            maxlen = max(ylen,xlen);
            ydatafull = zeros(maxlen,length(sibs));
            ydatafull(:,1) = this.basevalue;
            xdatafull = ydatafull;
            for k = 1:length(sibs)
                d = ydata{k};
                ydatafull(1:length(d),k) = d(:);
                d = xdata{k};
                xdatafull(1:length(d),k) = d(:);
                for j = (length(d)+1):maxlen
                    xdatafull(j,k) = d(end)+j*10*eps;
                end
            end
            xdata = xdatafull;
            ydata = ydatafull;
        end
        [msg,x,y] = xychk(xdata,ydata,'plot');
    catch err
        msg=err.message;
    end
    if ~isempty(msg)
        set(this,'Dirty','inconsistent');
    else
        level = this.basevalue;

        if min(size(y))==1, y = y(:); x = x(:); end
        [m,n] = size(y);

        if n>1,
            % Check for the same x spacing
            if all(all(abs(diff(x,2)) < eps(class(x)))),
                y = cumsum(y,2); % Use fast calculation
            % Check for duplicated x columns
            elseif ~any(any(diff(x,1,2))),
                y = cumsum(y,2); % Use fast calculation                    
            else
                xi = sort(x(:));
                yi = zeros(length(xi),size(y,2));
                for i=1:n,
                    yi(:,i) = interp1(x(:,i),y(:,i),xi);
                end
                d = find(isnan(yi(:,1)));
                if ~isempty(d), yi(d,1) = level(ones(size(d))); end
                d = find(isnan(yi));
                if ~isempty(d), yi(d) = zeros(size(d)); end
                x = xi(:,ones(1,n));
                y = cumsum(yi,2);
                m = size(y,1);
            end
            xx = [x(1,:);x;flipud(x)];
            yy = [level(ones(m,1)) y];
            yy = [yy(1,1:end-1);yy(:,2:end);flipud(yy(:,1:end-1))];
        else
            xx = [x(1,:);x;flipud(x)];
            yy = [level;y;level(ones(m,1))];
        end

        f = 1:size(xx,1);
        for k=1:length(sibs)
            s = sibs(k);
            v = [xx(:,k) yy(:,k)];
            color = k*ones(size(v,1),1);
            if (length(sibs) == 1)
                color(end) = 2;
            end
            set(s.children,'faces', f, 'vertices', v, ...
                'facevertexcdata', color);
            s.dirty = 'clean';
            update(s);
            if ~isempty(getappdata(double(s),'LegendLegendInfo'))
                setLegendInfo(s);
            end
        end
        cax = ancestor(sibs(1),'axes');
        hold_state = ishold(cax);
        if ~hold_state,
            x = xdata;
            view(cax,2); set(cax,'Box','on')
            minx = min(x(:));
            maxx = max(x(:));
            if (minx == maxx)
                minx = maxx-1;
                maxx = maxx+1;
            end
            set(cax,'XLim',[minx maxx]);
        end
    end
end