function[FS_MIN_INT, FS_MAX_INT, LS_MIN_INT, LS_MAX_INT ]=calculate_SSI(analysis_ctrl)
nr_cells=size(analysis_ctrl,2);
for cell=1:nr_cells;
    nr_sweeps=size(analysis_ctrl{1, cell}(1).laser_intensity  , 1);
    mean_FS=NaN;
    mean_LS=NaN;
    count=0;
    for sweep=1:nr_sweeps;
        nr_stim=size(analysis_ctrl{1, cell}(sweep).SSI,1);
        mean_FS=mean(analysis_ctrl{1, cell}(sweep).SSI(1,:));
        mean_LS=mean(analysis_ctrl{1, cell}(sweep).SSI(nr_stim,:));
        if isnan(mean_FS)==0 && isnan(mean_LS)==0;
            count=count+1;
            if count==1;
            FS_MIN_INT(1,cell)=mean_FS;
            LS_MIN_INT(1,cell)=mean_LS;
        end  
    end
    FS_MAX_INT(1,cell)= mean(analysis_ctrl{1, cell}(nr_sweeps).SSI(1,:)); 
    LS_MAX_INT(1,cell)= mean(analysis_ctrl{1, cell}(nr_sweeps).SSI(nr_stim,:)); 
end
end
        