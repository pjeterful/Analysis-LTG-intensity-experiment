%Plot the cumulative succes rates over each laser stimulus for each
%stimulus intenity in different sub plots and for each cell in a different
%figure. Input is an analysis struct for both ctrl and LTG conditions and
%which cells are to be plotted [1, 2, 5] etc. PAS 02-03-2016.

function c_suc_plot=plot_cumulative_succes_rate(analysis_ctrl, analysis_LTG, which_cells)

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
        cs_ctrl=analysis_ctrl{1, cell}(sweep).cumulative_succes_rate{1, 4};
        cs_LTG=analysis_LTG{1, cell}(sweep).cumulative_succes_rate{1, 4};
        % Plot the current sweep of the current cell and create aaxis
        % labels, legend, title and set the axis
        plot(cs_ctrl,'bo');
        plot(cs_LTG, 'ro');
        xlabel('stimulus nr');
        ylabel('cumulative succes rate');
        legend('control','LTG');
        a=num2str(analysis_ctrl{1, cell}(1).laser_intensity(sweep));
        title(['stimulus intensity: ' a]);
        axis([0 34 0 1])
    end
end