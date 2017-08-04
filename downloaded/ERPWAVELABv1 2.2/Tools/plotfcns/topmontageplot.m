function topmontageplot(X,chanlocs,width,height,ax,tim,Fa,TU,TL)
% Plots the time-frequency activity of the 3-way array X in the
% correct position according to each channels topographic location 
%
% Written by Morten Mørup
%
% Usage:
%   topmontageplot(X,chanlocs,width,height,ax,tim,Fa,TU,TL
%
% Input:
%   X           3-way array (Channel x Time x Frequency)
%   chanlocs    The channel locations as defined by the EEG structure in EEGLAB
%   width       The widht of each time-frequency plot (default=0.1)
%   height      The height of each time-frequency plot (default=0.1)
%   ax          The coloraxis of the plot (default=[min(X(:)) max(X(:))])
%   tim         The time axis
%   Fa          The frequency axis
%   TU          3-way array of Upper significance limit
%   TL          3-way array of Lower significance limit
%
% Copyright (C) Morten Mørup and Technical University of Denmark, 
% September 2006
%                                          
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

if nargin<3
    width=0.1;
end
if nargin<4
    height=0.1
end
if nargin<5
    ax=[min(X(:)) max(X(:))];
end
if nargin<6
    tim=[];
end
if nargin<7
    Fa=[];
end
if nargin<8
    TU=[];
end
if nargin<9
    TL=[];
end

for k=1:length(chanlocs)
    if ~isempty(chanlocs(k).radius)
        x(k)=sin(chanlocs(k).theta/360*2*pi)*chanlocs(k).radius;
        y(k)=cos(chanlocs(k).theta/360*2*pi)*chanlocs(k).radius;
    end
end
minx=min(x);
miny=min(y);
maxx=max(x);
maxy=max(y);
a=(maxx-minx)/50; % air to edge of plot
b=(maxy-miny)/50; % air to edge of plot
mx=maxx-minx+width;
my=maxy-miny+height;

name='Topological Montage Plot';
h = findobj('Name', name, 'Type', 'Figure');
if isempty(h)
   h = figure('WindowButtonDownFcn',{@showTFplot,X,x,y,chanlocs,tim,Fa,ax,mx,my,a,b,width,height,TU,TL});
   set(h, 'Name', name);
   set(h, 'NumberTitle', 'off');
else
    h = h(1);
    set(0, 'CurrentFigure', h);
    set(h,'WindowButtonDownFcn',{@showTFplot,X,x,y,chanlocs,tim,Fa,ax,mx,my,a,b,width,height,TU,TL});
end
clf;
set(h, 'Color', [1 1 1]);
set(h, 'PaperUnits', 'centimeters');
set(h, 'PaperType', '<custom>');
set(h, 'PaperPosition', [0 0 12 12]);

h = axes('position', [0 0 1 1]);
set(h, 'Visible', 'off');

for k=1:size(X,1);
   if ~isempty(chanlocs(k).radius)
        h=axes('position', [(x(k)-minx+a)/(mx+2*a), (y(k)-miny+a)/(my+2*b), width/mx, height/mx ]);
        hold on;
        imagesc(squeeze(X(k,:,:)));
        % Plot significance upper and over limits for two tailed analysis
        if ~isempty(TU)
            Tt=squeeze(TU(k,:,:));
            T=zeros(size(Tt));
            I=find(Tt>0);
            T(I)=1;
            contour(T,1,'LineColor','Red','linewidth',2)
        end
        if ~isempty(TL)
            Tt=squeeze(TL(k,:,:));
            T=zeros(size(Tt));
            I=find(Tt<0);
            T(I)=1;
            contour(T,1,'LineColor','Green','linewidth',2)
        end
        set(gca,'YDIR','reverse')
        caxis(ax);
        axis off;
        text(0,0,chanlocs(k).labels,'FontSize',8,'FontWeight','bold');
        hold off;
   end
end


%--------------------------------------------------------------------------
function showTFplot(src,event,X,x,y,chanlocs,tim,Fa,ax,mx,my,a,b,width,height,TU,TL)
% Button down function for plot figure - displays single channel activity
minx=min(x);
miny=min(y);
x=(x-minx+a)/(mx+2*a)+width/(2*mx);
y=(y-miny+a)/(my+2*b)+height/(2*mx);
ppl=[x' y'];
cp=get(src,'CurrentPoint');
cp2=get(src,'Position');
pos=cp./cp2(3:4);
dist=sum((ppl-repmat(pos,[size(ppl,1) ,1])).^2,2);
[Y,k]=min(dist);
alreg=abs(pos-ppl(k,:));
if alreg(1)<=width/(2*mx) & alreg(2)<=height/(2*mx)
    figure;
    hold on;
    imagesc(tim,Fa,squeeze(X(k(1),:,:)));
     % Plot significance upper and over limits for two tailed analysis
     if ~isempty(TU)
        Tt=squeeze(TU(k,:,:));
        T=zeros(size(Tt));
        I=find(Tt>0);
        T(I)=1;
        contour(tim,Fa,T,1,'LineColor','red','linewidth',2)
    end
    if ~isempty(TL)
        Tt=squeeze(TL(k,:,:));
        T=zeros(size(Tt));
        I=find(Tt<0);
        T(I)=1;
        contour(tim,Fa,T,1,'LineColor','Green','linewidth',2)
    end
    caxis(ax); 
    set(gca,'YDIR','reverse')
    axis tight;
    title(chanlocs(k(1)).labels,'FontSize',16,'FontWeight','bold');
    xlabel('ms','FontSize',12,'FontWeight','bold');
    ylabel('Hz','FontSize',12,'FontWeight','bold');
    hold off;
end


        

