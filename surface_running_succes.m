%Create a surface plot of the difference in running average firing probability against
%all stimulus intensities and stimulus numbers. Inputs areanalysis ctrl and
%LTG structs, which cells you would like to plot [], and which part of the
%plot you would like to cut of at the end if there is a lack of interesting
%points, make this 0 at the first run to see if its aplicable.
%Created 2016 PAS
function surf_run_suc_plot=surface_running_succes(analysis_ctrl, analysis_LTG, which_cells, reduction)

for cell=which_cells;
    
    red=reduction;
    nr_sweeps=size(analysis_ctrl{1, cell},2)-1;
    nr_stim=size(analysis_ctrl{1, cell}(1).running_average_succes,1);  
    %Clear all preexisting values
   clear x
   clear z
   clear y
   clear x_ctrl
   clear y_ctrl
   clear z_ctrl
   clear z_LTG
%Create z and y values for ctrl and LTG
    for sweep=1:(nr_sweeps-red);     
        z_ctrl(:,sweep)=analysis_ctrl{1, cell}(sweep+1).running_average_succes;
        z_LTG(:,sweep)=analysis_LTG{1, cell}(sweep+1).running_average_succes;
        y_ctrl(:,sweep)=1:(size(analysis_ctrl{1, 6}(2).laser_peaks,1));
    end
    
    max=(size(analysis_ctrl{1, cell}(1).laser_intensity,1));
    %Determine the x by counting all stim
    for stim=1:nr_stim;
        x_ctrl(:,stim)=analysis_ctrl{1, cell}(1).laser_intensity(2:(max-red)) ;
    end
    %Create a new figure for each cell
    figure(cell);
    %Change to vectors
    y_ctrl=y_ctrl';
    z_ctrl=z_ctrl';
    %Create the difference between LTG and control by substracting
    z_LTG=z_ctrl-z_LTG';
    %Determing x, y and z, this can be altered if need be.
    x=x_ctrl;
    y=y_ctrl;
    z=z_LTG;
    %Plot the surface plot and label the axis.
    M=surf(y,x,z);
    ylabel('Laser intensity (%)');
    xlabel('Stimulus number');
    zlabel('LTG effect on firing probability');
end
end