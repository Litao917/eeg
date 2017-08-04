function coefs=gabortf(signal, Fa,Fs,fb, points,resol)
% time-frequency analysis based on the Gabor transform, 
% i.e. correspondign to a stft windowed by a gaussion function
%
% Written by Morten Mørup
%
% Usage:
%       coefs=gabortf(signal, Fa, Fs, fb, points, resol)
%
% Input:
%       signal        Data to transform given by a 2-way array of Time x Epoch   
%       Fa  ´         Frequencies used
%       Fs            The sample rate
%       fb            window width parameter
%       points        Time points of which time-frequency coefficients are calculated
%       resol         Resolution of the Gabor transform (optional)
%
% Output:
%       coefs         The wavelet coefficients at the specified timepoints
%
%   See also fastwavelet
%
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

if nargin <5
    resol=12; % the resolution of the mother wavelet
end

xval=-4*fb:1/Fs:4*fb;

%%%%%%%%%%%%%%%%Perform Gabor transform%%%%%%%%%%%%%%%%%%%%%%%%
sz=size(signal);
coefs  = zeros(length(Fa),length(points),sz(2));
if exist('fft.m','file') % Make sure signal processing toolbox of MATLAB exist
    % Gabor transform based on FFT
    for k = 1:length(Fa)
        f=1/sqrt(2*pi*fb^2)*exp(i*2*pi*Fa(k)*xval).*exp(-xval.^2/(2*fb^2));          
        f = conj(f);
        if k==1 % Correct for length of Gabor filter 
            signal(end+1:end+length(f),:)=zeros(length(f),sz(2));
            XF=fft(signal);
            fs=zeros(size(signal,1),1);
        end
        fs(1:length(f))=f;
        FS=fft(fs);
        COEF=XF.*repmat(FS,[1,sz(2)]);
        c=ifft(COEF);
        coefs(k,:,:)=c(points+floor(length(f)/2),:);
    end
else
    % Signal processing toolbox not installed, thus transform performed
    % (slowly) in time-domain.
     for k = 1:length(Fa)
        f=1/sqrt(2*pi*fb^2)*exp(i*2*pi*Fa(k)*xval).*exp(-xval.^2/(2*fb^2));  
        f = conj(f);
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
