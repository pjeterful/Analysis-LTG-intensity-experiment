function [depol] = depolarization(Itrace, time, start, stop, ref1, ref2)

% Create a number of vectors to hold the data.
vhold   = [];
vevoked = [];
depol   = [];

% Determine a range for the reference potential
startref = find(time == ref1);
stopref  = find(time == ref2);

% Determine a range for the depolarization
startpol = find(time == start);
stoppol  = find(time == stop);

% For every repeat run the depolarization calculation
for nr = 1:size(Itrace,2)

vhold(nr)   = mean(Itrace(startref:stopref,nr));
vevoked(nr) = mean(Itrace(startpol:stoppol,nr));
depol(nr)   = vevoked(nr) - vhold(nr);

end

end

% Small script to determine depolarization in current clamp
% Input is the scaled time and 
% Output is the mean Vhold and Vexcite as well as the difference.
% Created by SdK March 10, 2014, updated May 12th 2014
