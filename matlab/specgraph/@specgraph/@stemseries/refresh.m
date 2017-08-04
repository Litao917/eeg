function refresh(this)
%REFRESH Refresh stem plot

%   Copyright 1984-2008 The MathWorks, Inc.

is3D = ~isempty(this.zdata);

if ~strcmp(this.dirty,'clean')
    
    % Record the lengths of xdata, ydata, and zdata
    xlen = length(this.xdata);
    ylen = length(this.ydata);
    zlen = length(this.zdata);
    
    % Check for consistent lengths
    if (is3D && ((xlen ~= ylen) || (xlen ~= zlen)))
        this.dirty = 'inconsistent';
    elseif (~is3D && (xlen ~= ylen))
        this.dirty = 'inconsistent';
    else
        % force data to be column vector
        [x,y] = deal(this.xdata,this.ydata);
        x = x(:); y = y(:);
        if is3D
            z = this.zdata; z = z(:);
        end
        
        % Create data for plotting stem marker and stem line.
        % NaNs are used to make non-continuos line segments.
        m = length(x);
        xx = zeros(3*m,1);
        xx(1:3:3*m) = x;
        xx(2:3:3*m) = x;
        xx(3:3:3*m) = NaN;
        
        if is3D
            yy = zeros(3*m,1);
            yy(1:3:3*m) = y;
            yy(2:3:3*m) = y;
            yy(3:3:3*m) = NaN;
            
            zz = this.basevalue*ones(3*m,1);
            zz(1:3:3*m) = z;
            zz(3:3:3*m) = NaN;
        else
            yy = this.basevalue*ones(3*m,1);
            yy(2:3:3*m) = y;
            yy(3:3:3*m) = NaN;
            
            zz = [];
            z = [];
        end
        
        hMarker = get(this,'MarkerHandle');
        hStem = get(this,'StemHandle');
        set([hMarker,hStem],'Visible',this.visible);
        
        % stem marker
        set(hMarker,'xdata',x,'ydata',y,'zdata',z);
        % stem line
        set(hStem,'xdata',xx,'ydata',yy,'zdata',zz);
        
        cax = get(this,'Parent');
        if ~strcmp(get(cax,'Type'),'axes')
            cax = ancestor(cax,'axes');
        end
        if ~ishold(cax)
            set(cax,'Box','on');
        end
        this.dirty = 'clean';
        update(this);
        if ~isempty(getappdata(double(this),'LegendLegendInfo'))
            setLegendInfo(this);
        end
    end
end

