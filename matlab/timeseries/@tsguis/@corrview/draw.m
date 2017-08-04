function draw(this, Data, NormalRefresh)
%DRAW  Draws Bode response curves.
%
%  DRAW(VIEW,DATA) maps the response data in DATA to the curves in VIEW.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.

AxGrid = this.AxesGrid;

% Input and output sizes
[Ny, Nu] = size(this.Curves);

% Draw points
for row=1:Ny
    for col=1:Nu
     [T,Y] = stairs(Data.Lags,Data.CData(:,col,row));
     set(double(this.Curves(row,col)),'XData',T-0.5, 'YData',Y);
    end
end


