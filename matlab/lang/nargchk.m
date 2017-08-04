%NARGCHK Validate number of input arguments. 
%   MSGSTRUCT = NARGCHK(LOW,HIGH,N,'struct') returns an appropriate error
%   message structure if N is not between LOW and HIGH. If N is in the
%   specified range, the message structure is empty. The message structure
%   has at a minimum two fields, 'message' and 'identifier'.
%
%   MSG = NARGCHK(LOW,HIGH,N) returns an appropriate error message string if
%   N is not between LOW and HIGH. If it is, NARGCHK returns an empty matrix. 
%
%   MSG = NARGCHK(LOW,HIGH,N,'string') is the same as 
%   MSG = NARGCHK(LOW,HIGH,N).
% 
%   NARGCHK will be removed in a future release. Use NARGINCHK instead.
%
%   Example
%      error(nargchk(1, 3, nargin, 'struct'))
%
%   See also NARGINCHK, NARGOUTCHK, NARGIN, NARGOUT, INPUTNAME, ERROR.

%   Copyright 1984-2005 The MathWorks, Inc.
%   Built-in function.
