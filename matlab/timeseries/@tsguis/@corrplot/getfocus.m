function xfocus = getfocus(this)
%GETFOCUS  Computes optimal X limits for wave plot 
%          by merging Focus of individual waveforms.

%  Author(s):  
%  Copyright 1986-2005 The MathWorks, Inc.

xfocus = [0 1];
for k=1:length(this.Responses) 
    if this.Responses(k).isvisible && ~isempty(this.Responses(k).Data) && ...
            ~this.Responses(k).Data.Exception
        xfocus = [min([this.Responses(k).Data.Lags(:); xfocus(1)]) ...
            max([this.Responses(k).Data.Lags(:); xfocus(2)])];
    end
end

