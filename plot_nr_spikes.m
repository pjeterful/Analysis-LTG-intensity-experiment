% Plot the mean nr of spikes of all stimulus time points over the simulus
% intensity, for every cell in a different subplot. PAS 18-05-2016. 


function nr_spikes_plot=plot_nr_spikes(analysis_ctrl, analysis_LTG)

% Calculate the number of cells
nr_cells=size(analysis_ctrl,2);

% Make a subplot for each cell
for cell=1:nr_cells;
    if isfield(analysis_ctrl{1, cell},'laser_intensity')==1
    subplot(ceil(sqrt(nr_cells)), ceil(sqrt(nr_cells)),cell);
    hold on
    % Set x and y values of the current cell for ctrl and LTG conditions
    las_ctrl=analysis_ctrl{1,cell}.laser_intensity;
    mn_ctrl=analysis_ctrl{1,cell}.mean_nr_spikes;
    las_LTG=analysis_LTG{1,cell}.laser_intensity;
    mn_LTG=analysis_LTG{1,cell}.mean_nr_spikes;
    % Plot the current cell and create correpsponding axis labels, 
    % axis values,  legend, title and set the axis
    plot(las_ctrl ,mn_ctrl,'ko','MarkerSize', 4);
    %plot(las_ctrl ,mn_ctrl-mn_LTG,'k');
    plot(las_LTG, mn_LTG, 'k^','MarkerSize', 4);
    xlabel('stimulus intensity (%)');
    ylabel('spike probability');
    legend('control','LTG');
    title(['neuron: ' num2str(cell)]);
    axis([las_LTG(1), las_LTG(size(las_LTG,1)), 0, max(mn_ctrl)]);
    std_mn_nr_ctrl=[];
    std_mn_nr_LTG=[];
    for sweep=1:size(analysis_ctrl{1, cell}(1).laser_intensity,1);
        mn_nr_ctrl=mean(analysis_ctrl{1, cell}(sweep).nr_spikes,2);
        mn_nr_LTG=mean(analysis_LTG{1, cell}(sweep).nr_spikes,2);
        std_mn_nr_ctrl(sweep)=std(mn_nr_ctrl);
        std_mn_nr_LTG(sweep)=std(mn_nr_LTG);
    end
   errorbar(las_ctrl ,mn_ctrl,std_mn_nr_ctrl,'k')
   errorbar(las_LTG ,mn_LTG,std_mn_nr_LTG,'k')
    end
end

for cell=1:nr_cells;
    if isfield(analysis_ctrl{1, cell},'elec_intensity')==1
    subplot(ceil(sqrt(nr_cells)), ceil(sqrt(nr_cells)),cell);
    hold on
    % Set x and y values of the current cell for ctrl and LTG conditions
    las_ctrl=analysis_ctrl{1,cell}.elec_intensity;
    mn_ctrl=analysis_ctrl{1,cell}.mean_nr_spikes;
    las_LTG=analysis_LTG{1,cell}.elec_intensity;
    mn_LTG=analysis_LTG{1,cell}.mean_nr_spikes;
    % Plot the current cell and create correpsponding axis labels, 
    % axis values,  legend, title and set the axis
    plot(las_ctrl ,mn_ctrl,'k', 'MarkerSize', 2);
    plot(las_LTG, mn_LTG, 'r','MarkerSize', 2);
    xlabel('stimulus intensity (%)');
    ylabel('average nr of spikes');
    legend('control','LTG');
    title(['neuron: ' num2str(cell)]);
    axis([las_LTG(1), las_LTG(size(las_LTG,1)), 0, 3]);
    end
end
end