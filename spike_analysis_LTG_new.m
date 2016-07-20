function [analysis_ctrl, analysis_LTG]=spike_analysis_LTG_new (ctrl_folder, LTG_folder)

% Analyse electrophysiological data acquired with NEURON matlab program.
% Input files must be devided in two folders, control and LTG condition. 
% This function detects spikes and organizes useful data in two structs (ctrl and LTG).  
% created by PAS on 12-07-2016.

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
    
    if isfield(exper,'nr_electrode_stim')==1 
        
    nr_sweeps=size(exper_ctrl,2);
    for sweep=1:nr_sweeps; 
        
        analysis_ctrl{fil-2}(1).elec_intensity(sweep,1)=ceil(max(exper_ctrl(1,sweep).electrode_comm));
        analysis_LTG{fil-2}(1).elec_intensity(sweep,1)=ceil(max(exper_LTG(1,sweep).electrode_comm));
       
        for stim = 1:exper_ctrl(sweep).nr_electrode_stim; 
        
           %ctrl files
            analysis_ctrl{fil-2}(sweep).stimulus_peaks(stim,1) = ...
            exper_ctrl(sweep).stim_l_dac_endtimes(stim*3,1)/100; 
            %LTG files
            analysis_LTG{fil-2}(sweep).stimulus_peaks(stim,1) = ...
            exper_LTG(sweep).stim_l_dac_endtimes(stim*3,1)/100; 
        end
        
        analysis_ctrl{fil-2}(sweep).time=exper_ctrl(sweep).time;
        analysis_LTG{fil-2}(sweep).time=exper_LTG(sweep).time;
        
        analysis_ctrl{fil-2}(sweep).spike_trace=exper_ctrl(sweep).v_rec;
        analysis_LTG{fil-2}(sweep).spike_trace=exper_LTG(sweep).v_rec;  
        
        %Perform peak detection using peakdet.m and save the times and hights of
        %the peak per sweep.
        for repeat=1:size(analysis_ctrl{fil-2}(sweep).spike_trace,2);
            %Save the inputs for the peakdet
            v_ctrl=analysis_ctrl{fil-2}(sweep).spike_trace(:,repeat) ;
            x_ctrl=analysis_ctrl{fil-2}(sweep).time;
            %find the maximum value in the last sweep and save the value
            %and the indice.
            [M_ctrl,I_ctrl]=max(exper_ctrl(nr_sweeps). v_rec(:,repeat));
            %Rename this trace so its indice can be called upon.
            trace_ctrl=exper_ctrl(nr_sweeps).v_rec(:,repeat);
            %Suptract the value 10ms before the highest peak from the value
            %of the higest peak, this is the relative spike hight.
            spike_hight_ctrl=M_ctrl-trace_ctrl(I_ctrl-100);
            %The delta used in the peakdet. is 75% of the relative peak
            %hight of the highest found peak.
            delta_ctrl=0.75*spike_hight_ctrl;
            %Perform the peakdetection.
            analysis_ctrl{fil-2}(sweep).spike_peaks{repeat}=...
            peakdet(v_ctrl,delta_ctrl,x_ctrl);
        
       %Do the same for the LTG condition.
            v_LTG=analysis_LTG{fil-2}(sweep).spike_trace(:,repeat) ;
            x_LTG=analysis_LTG{fil-2}(sweep).time;
            [M_LTG,I_LTG]=max(exper_LTG(nr_sweeps).v_rec(:,repeat));
            trace_LTG=exper_LTG(nr_sweeps).v_rec(:,repeat);
            spike_hight_LTG=M_LTG-trace_LTG(I_ctrl-100);
            delta_LTG=0.75*spike_hight_LTG;
            analysis_LTG{fil-2}(sweep).spike_peaks{repeat}=...
            peakdet(v_LTG,delta_LTG,x_LTG);
        end
    end
 end
   
       
if isfield(exper,'nr_laser_stim')==1
% Save laser intensities of the stimulations laser
% Do this for each sweep (new laser intensity).
        nr_sweeps=size(exper_ctrl,2);
    for sweep=1:nr_sweeps; 
        analysis_ctrl{fil-2}(1).laser_intensity(sweep,1)=ceil(max(exper_ctrl(1,sweep).laser_int_comm));
        analysis_LTG{fil-2}(1).laser_intensity(sweep,1)=ceil(max(exper_LTG(1,sweep).laser_int_comm));
        
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
            exper_ctrl(sweep).l_dac_endtimes(laser,1)/10; 
        %LTG files
            analysis_LTG{fil-2}(sweep).laser_peaks(ceil(laser/2),1) = ...
            exper_LTG(sweep).l_dac_endtimes(laser,1)/10; 
    end
    
    %Copy the time from the exper file to the analysis file
    %for ctrl and LTG
    analysis_ctrl{fil-2}(sweep).time=...
            exper_ctrl(sweep).time;
    analysis_LTG{fil-2}(sweep).time=...
            exper_LTG(sweep).time;
    
    %Save the traces of all repeats from the exper file to the anaysis file
    %for ctrl and LTG
    analysis_ctrl{fil-2}(sweep).spike_trace=...
            exper_ctrl(sweep).v_rec;
    analysis_LTG{fil-2}(sweep).spike_trace=...
            exper_LTG(sweep).v_rec;   
        
%Perform peak detection using peakdet.m and save the times and hights of
%the peak per sweep.
        for repeat=1:size(analysis_ctrl{fil-2}(sweep).spike_trace,2);
            %Save the inputs for the peakdet
            v_ctrl=analysis_ctrl{fil-2}(sweep).spike_trace(:,repeat) ;
            x_ctrl=analysis_ctrl{fil-2}(sweep).time;
            %find the maximum value in the last sweep and save the value
            %and the indice.
            [M_ctrl,I_ctrl]=max(exper_ctrl(nr_sweeps). v_rec(:,repeat));
            %Rename this trace so its indice can be called upon.
            trace_ctrl=exper_ctrl(nr_sweeps).v_rec(:,repeat);
            %Suptract the value 10ms before the highest peak from the value
            %of the higest peak, this is the relative spike hight.
            spike_hight_ctrl=M_ctrl-trace_ctrl(I_ctrl-100);
            %The delta used in the peakdet. is 75% of the relative peak
            %hight of the highest found peak.
            delta_ctrl=0.75*spike_hight_ctrl;
            %Perform the peakdetection.
            analysis_ctrl{fil-2}(sweep).spike_peaks{repeat}=...
            peakdet(v_ctrl,delta_ctrl,x_ctrl);
        
       %Do the same for the LTG condition.
            v_LTG=analysis_LTG{fil-2}(sweep).spike_trace(:,repeat) ;
            x_LTG=analysis_LTG{fil-2}(sweep).time;
            [M_LTG,I_LTG]=max(exper_LTG(nr_sweeps).v_rec(:,repeat));
            trace_LTG=exper_LTG(nr_sweeps).v_rec(:,repeat);
            spike_hight_LTG=M_LTG-trace_LTG(I_ctrl-100);
            delta_LTG=0.75*spike_hight_LTG;
            analysis_LTG{fil-2}(sweep).spike_peaks{repeat}=...
            peakdet(v_LTG,delta_LTG,x_LTG);
        end
    end
end
end
end