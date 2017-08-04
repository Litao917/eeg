function t = tsgetrelativetime(date,dateRef,unit)
% 

% this method calculates relative time value between date absolute dateref.

% Author: Rong Chen 
%  Copyright 2004-2010 The MathWorks, Inc.

vecRef = datevec(dateRef);
vecDate = datevec(date);
t = tsunitconv(unit,'days')*(datenum([vecDate(:,1:3) zeros(size(vecDate,1),3)])-datenum([vecRef(1:3) 0 0 0])) + ...
    tsunitconv(unit,'seconds')*(vecDate(:,4:6)*[3600 60 1]'-vecRef(:,4:6)*[3600 60 1]');
