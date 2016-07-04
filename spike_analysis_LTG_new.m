%Use this function if both ctrl and LTG files have the same size, otherwise
%use spike_analysis_LTG2.

% Analyse electrophysiological data acquired with NEURON matlab program.
% Input files must be devided in two folders, control and LTG condition. 
% This function detects spikes and registers if they fall within a given spike
% window. With this measurements two structs are created, ctrl and LTG with 
% useful statistics per cell, such as spike-, mean- and cumulative succes rates. 
% First created by PAS on 16-02-2016.

function [analysis_2_ctrl, analysis_2_LTG]=spike_analysis_LTG (ctrl_folder, LTG_folder, spike_window)

% State the input folders and parameters.
ctrl_files  = dir(ctrl_folder);
LTG_files  = dir(LTG_folder);
sw=spike_window; % Think about nomenclature again.

% Check if the folders are the same size.
if size(ctrl_files,2) ~= size(LTG_files,2)
    error('Folder size is not equal')
end

% Create two structs to save output to.
analysis_2_ctrl={};
analysis_2_LTG={};

% Perform primairy spike analysis on the rough data using the function
% spike_analysis_opto (12/1/15, SdK).

% Do this for each file
for fil = 3:size(ctrl_files);
    load(ctrl_files(fil).name);
    ctrl_exper=exper;
    load(LTG_files(fil).name);
    LTG_exper=exper;
    analysis_ctrl=spike_analysis(ctrl_files(fil).name,'juxta');
    analysis_LTG=spike_analysis(LTG_files(fil).name,'juxta');
    
% Save laser intensities of the stimulations laser
% Do this for each sweep (new laser intensity).
    for sweep=1:size(ctrl_exper,2); 
        analysis_2_ctrl{fil-2}(1).laser_intensity(sweep,1)=analysis_ctrl{1,sweep}.laser_int_max;
        analysis_2_LTG{fil-2}(1).laser_intensity(sweep,1)=analysis_LTG{1,sweep}.laser_int_max;
        
% Save the start times of the laser stimulations per frequency in
% analysis_2.laser peaks, if the stimulus intensity is 0,fill it with NaN

    for laser = 1:2:ctrl_exper(sweep).nr_laser_stim*2; 
        if analysis_2_ctrl{fil-2}(1).laser_intensity(sweep,1)==0;
        %ctrl files   
            analysis_2_ctrl{fil-2}(sweep).laser_peaks(ceil(laser/2),1) = NaN;
        %LTG files
           analysis_2_LTG{fil-2}(sweep).laser_peaks(ceil(laser/2),1) = NaN; 
            continue
        end
        %ctrl files
            analysis_2_ctrl{fil-2}(sweep).laser_peaks(ceil(laser/2),1) = ...
            ctrl_exper(sweep).l_dac_endtimes(laser,1)/10; 
        %LTG files
            analysis_2_LTG{fil-2}(sweep).laser_peaks(ceil(laser/2),1) = ...
            LTG_exper(sweep).l_dac_endtimes(laser,1)/10; 
    end
    
    %Copy the time from the exper file to the anaysis file
    %for ctrl and LTG
    analysis_2_ctrl{fil-2}(sweep).time=...
            ctrl_exper(sweep).time;
    analysis_2_LTG{fil-2}(sweep).time=...
            LTG_exper(sweep).time;
    
    %Save the traces of all repeats from the exper file to the anaysis file
    %for cntrl and LTG
    analysis_2_ctrl{fil-2}(sweep).spike_trace=...
            ctrl_exper(sweep).v_rec;
    analysis_2_LTG{fil-2}(sweep).spike_trace=...
            LTG_exper(sweep).v_rec;       

        for stim= 1:size(analysis_2_ctrl{fil-2}(sweep).laser_peaks);
            % ctrl files
            analysis_2_ctrl{fil-2}(sweep).det_peaks{repeat}(stim,1:3)=0;
            % LTG files
            analysis_2_LTG{fil-2}(sweep).det_peaks{repeat}(stim,1:3)=0;
        end
    end
    end
end