function createArrow(hThis,varargin)
% Create and set up a scribe arrow

%   Copyright 2006-2010 The MathWorks, Inc.

% Since we cannot call super() from UDD, call a helper-method:
% Don't send varargin here, but rather call this method for setup purposes
hThis.createScribeObject1D;

% Define the shape type:
hThis.ShapeType = 'arrow';

% Angle of arrow
dx = hThis.X(2) - hThis.X(1);
dy = hThis.Y(2) - hThis.Y(1);
theta = atan2(dy,dx);
costh = cos(theta); sinth = sin(theta);
% length of whole arrow in normal and pixel coords
nx = hThis.X;
ny = hThis.Y;
nlength = sqrt((diff(nx)).^2 + (diff(ny)).^2);
hFig = ancestor(hThis,'Figure');
R1 = hgconvertunits(hFig,[nx(1) ny(1) 0 0],'normalized','pixels',hFig);
R2 = hgconvertunits(hFig,[nx(2) ny(2) 0 0],'normalized','pixels',hFig);
px = [R1(1) R2(1)];
py = [R1(2) R2(2)];
plength = sqrt((diff(px)).^2 + (diff(py)).^2);

% fractional (frx of whole arrow length) Head lengths and widths
HeadFLength = hThis.HeadLength/plength;
HeadFWidth = hThis.HeadWidth/plength;

% unrotated x,y,z vectors for line part
x = [0, nlength*(1 - HeadFLength)];
y = [0, 0];
z = [0, 0];
% Rotate by theta and translate by hThis.X(1),hThis.Y(1).
xx = x.*costh - y.*sinth + hThis.X(1);
yy = x.*sinth + y.*costh + hThis.Y(1);
% create a tail
hThis.TailHandle = hg.line('xdata',xx,'ydata',yy,'zdata',z,...
    'Parent',double(hThis),'Interruptible','off',...
    'HitTest','off','HandleVisibility','off');

% Head
% unrotated x,y,z vectors for arrow
x = nlength.*[1-HeadFLength, 1, 1-HeadFLength];
y = nlength.*[HeadFWidth/2, 0, - HeadFWidth/2];
z = [0, 0, 0];
% Rotate by theta and translate by hThis.X(1),hThis.Y(1).
xx = x.*costh - y.*sinth + hThis.X(1);
yy = x.*sinth + y.*costh + hThis.Y(1);

% Create Head - ignoring style and everything for now.
hThis.HeadHandle = hg.patch('XData',xx,'YData',yy,'ZData',z,...
    'Parent',double(hThis),'Interruptible','off','HitTest','off',...
    'HandleVisibility','off');

% The Selection Handles must always be on top in the child order:
hChil = findall(double(hThis));
set(hThis,'Children',[hChil(4:end);hChil(2:3)]);

% Define the properties which should listen to the "Color" property
hThis.ColorProps{end+1} = 'TailColor';
hThis.ColorProps{end+1} = 'HeadColor';

% Set the Edge Color Property to correspond to the "Color" property of the
% line.
hThis.EdgeColorProperty = 'Color';
hThis.EdgeColorDescription = 'Color';

% Set the Face Color Property to correspond to the "Color" property of the
% line.
hThis.FaceColorProperty = 'HeadColor';
hThis.FaceColorDescription = 'Head Color';

% Initialize the LineWidth/LineStyle properties
defaultLineWidth = get(0,'DefaultLineLineWidth');
hThis.LineWidth = defaultLineWidth;
hThis.HeadLineWidth = defaultLineWidth;
hThis.TailLineWidth = defaultLineWidth; 
defaultLineStyle = get(0,'DefaultLineLineStyle');
hThis.HeadLineStyle = defaultLineStyle;
hThis.TailLineStyle = defaultLineStyle;
hThis.LineStyle = defaultLineStyle;

