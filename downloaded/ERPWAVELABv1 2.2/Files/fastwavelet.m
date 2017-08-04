function coefs=fastwavelet(signal, scales,wname,fb, points,resol)
% Wavelet analysis currently only based on complex Morlet wavelet
%
% Written by Morten Mørup
%
% Usage:
%       coefs=fastwavelet(signal, scales, wname, fb, points, resol)
%
% Input:
%       signal        Data to transform given by a 2-way array of Time x Epoch   
%       scales        scales used
%       wname         Wavelet name
%       fb            bandwidth parameter
%       points        Time points of which wavelet coefficients are calculated
%       resol         Resolution of the mother wavelet (optional)
%
% Output:
%       coefs         The wavelet coefficients at the specified timepoints
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

if nargin <6
    resol=12; % the resolution of the mother wavelet
end


%%%%%%%%%%%%%%%%%Complex Morlet wavelet%%%%%%%%%%%%%%%%%%%%%%%%%%
Fc=1;                                                           % Center frequency
xval=linspace(-4*fb,4*fb,2^resol);                  % Mother wavelet evaluation points
if strcmp(wname,'cmor')
    psi_integ=1/sqrt(2*pi*fb^2)*exp(i*2*pi*Fc*xval).*exp(-xval.^2/(2*fb^2));          
    psi_integ = conj(psi_integ);
end


%%%%%%%%%%%%%%%%Perform wavelet transform%%%%%%%%%%%%%%%%%%%%%%%%
sz=size(signal);
coefs  = zeros(length(scales),length(points),sz(2));
nbscales = length(scales);
dx=xval(2)-xval(1);
if points(2)-points(1)<=3 & exist('fft.m','file')
    % If almost every time-point is used transform is fastest performed in
    % frequency domain
    for k = 1:nbscales
        a = scales(k);
        t=1:(1/(dx*a)):length(xval);
        j = round(t);
        f=psi_integ(j);
        f=f/sqrt(a);
        if k==1 % Correct for length of wavelet 
            signal(end+1:end+length(f),:)=zeros(length(f),sz(2));
            XF=fft(signal);
        end
        fs=zeros(size(signal,1),1);
        fs(1:length(f))=f;
        FS=fft(fs);
        COEF=XF.*repmat(FS,[1,sz(2)]);
        c=ifft(COEF);
        coefs(k,:,:)=c(points+floor(length(f)/2),:);        
    end
else    
    % Calculate transform in time domain    
    for k = 1:nbscales
        a = scales(k);
        t=1:(1/(dx*a)):length(xval);
        j = round(t);
        f=psi_integ(j);
        f=f/sqrt(a);
        f=repmat(f',[1,sz(2)]);
        Lt=size(f,1);
        L1=floor(Lt/2);
        L2=ceil(Lt/2);
        for t=1:length(points)
            p=points(t);
            ind=max([1,p-L1+1]):min([sz(1),p+L2]);
            indW=max([1, L1-p+1]):(Lt+min([0,sz(1)-p-L2]));
            coefs(k,t,:)=sum(signal(ind,:).*f(indW,:),1);
        end
    end
end


