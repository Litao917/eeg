function  setpp( target, properties )
%SETPP Set all paper properties.
%	SPP( h, properties ) set property values of h from fields in properties structure.

%   Copyright 1984-2002 The MathWorks, Inc. 

if nargin ~= 2
    error(message('MATLAB:graphics:setpp:NoTarget'))
end

%maintain order, in case units were changed, and so mode ends up auto if that was the case
setset(target,'paperunits', properties.paperunits );
setset(target,'paperposition', properties.paperposition );
setset(target,'paperpositionmode', properties.paperpositionmode );
 
setset(target,'paperorientation', properties.paperorientation );
setset(target,'papertype', properties.papertype );

%Can't do this, yet
%setset(target,'papersize', properties.papersize );
