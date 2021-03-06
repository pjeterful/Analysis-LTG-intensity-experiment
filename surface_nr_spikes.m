%Create a surface plot of the difference in nr of spikes following a laser puls against
%all stimulus intensities and stimulus numbers. Inputs are analysis ctrl and
%LTG structs, which cells you would like to plot [], 
%Created 18-05-2016 PAS
function surf_nr_spikes_plot=surface_nr_spikes(analysis_ctrl, analysis_LTG, which_cells)

   
for cell=which_cells;
    %Use this code if there is laser stimulation
    if isfield(analysis_ctrl{1, cell},'laser_intensity')==1
    nr_sweeps=size(analysis_ctrl{1, cell}(1).laser_intensity  ,1)-1;
    nr_stim=size(analysis_ctrl{1, cell}(1).running_average_nr_spikes,1);  
    %Clear all preexisting values
   clear x z y x_ctrl y_ctrl z_ctrl z_LTG
%Create z and y values for ctrl and LTG
    for sweep=1:nr_sweeps;     
        z_ctrl(:,sweep)=analysis_ctrl{1, cell}(sweep+1).running_average_nr_spikes;
        z_LTG(:,sweep)=analysis_LTG{1, cell}(sweep+1).running_average_nr_spikes;
        y_ctrl(:,sweep)=1:(size(analysis_ctrl{1, cell}(2).laser_peaks,1));
    end
    
    max=(size(analysis_ctrl{1, cell}(1).laser_intensity,1));
    %Determine the x by counting all stim
    for stim=1:nr_stim;
        x_ctrl(:,stim)=analysis_ctrl{1, cell}(1).laser_intensity(2:(max)) ;
    end
    %Create a new figure for each cell
    figure(cell);
    %Change to vectors
    y_ctrl=y_ctrl';
    z_ctrl=z_ctrl';
    z_LTG=z_LTG';
    %Determing x, y and z, this can be altered if need be.
    x=x_ctrl;
    y=y_ctrl;
    z=z_LTG;
    %Plot the surface plot and label the axis.
    M=surf(y,x,z);
    caxis([ 0 3]);
    colormap(jet(15));
    ylabel('Laser intensity (%)');
    xlabel('Stimulus number');
    zlabel('LTG effect on nr of spikes');
    end
    
    %Use this code if there is electrical stimulation via a stimulus
    %electrode
if isfield(analysis_ctrl{1, cell},'elec_intensity')==1
    nr_sweeps=size(analysis_ctrl{1, cell}(1).elec_intensity  ,1)-1;
    nr_stim=size(analysis_ctrl{1, cell}(1).running_average_nr_spikes,1);  
    %Clear all preexisting values
    clear x z y x_ctrl y_ctrl z_ctrl z_LTG
    %Create z and y values for ctrl and LTG
    for sweep=1:nr_sweeps;     
        z_ctrl(:,sweep)=analysis_ctrl{1, cell}(sweep+1).running_average_nr_spikes;
        z_LTG(:,sweep)=analysis_LTG{1, cell}(sweep+1).running_average_nr_spikes;
        y_ctrl(:,sweep)=1:(size(analysis_ctrl{1, cell}(2).stimulus_peaks,1));
    end
    
    max=(size(analysis_ctrl{1, cell}(1).elec_intensity,1));
    %Determine the x by counting all stim
    for stim=1:nr_stim;
        x_ctrl(:,stim)=analysis_ctrl{1, cell}(1).elec_intensity(2:(max)) ;
    end
    %Create a new figure for each cell
    figure(cell);
    %Change to vectors
    y_ctrl=y_ctrl';
    z_ctrl=z_ctrl';
    z_LTG=z_LTG';
    %Determing x, y and z, this can be altered if need be.
    x=x_ctrl;
    y=y_ctrl;
    z=z_LTG;
    %Plot the surface plot and label the axis.
    M=surf(y,x,z);
    caxis([ 0 2]);
    colormap(jet(10));
    ylabel('Laser intensity (%)');
    xlabel('Stimulus number');
    zlabel('LTG effect on nr of spikes');
    end
    
end
end