% Install a property listener on the values which cause the "Position"
% property to update:
props = hThis.findprop('Position');
props(end+1) = hThis.findprop('HeadStyle');
props(end+1) = hThis.findprop('HeadBackDepth');
props(end+1) = hThis.findprop('HeadRosePQ');
props(end+1) = hThis.findprop('HeadHypocycloidN');
props(end+1) = hThis.findprop('HeadLength');
props(end+1) = hThis.findprop('HeadWidth');
props(end+1) = hThis.findprop('HeadSize');
l = handle.listener(hThis,props, ...
    'PropertyPostSet', @localChangePosition);
hThis.PropertyListeners(end+1) = l;

% Set the "HeadColorMode" property to "auto"
hThis.HeadColorMode = 'auto';

% Update the head patch data
evd.affectedObject = hThis;
localChangePosition([],evd);

% Set properties passed by varargin
set(hThis,varargin{:});

%---------------------------------------------------------------------%
function localChangePosition(hProp,eventData) %#ok
% Update the line data to be in line with the position

hThis = eventData.affectedObject;
if ~hThis.UpdateInProgress
    hThis.UpdateInProgress = true;
    hFig = ancestor(hThis,'Figure');
    R1 = hgconvertunits(hFig,[0 0 hThis.X(1) hThis.Y(1)],hThis.Units,'points',hFig);
    R2 = hgconvertunits(hFig,[0 0 hThis.X(2) hThis.Y(2)],hThis.Units,'points',hFig);
    PX = [R1(3) R2(3)];
    PY = [R1(4) R2(4)];

    % Angle of arrow
    dx = PX(2) - PX(1);
    dy = PY(2) - PY(1);
    theta = atan2(dy,dx);
    costh = cos(theta);
    sinth = sin(theta);
    % length of whole arrow in points
    PAL = sqrt((abs(PX(1) - PX(2)))^2 + (abs(PY(1) - PY(2)))^2);

    % unrotated x,y,z vectors for line part
    x1 = 0;
    L = hThis.HeadLength;
    switch (hThis.HeadStyle)
        case 'none'
            x2 = PAL;
        case {'plain','diamond','fourstar','ellipse','rectangle','rose'}
            x2 = PAL - L;
        case {'vback1','vback2','vback3'}
            d = [.15,.35,.8]; b = {'vback1','vback2','vback3'};
            x2 = PAL - (1 - d(strcmp(b,hThis.HeadStyle)))*L;
        case {'cback1','cback2','cback3'}
            d = [.1,.25,.6]; b = {'cback1','cback2','cback3'};
            depth = d(strcmp(b,hThis.HeadStyle));
            dfromend = (1 - depth)*(L/PAL);
            x2 = PAL*(1 - dfromend);
        case 'hypocycloid'
            N = hThis.HeadHypocycloidN;
            % odd number doesn't get rotated
            % already points away (with a -1*x flip at this end)
            % meets tail in one of its concavities
            if mod(N,2)>0
                x2 = PAL - (((N-1)/N)*L);
            else
                x2 = PAL - L;
            end
        case 'astroid'
            x2 = PAL - L;
        case 'deltoid'
            x2 = PAL - (2*L/3);
    end

    x = [x1,x2];
    y = [0, 0];

    % Rotate by theta and translate by hThis.X(1),hThis.Y(1).
    xx = x.*costh - y.*sinth + PX(1);
    yy = x.*sinth + y.*costh + PY(1);

    % Convert to normalized units
    norm1 = hgconvertunits(hFig,[xx(1) yy(1) 0 0],'points','normalized',hFig);
    norm2 = hgconvertunits(hFig,[xx(2) yy(2) 0 0],'points','normalized',hFig);
    
    xx = [norm1(1) norm2(1)];
    yy = [norm1(2) norm2(2)];
   
    set(double(hThis.TailHandle),'xdata',xx,'ydata',yy);

    % unrotated x,y,z vectors for arrow head
    L = hThis.HeadLength;
    W = hThis.HeadWidth/2;
    switch (hThis.HeadStyle)
        case 'plain'
            x = [PAL-L, PAL, PAL-L];
            y = [W, 0, -W];
        case {'vback1','vback2','vback3'}
            narrowfrx = .75;
            d = [.15,.35,.8]; b = {'vback1','vback2','vback3'};
            depth = d(strcmp(b,hThis.HeadStyle));
            x = [PAL-L,PAL; PAL,PAL-L;  PAL-(1-depth)*L,PAL-(1-depth)*L];
            y = narrowfrx.*[W,0; 0,-W; 0,0];
        case 'diamond'
            x = [PAL-L/2,PAL-L/2; PAL,PAL-L; PAL-L/2,PAL-L/2];
            y = [W,-W; 0,0; -W,W];
        case 'rectangle'
            x = [PAL-L,PAL;  PAL,PAL-L; PAL,PAL-L];
            y = [W,-W; W,-W; -W,W];
        case 'fourstar'
            x = [PAL-L/3,PAL-L/2,PAL-L,PAL-L/2,PAL-(2*L/3),PAL-(2*L/3);
                PAL,PAL-L/3,PAL-(2*L/3),PAL-(2*L/3),PAL-(2*L/3),PAL-L/3;
                PAL-L/3,PAL-(2*L/3),PAL-(2*L/3),PAL-L/3,PAL-L/3,PAL-L/3];
            y = [W/2,W,0,-W,-W/3,W/3;
                0,W/3,W/3,-W/3,W/3,W/3;
                -W/3,W/3,-W/3,-W/3,-W/3,-W/3];
        case {'cback1','cback2','cback3'}
            d = [.1,.25,.6]; b = {'cback1','cback2','cback3'};
            depth = d(strcmp(b,hThis.HeadStyle));
            Y = pi/2:pi/40:3*pi/2;
            X = cos(Y);
            xbot = 3;
            xoff = 2*depth;
            X = (-1*xoff).*X;
            Y = Y./pi - 1; %-1/2 to 1/2
            Y = Y.*2*W; %-W to W
            X = X.*(L/3);
            X = X + PAL - L;
            xtip = xbot*(L/3) + PAL - L;
            ytip = 0;
            x=zeros(3,length(X)-1); y=zeros(3,length(X)-1);
            for i=1:length(X)-1
                x(:,i) = [xtip; X(i); X(i+1)];
                y(:,i) = [ytip; Y(i); Y(i+1)];
            end
        case 'ellipse'
            % make a basic ellipse LxW at 0,0 with 20 points
            xstart = L/2; ystart = 0;
            x = zeros(3,39); y = zeros(3,39);
            for i=1:39
                th = i*pi/20;
                x(:,i) = [xstart; L/2*cos(th); L/2*cos(th+pi/20)];
                y(:,i) = [ystart; W*sin(th); W*sin(th+pi/20)];
            end
            % translate to beginning of arrow
            x = x + PAL - L/2;
        case 'rose'
            % Roses r==Cos[p/q*theta].
            % Parametric: Cos[p/q*t]*{Cos[t],Sin[t]}
            pq = hThis.HeadRosePQ;
            xstart = sin(pi/4).*cos(pq*pi/4)*L/2;
            ystart = cos(pi/4).*cos(pq*pi/4)*W;
            x=zeros(3,39); y=zeros(3,39);
            delta_t = pi/20;
            for i=1:39
                t1 = pi/4 + i*delta_t;
                t2 = t1 + delta_t;
                x1 = sin(t1).*cos(pq*t1)*L/2;
                x2 = sin(t2).*cos(pq*t2)*L/2;
                y1 = cos(t1).*cos(pq*t1)*W;
                y2 = cos(t2).*cos(pq*t2)*W;
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end
            x = x + PAL - L/2;
        case 'hypocycloid'
            N = hThis.HeadHypocycloidN;
            a = 1;
            b = 1/N;
            xstart = (a-2*b); ystart = 0;
            x=zeros(3,12*N-1); y=zeros(3,12*N-1);
            delta_t = pi/(6*N);

            for i=1:12*N-1
                t1 = i*delta_t;
                t2 = t1 + delta_t;
                x1 = (a - b) * cos(t1) - b*cos(((a-b)/b)*t1);
                x2 = (a - b) * cos(t2) - b*cos(((a-b)/b)*t2);
                y1 = (a - b) * sin(t1) + b*sin(((a-b)/b)*t1);
                y2 = (a - b) * sin(t2) + b*sin(((a-b)/b)*t2);
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end
            if mod(N,2)==0
                % a little rotation for even pointed hypocycloids
                % so that point meets tail.
                phi = pi/N; cosphi = cos(phi); sinphi = sin(phi);
                xx = x.*cosphi - y.*sinphi;
                yy = x.*sinphi + y.*cosphi;
                x = xx;
                y = yy;
            else
                % odd pointed hypocycloids need to be flipped for
                % concavity to meet tail and point to point away.
                x = -x;
            end
            x = x*L/2;
            y = y*W;
            x = x + PAL - L/2;
        case 'astroid' %hypocycloid, N=4;
            N = 4;
            a = 1;
            b = 1/N;
            xstart = (a-2*b); ystart = 0;
            x=zeros(3,47); y=zeros(3,47);
            delta_t = pi/24;
            for i=1:47
                t1 = i*delta_t;
                t2 = t1 + delta_t;
                x1 = (a - b) * cos(t1) - b*cos(((a-b)/b)*t1);
                x2 = (a - b) * cos(t2) - b*cos(((a-b)/b)*t2);
                y1 = (a - b) * sin(t1) + b*sin(((a-b)/b)*t1);
                y2 = (a - b) * sin(t2) + b*sin(((a-b)/b)*t2);
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end

            % a little rotation for even pointed hypocycloids
            % so that point meets tail.
            phi = pi/N; cosphi = cos(phi); sinphi = sin(phi);
            xx = x.*cosphi - y.*sinphi;
            yy = x.*sinphi + y.*cosphi;
            x = xx;
            y = yy;
            x = x*L/2;
            y = y*W;
            x = x + PAL - L/2;
        case 'deltoid' %hypocycloid, N=3;
            N = 3;
            a = 1;
            b = 1/N;

            xstart = (a-2*b); ystart = 0;
            x=zeros(3,35); y=zeros(3,35);
            delta_t = pi/18;
            for i=1:35
                t1 = i*delta_t;
                t2 = t1 + delta_t;
                x1 = (a - b) * cos(t1) - b*cos(((a-b)/b)*t1);
                x2 = (a - b) * cos(t2) - b*cos(((a-b)/b)*t2);
                y1 = (a - b) * sin(t1) + b*sin(((a-b)/b)*t1);
                y2 = (a - b) * sin(t2) + b*sin(((a-b)/b)*t2);
                x(:,i) = [xstart; x1; x2];
                y(:,i) = [ystart; y1; y2];
            end

            % odd pointed hypocycloids need to be flipped for
            % concavity to meet tail and point to point away.
            x = -x;
            x = x*L/2;
            y = y*W;
            x = x + PAL - L/2;
        case 'none'
            x = PAL; y = 0;
    end
    % Rotate by theta and translate by hThis.X(1),hThis.Y(1).
    xx = x.*costh - y.*sinth + PX(1);
    yy = x.*sinth + y.*costh + PY(1);
    
    % Convert into normalized units:
    % For each entry in xx and yy, do the conversion
    for i = 1:numel(xx)
        norm = hgconvertunits(hFig,[xx(i) yy(i) 0 0],'points','normalized',hFig);
        xx(i) = norm(1);
        yy(i) = norm(2);
    end
    set(double(hThis.HeadHandle),'xdata',xx,'ydata',yy,'zdata',zeros(size(yy)));
    hThis.UpdateInProgress = false;
end