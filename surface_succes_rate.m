function surf_suc_plot=surface_succes_rate(analysis_ctrl, analysis_LTG, which_cells)

for cell=which_cells;
    red=0;
    
    nr_sweeps=size(analysis_ctrl{1, cell},2)-1;
    nr_stim=size(analysis_ctrl{1, cell}(3).succes_rate,1);  
    % Create a subplot for each sweep
   clear x
   clear z
   clear y
   clear x_ctrl
   clear y_ctrl
   clear z_ctrl
   clear z_LTG
   
    for sweep=1:(nr_sweeps-red);     
        z_ctrl(:,sweep)=analysis_ctrl{1, cell}(sweep+1).succes_rate;
        z_LTG(:,sweep)=analysis_LTG{1, cell}(sweep+1).succes_rate;
        y_ctrl(:,sweep)=1:size(analysis_ctrl{1, 6}(2).laser_peaks,1);
    end
    
    max=size(analysis_ctrl{1, cell}(1).laser_intensity,1);
    for stim=1:nr_stim;
        x_ctrl(:,stim)=analysis_ctrl{1, cell}(1).laser_intensity(2:(max-red)) ;
    end
    figure(cell);
    y_ctrl=y_ctrl';
    z_ctrl=z_ctrl';
   
    z_LTG=z_LTG';
    
    x=x_ctrl;
    y=y_ctrl;
    z=z_ctrl-z_LTG;
    M=surf(y,x,z);
    ylabel('Laser intensity (%)');
    xlabel('Stimulus number');
    zlabel('LTG effect on succes rate');
    end