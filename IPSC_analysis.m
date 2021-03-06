function [analysis_ctrl, analysis_LTG]=IPSC_analysis (ctrl_folder, LTG_folder)

% State the input folders and parameters.
ctrl_files  = dir(ctrl_folder);
LTG_files  = dir(LTG_folder);

% Check if the folders are the same size.
if size(ctrl_files,2) ~= size(LTG_files,2)
    error('Folder size is not equal')
end

% Create two structs to save output to.
analysis_ctrl={};
analysis_LTG={};


% Do this for each file
for fil = 3:size(ctrl_files);
    load(ctrl_files(fil).name);
    exper_ctrl=exper;
    meta_ctrl=meta;
    load(LTG_files(fil).name);
    exper_LTG=exper;
    meta_LTG=meta;
 %copy the filenames of each cell to the new structs.   
    analysis_ctrl{fil-2}.cell_name=meta_ctrl.filename ;
    analysis_LTG{fil-2}.cell_name=meta_LTG.filename ;
    
     %copy the filenames of each cell to the new structs.   
    analysis_ctrl{fil-2}(1,1).cell_name=meta_ctrl.filename ;
    analysis_LTG{fil-2}(1,1).cell_name=meta_LTG.filename ;
    analysis_ctrl{fil-2}(2,1).cell_name=meta_ctrl.prot ;
    analysis_LTG{fil-2}(2,1).cell_name=meta_ctrl.prot ;
    
    % Save laser intensities of the stimulations laser
% Do this for each sweep (new laser intensity).
        nr_sweeps=size(exper_ctrl,2);
    for sweep=1:nr_sweeps; 
        analysis_ctrl{fil-2}(1).laser_intensity(sweep,1)=10*ceil(max(exper_ctrl(1,sweep).laser_int_comm));
        analysis_LTG{fil-2}(1).laser_intensity(sweep,1)=10*ceil(max(exper_LTG(1,sweep).laser_int_comm));
        
% Save the start times of the laser stimulations per frequency in
% analysis_2.laser peaks, if the stimulus intensity is 0,fill it with NaN

    for laser = 1:2:exper_ctrl(sweep).nr_laser_stim*2; 
        if analysis_ctrl{fil-2}(1).laser_intensity(sweep,1)==0;
        %ctrl files   
            analysis_ctrl{fil-2}(sweep).laser_peaks(ceil(laser/2),1) = NaN;
        %LTG files
           analysis_LTG{fil-2}(sweep).laser_peaks(ceil(laser/2),1) = NaN; 
            continue
        end
        %ctrl files
            analysis_ctrl{fil-2}(sweep).laser_peaks(ceil(laser/2),1) = ...
            exper_ctrl(1,sweep).l_dac_endtimes(laser,1)/10; 
        %LTG files
            analysis_LTG{fil-2}(sweep).laser_peaks(ceil(laser/2),1) = ...
            exper_LTG(1,sweep).l_dac_endtimes(laser,1)/10; 
    end
    
    %Copy the time from the exper file to the analysis file
    %for ctrl and LTG
    analysis_ctrl{fil-2}(sweep).time=...
            exper_ctrl(1,sweep).time;
    analysis_LTG{fil-2}(sweep).time=...
            exper_LTG(1,sweep).time;
    
    %Save the traces of all repeats from the exper file to the anaysis file
    %for ctrl and LTG
    analysis_ctrl{fil-2}(sweep).spike_trace=...
            exper_ctrl(1,sweep).i_rec;
    analysis_LTG{fil-2}(sweep).spike_trace=...
            exper_LTG(1,sweep).i_rec; 
        
        %Detect minima in the IPSC trace after each laser pulse and save the times and currents of
        %the peak per sweep and repeat.
        for repeat=1:size(analysis_ctrl{fil-2}(sweep).spike_trace,2);
            for stim=1:size(analysis_ctrl{fil-2}(sweep).laser_peaks,1);
                %save the indice of the laser pulse, if there is no laser
                %pulse continue
                laser=analysis_ctrl{fil-2}(sweep).laser_peaks(stim,1)*10;
                if isnan(laser)==1;
                    continue
                end
                %
                dist=analysis_ctrl{fil-2}(sweep).laser_peaks(2,1)*10-analysis_ctrl{fil-2}(sweep).laser_peaks(1,1)*10;
                [v,i]=min(analysis_ctrl{fil-2}(sweep).spike_trace(laser:laser+dist,repeat));
                analysis_ctrl{fil-2}(sweep).IPSC_peaks{1,repeat}(stim,1)=(i+laser)/10;
                analysis_ctrl{fil-2}(sweep).IPSC_peaks{1,repeat}(stim,2)=v;
        
       %Do the same for the LTG condition.
                laser=analysis_LTG{fil-2}(sweep).laser_peaks(stim,1)*10;
                dist=analysis_LTG{fil-2}(sweep).laser_peaks(2,1)*10-analysis_LTG{fil-2}(sweep).laser_peaks(1,1)*10;
                [v,i]=min(analysis_LTG{fil-2}(sweep).spike_trace(laser:laser+dist,repeat));
                analysis_LTG{fil-2}(sweep).IPSC_peaks{1,repeat}(stim,1)=(i+laser)/10;
                analysis_LTG{fil-2}(sweep).IPSC_peaks{1,repeat}(stim,2)=v;
        end
    end
    end
end
end