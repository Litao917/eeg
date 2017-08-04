%% Function Functions
% This example shows how to use the output of one MATLAB(R) function as an
% input to another. This ability to specify a function's output as an
% input of another function serves a wide variety of purposes. Here we
% illustrate its use for finding zeros, optimization, and integration.
%
% Copyright 1984-2011 The MathWorks, Inc. 

%% The HUMPS Function
% A MATLAB function is a file that starts with the keyword function. This
% is what the function HUMPS looks like:

type humps

%% Plot of HUMPS
% This figure shows a plot of HUMPS in the domain [0,2] using FPLOT.

fplot(@humps,[0,2]);

%% Zero of HUMPS
% The FZERO function finds a zero of a function near an initial estimate.
% Our initial guess for the zero of HUMPS is 1.

z = fzero(@humps,1,optimset('Display','off'));
fplot(@humps,[0,2]);                          
hold on;
plot(z,0,'r*');
hold off 

%% Minimum of HUMPS
% The FMINBND function finds the minimum of a function in a given domain. Here, we
% search for a minimum for HUMPS in the domain (0.25, 1).
 
m = fminbnd(@humps,0.25,1,optimset('Display','off'));     
fplot(@humps,[0 2]);                                      
hold on; 
plot(m,humps(m),'r*');
hold off
 
%% Integral of HUMPS
% The INTERGRAL function finds the definite integral of HUMPS in a given domain. Here it
% computes the area in the domain [0.5, 1].
 
q = integral(@humps,0.5,1);                
fplot(@humps,[0,2]);                   
title(['Area = ',num2str(q)]);

displayEndOfDemoMessage(mfilename)
