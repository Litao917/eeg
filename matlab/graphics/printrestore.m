function pj = printrestore( pj, h )
%PRINTRESTORE Reset a Figure or Simulink model after printing.
%   When printing a model or Figure, some properties have to be changed
%   to create the desired output. PRINTRESTORE resets the properties back to 
%   their original values.
%
%   Ex:
%      pj = PRINTRESTORE( pj, h ); %modifies PrintJob pj and Figure/model h
%
%   See also PRINT, PRINTOPT, PRINTPREPARE.

%   Copyright 1984-2011 The MathWorks, Inc. 


error( nargchk(2,2,nargin) )

if ~useOriginalHGPrinting(h)
    error(message('MATLAB:print:ObsoleteFunction', upper( mfilename )));
end

% call private version.
pj = restore(pj, h);

