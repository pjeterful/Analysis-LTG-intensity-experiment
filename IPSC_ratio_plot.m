% This function plots the IPSC ratios between control and LTG condition of
% the first 'n' stimuli, for every cell, with the ratio of each individual 
% in blue and the mean in black, the SEM is represented by error bars.
function IPSC_ratio_plot=IPSC_ratio_plot(IPSC_ratio)
% The number of cells
nr_cells=size(IPSC_ratio,2);
% Give yfor every as the ration for every cell
for cell=1:nr_cells;
    hold on
    y(1:n,cell)=IPSC_ratio{1, cell}(1:n,11);
    plot([1:n],IPSC_ratio{1, cell}(1:n,11),'b')
end
% Calculate the mean of the the ratio and the SEM and plot these in black
% and as error bars respectively.
mn=mean(y,2);
stand=std(y,0,2)/sqrt(5);
hold on
plot([1:n],mn,'k ')
errorbar(mn,stand)
end