% This function performs a gaussian fit on data.
% For current values of below 0, the weibull fit doesn't comply.
% Input to function is two vectors (x and y)
% Output is a fit, two vectors and X50 and Y50 values.

function [dblThreshold, xThreshold, vecFitX, vecFitY, cFit] = gaussian_fit(currents,freq_values)

% X and Y values of points to perform fit on.
% Here derive them form the IF_folder_runner function
vecX = currents;
vecY = freq_values; 

if size(vecX,2) ~= size(vecY,2)
    error('Vectors must be same length')
end

% Vector with x values to evaluate fit on
vecFitX = 0.01:0.01:500;

% Fit settings for the Weibull, set to specific range and type.
% Range of spike frequency is about 0 - 50 Hz, currents 0 - 350 pA
sFit = fitoptions('Method', 'NonlinearLeastSquares', ...
    'Lower', [0 0 0 0], 'Upper', [70 70 70 70], 'StartPoint', [5 2 0 2]);
fFit = fittype('(d-c)*(0.5*(1+erf((x-a)/(b*sqrt(2)))))+c', 'options', sFit); 
% 'Lower' and 'Upper' refer to the minimum and maximum possible fits
% Startpoint is a guesstimate to start with, so it goes faster.
% For every range we have: a = u (mu,mean,shabang), b = sigma, c = lower, d = upper

% Perform the fit on the vectors added to the fit
% Calculate the vecFitY for the given fit.
cFit = fit(vecX', vecY', fFit);
vecFitY = (cFit.d-cFit.c)*(0.5*(1+erf((vecFitX-cFit.a)/(cFit.b*sqrt(2)))))+cFit.c;

%Determine 50% of upper and lower bounds
halfway      = (cFit.d-cFit.c)*0.5;
dblThreshold = halfway + cFit.c; % 50% diff + lower
xThreshold   = cFit.a;

% %Plot the results on a logarithmic scale for comparison
% figure('units','normalized','outerposition',[0 0 1 1]);
% plot(vecFitX, vecFitY, 'k', 'LineWidth', 2); hold on;
% h = plot(vecX, vecY, 'o', 'LineWidth', 2);
% set(h, 'MarkerFaceColor', [1 0 0], 'MarkerEdgeColor', [1 0 0]);
% title(sprintf('Threshold: %.2f%%', dblThreshold));

% semilogx() also an option

end