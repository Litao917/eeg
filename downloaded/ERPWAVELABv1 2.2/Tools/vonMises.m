function [X, p]=vonMises(X,n,SL,ncomp)
% Function to test the hypothesis h0: theta=0 or 180 degrees of the ERPCOH
% measure.
%
% Written by Morten Mørup 
%
% Usage:
%   X=vonMises(X,n,SL)
%
% Input:
%   X       channel x frequency x time array of ERPCOH values
%   n       number of epochs
%   SL      Significance Level
%   ncomp   number of tests for correction of multiple comparisons, if
%           ncomp=1 no multiple comparison else significance is given for
%           the distribution of the max value of the ncomp observations.
%
% Output:
%   X       channel x frequency x time array of ERPCOH values set to 0
%           where h0 could not be rejected.
%   p       if X only contains one element, the probability of the phase
%           being zero or 180 degrees is also returned else p=[].
%
% The von Mises test is based on Upton (1973) 
% see also: 
% Mardia, K.V and Jupp, P.E. "Directional Statistics", 1999 page 122
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

if n<5
    disp('Warning: Not enough epochs to generate valid Von Mises statistics');
end
absX=abs(X);
Rsqr=absX.^2;
theta=real(-i*log(X./absX));
C=absX.*abs(cos(theta));
Csqr=C.^2;
I1=find(C<=2/3);
I2=find(C>2/3);
Chi_stat=zeros(size(X)); 
% Test statistics: 4n(R^2-C^2)/(2-C^2) for C<=2/3 following a Chi-1
% distribution
Chi_stat(I1)=4*n*(Rsqr(I1)-Csqr(I1))./(2-Csqr(I1));

% Test statistics: 2n^3/(n^2+C^2+3n)log((1-C^2)/(1-R^2)) for C>2/3 following a Chi-1
% distribution
Chi_stat(I2)=2*n^3./(n^2+Csqr(I2)+3*n).*log((1-Csqr(I2))./(1-Rsqr(I2)+eps)+eps);

chi_val=chi2inv(SL^(1/ncomp),1);
I=find(Chi_stat<chi_val);
X(I)=0;

if prod(size(X))==1
    p=1-chi2cdf(Chi_stat,1)^ncomp;
else
    p=[];
end
