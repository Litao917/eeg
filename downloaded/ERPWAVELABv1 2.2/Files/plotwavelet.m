function plotwavelet(wname,fb,Fs,FF)
% Function to show the from of the time-frequency transfomration
%
% Written by Morten Mørup
%
% Usage:
%   plotwavelet(wname,fb,Fs,FF)
%
% Input:
%   wname   String containing name of wavelet
%   fb      the range in which the wavelet is evaluated for the plotting is set to +/-4*sqrt(fb)
%   Fs      Sample rate (optional)
%   FF      FF(1) start frequency, FF(2) end frequency of transformation (optional)
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

if nargin<3
    Fs=1000;
    FF=[10 80];
end

if strcmp(wname,'cmor')
    resol=12; % the resolution of the cmor wavelet
    signal=zeros(2^resol,1);
    L=round(size(signal,1)/2);
    signal(L,1)=1;
    xval=linspace(-4*fb,4*fb,2^resol);
    dx=xval(2)-xval(1);
    coefs=squeeze(fastwavelet(signal,1/dx,wname,fb, 1:length(signal),resol));
    coefs=fliplr(coefs);
    C(:,1)=real(coefs);
    C(:,2)=imag(coefs);
    plot(C);
    title('$\widetilde{\varphi}(t)=\frac{1}{\sqrt{2\pi\sigma^2}}e^{-i2\pi t}e^{-\frac{t^2}{2\sigma^2}}$','Interpreter','latex')
    axis off;
elseif strcmp(wname,'Gabor (stft)')
    signal=zeros(length(-4*fb:1/Fs:4*fb),1);
    signal(round(size(signal,1)/2),1)=1;
    C1=[];
    C2=[];
    for k=1:2
        coefs=squeeze(gabortf(signal,FF(k),Fs,fb,1:length(signal)));
        coefs=fliplr(coefs);
        C1=[C1 real(coefs)];
        C2=[C2 imag(coefs)];  
    end
    C=[C1; C2];
    plot(C');
    title(['$\frac{1}{\sqrt{2\pi\sigma^2}}e^{-i2\pi' num2str(FF(1)) ' t}e^{-\frac{t^2}{2\sigma^2}}\quad \frac{1}{\sqrt{2\pi\sigma^2}}e^{-i2\pi' num2str(FF(2)) ' t}e^{-\frac{t^2}{2\sigma^2}}$'],'Interpreter','latex')    
    axis off;
end
    