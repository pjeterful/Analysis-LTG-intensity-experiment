%Plot the running succes rates in a separte figure for each cell and a
%seperate subplot for each stimulus intesnity. input is a analysis ctrl and
%LTG struct and which cells you would like to have plotted. Outputs are
%plots of all runnign succes rates.
%Created 30-06-2016 PAS 
function run_av_suc_plot=plot_running_succes(analysis_ctrl, analysis_LTG, which_cells)

% Create a new figure for each cell
for cell=[which_cells];
    figure(cell);
    
    % Calculate the number of sweeps
    nr_sweeps=size(analysis_ctrl{1, cell},2);
    
    % Create a subplot for each sweep
    for sweep=2:nr_sweeps; 
        subplot(ceil(sqrt(nr_sweeps)), ceil(sqrt(nr_sweeps)),sweep-1)
        hold on
        % Set the y values for ctrl and LTG condition in the current cell
        % and sweep
        cs_ctrl=analysis_ctrl{1, cell}(sweep).running_average_succes;
        cs_LTG=analysis_LTG{1, cell}(sweep).running_average_succes;
        % Plot the current sweep of the current cell and create axis
        % labels, legend, title and set the axis
        plot(cs_ctrl,'ko');
        plot(cs_LTG, 'ro');
        xlabel('stimulus nr');
        ylabel('running succes rate');
        legend('control','LTG');
        a=num2str(analysis_ctrl{1, cell}(1).laser_intensity(sweep));
        title(['stimulus intensity: ' a]);
        axis([0 32 0 1])
    end
end