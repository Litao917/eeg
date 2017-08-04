function [is,us] = strings2codes(s)
%STRINGS2CODES Handle strings that will become undefined elements.

import matlab.internal.tableUtils.isstring
import matlab.internal.tableUtils.isStrings

if ischar(s)
    us = strtrim(s);
    
    % Set '<undefined>' or '' as undefined elements
    if strcmp(us,categorical.undefLabel) || strcmp(us,'') || strcmp(us,char(zeros(1,0)));
        is = 0;
        us = {};
    else
        is = 1;
    end
else % iscellstr(b)
    [us,~,is] = unique(strtrim(s));

    % Allow 0x0 or 1x0 char, but not 0x1 or any other empty char
    if isStrings(us)
        us = us(:); % force cellstr to a column
    else
        throwAsCaller(msg2exception('MATLAB:categorical:InvalidNames', upper(inputname(1))));
    end
    
    % Set '<undefined>' or '' as undefined elements
    locs = strcmp(us,categorical.undefLabel) | strcmp(us,'') | strcmp(us,char(zeros(1,0)));

    if any(locs)
        convert = (1:length(us))' - cumsum(locs);
        convert(locs) = 0;
        is = convert(is);
        us(locs) = [];
    end

    is = reshape(is,size(s));
end
