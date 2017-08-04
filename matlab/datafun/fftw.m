%FFTW Interface to FFTW library run-time algorithm tuning control.
%   The MATLAB functions FFT, IFFT, FFT2, IFFT2, FFTN, and IFFTN functions
%   use a library called FFTW.  The FFTW library has the ability to
%   experimentally determine the quickest computational method to compute
%   the FFT of a particular size and dimensionality.  The FFTW function
%   provides an interface to this run-time algorithm tuning.
%
%   FFTW('planner', METHOD) sets the FFTW library planner method used for
%   subsequent calls to FFT, IFFT, FFT2, IFFT2, FFTN, and IFFTN.  METHOD can
%   be one of these strings: 'estimate', 'measure', 'patient', and
%   'exhaustive', or 'hybrid'.  If the planner method is 'estimate', then
%   the FFTW library chooses algorithms based on a quick heuristic.  The
%   resulting algorithms are sometimes suboptimal.  If you specify
%   'measure', the FFTW library will experiment with many different
%   algorithms to compute an FFT of a given size.  The library caches the
%   result in an internal "wisdom" database so that it can reused the
%   next time an FFT of the same size is computed.  Methods 'patient' and
%   'exhaustive' are similar to 'measure' except that they take much
%   longer.  If the planner method is 'hybrid', then MATLAB uses the
%   'measure' method for FFT dimensions of 8192 or smaller, and it uses
%   the 'estimate' method for larger dimensions.  The default planner
%   method is 'estimate'.
%
%   METHOD = FFTW('planner') returns the current planner method.
%
%   STR = FFTW('dwisdom') returns the FFTW library's internal
%   double-precision wisdom database as a string.  The string can be saved
%   and then later reused in a subsequent MATLAB session using the next
%   syntax.
%
%   STR = FFTW('swisdom') returns the FFTW library's internal
%   single-precision wisdom database as a string.
%
%   FFTW('dwisdom',STR) loads FFTW wisdom, represented as a string, into the 
%   FFTW library's internal double-precision wisdom database.
%   FFTW('dwisdom','') or FFTW('dwisdom',[]) clears the internal wisdom
%   database.
%
%   FFTW('swisdom',STR) loads FFTW wisdom, represented as a string, into the 
%   FFTW library's internal single-precision wisdom database.
%   FFTW('swisdom','') or FFTW('swisdom',[]) clears the internal wisdom
%   database.
%
%   For more information about the FFTW library, see http://www.fftw.org.
%
%   See also FFT, FFT2, FFTN, IFFT, IFFT2, IFFTN, FFTSHIFT.

%   Copyright 1984-2006 The MathWorks, Inc.

