function [actVal, expVal] = eliminateCommonInfsAndNans(actVal, expVal)
%eliminateCommonInfsAndNans   Utility function to convert same-signed Infs
%   and NaNs in identical locations in actual and expected values to zeros.
%
%   This function finds same-signed Infs and NaNs in identical locations in the
%   actual and expected value arrays, and sets them to zero. To be clear, only
%   matching same-signed Infs or NaNs will be changed. The following example
%   demonstrates this behavior:
%
%   actual   = [Inf -Inf NaN  Inf NaN]
%   expected = [Inf -Inf NaN -Inf Inf]
%
%       are converted to
%
%   actual   = [0    0   0    Inf NaN]
%   expected = [0    0   0   -Inf Inf]
%
%   This function can be used to effectively ignore same-signed Infs and NaNs by
%   forcing them to zeros, making them appear equal and within any tolerance.

%  Copyright 2012 The MathWorks, Inc.


% Both act and exp values must be float in order to eliminate
% common Infs/NaNs
if (~(isfloat(actVal) && isfloat(expVal)))
    return;
end

if (isreal(actVal) && isreal(expVal))    
    
    actNans = isnan(actVal);
    expNans = isnan(expVal);
    actInfs = isinf(actVal);
    expInfs = isinf(expVal);
    
    eqInfs     = actInfs & ...
                 expInfs & ...
                 (sign(actVal) == sign(expVal));
    eqNans     = actNans & ...
                 expNans;
    eqInfsNans = eqInfs | ...
                 eqNans;
    
    actVal(eqInfsNans) = zeros('like',actVal);
    expVal(eqInfsNans) = zeros('like',expVal);
else
    actRealVal = real(actVal);
    actImagVal = imag(actVal);
    expRealVal = real(expVal);
    expImagVal = imag(expVal);
    
    actRealInfs = isinf(actRealVal);
    actImagInfs = isinf(actImagVal);
    expRealInfs = isinf(expRealVal);
    expImagInfs = isinf(expImagVal);
    
    actRealNans = isnan(actRealVal);
    actImagNans = isnan(actImagVal);
    expRealNans = isnan(expRealVal);
    expImagNans = isnan(expImagVal);
    
    eqRealInfs     = actRealInfs & ...
                     expRealInfs & ...
                     (sign(actRealVal) == sign(expRealVal));
    eqRealNans     = actRealNans & ...
                     expRealNans;
    eqRealInfsNans = eqRealInfs | ...
                     eqRealNans;
    eqImagInfs     = actImagInfs & ...
                     expImagInfs & ...
                     (sign(actImagVal) == sign(expImagVal));
    eqImagNans     = actImagNans & ...
                     expImagNans;
    eqImagInfsNans = eqImagInfs | ...
                     eqImagNans;
    
    % Special handling when actual/expected are sparse complex matrices
    % since complex function does not accept scalar inputs. In case of
    % sparse matrices, we do an intermediate cast to full, convert to
    % complex and then recast to sparse
    if issparse(actVal) 
        actVal(eqRealInfsNans) = complex(full(zeros('like',actRealVal)), ...
                                         full(actImagVal(eqRealInfsNans)));
        actVal(eqImagInfsNans) = complex(full(real(actVal(eqImagInfsNans))), ...
                                         full(zeros('like',actImagVal)));
    else
        actVal(eqRealInfsNans) = complex(zeros('like',actRealVal), ...
                                         actImagVal(eqRealInfsNans));
        actVal(eqImagInfsNans) = complex(real(actVal(eqImagInfsNans)), ...
                                         zeros('like',actImagVal));
    end
        
    if issparse(expVal) 
        expVal(eqRealInfsNans) = complex(full(zeros('like',expRealVal)), ...
                                         full(expImagVal(eqRealInfsNans)));
        expVal(eqImagInfsNans) = complex(full(real(expVal(eqImagInfsNans))), ...
                                         full(zeros('like',expImagVal)));
    else
        expVal(eqRealInfsNans) = complex(zeros('like',expRealVal), ...
                                     expImagVal(eqRealInfsNans));
        expVal(eqImagInfsNans) = complex(real(expVal(eqImagInfsNans)), ...
                                     zeros('like',expImagVal));
    end
end
end

% LocalWords:  Ns
