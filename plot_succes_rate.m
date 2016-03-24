% Plot the mean succes rates of all stimulus time points over the simulus
% intensity, for every cell in a different subplot. PAS 02-03-2016. git
% test

function suc_plot=plot_succes_rate(analysis_ctrl, analysis_LTG)

% Calculate the number of cells
nr_cells=size(analysis_ctrl,2);

% Make a subplot for each cell
for cell=1:nr_cells;
    subplot(ceil(sqrt(nr_cells)), floor(sqrt(nr_cells)),cell);
    hold on
    % Set x and y values of the current cell for ctrl and LTG conditions
    las_ctrl=analysis_ctrl{1,cell}.laser_intensity;
    mn_ctrl=analysis_ctrl{1,cell}.mean_succes_rate;
    las_LTG=analysis_LTG{1,cell}.laser_intensity;
    mn_LTG=analysis_LTG{1,cell}.mean_succes_rate;
    % Plot the current cell and create correpsponding axis labels, 
    % axis values,  legend, title and set the axis
    plot(las_ctrl ,mn_ctrl,'b');
    plot(las_LTG, mn_LTG, 'r');
    xlabel('stimulus intensity (%)');
    ylabel('succes rate');
    legend('control','LTG');
    title(['PV neuron: ' num2str(cell)]);
    axis([las_LTG(1), las_LTG(size(las_LTG,1)), 0, 1]);
end