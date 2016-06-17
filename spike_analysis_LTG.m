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
        
% Save the times of all detected peaks to data file analysis_2.spike_peaks.
% Do this for every repeat 
    for repeat=1:size(analysis_ctrl{1, 1}.spikes,2);
         
         analysis_2_ctrl{fil-2}(sweep).spike_peaks{repeat}=0;
         analysis_2_LTG{fil-2}(sweep).spike_peaks{repeat}=0;
        % control files
        for stim = 1:size(analysis_ctrl{1, sweep}.spikes{1, repeat})  ;
            analysis_2_ctrl{fil-2}(sweep).spike_peaks{repeat}(stim,1)=...
            analysis_ctrl{1, sweep}.spikes{1, repeat}(stim); 
        end
        % LTG files
        for stim = 1:size(analysis_LTG{1, sweep}.spikes{1, repeat})  ;
        analysis_2_LTG{fil-2}(sweep).spike_peaks{repeat}(stim,1)=...
            analysis_LTG{1, sweep}.spikes{1, repeat}(stim); 
        end
            
% Calculate the times between each laser pulse and the first following peak
% in the spike trace.
%        lasertimes=analysis_2_ctrl{fil-2}(sweep).laser_peaks;
%        spiketimes=analysis_2_ctrl{fil-2}(sweep).spike_peaks{repeat} ; 
%        for stim=1:size(lasertimes,1);
%            analysis_2_ctrl{fil-2}(sweep).spikes_after_laser(stim, repeat)=...
%            find(spiketimes > lasertimes(stim) & spiketimes < lasertimes(stim) + 10,1);
%            if isempty (analysis_2_ctrl{fil-2}(sweep).spikes_after_laser(stim, repeat));
%               analysis_2_ctrl{fil-2}(sweep).spikes_after_laser(stim, repeat)=NaN;
%            end
%        end
        
% Create a struct  with the same size of analysis_2.laser_peaks,and fill it with 0

        for stim= 1:size(analysis_2_ctrl{fil-2}(sweep).laser_peaks);
            % ctrl files
            analysis_2_ctrl{fil-2}(sweep).det_peaks{repeat}(stim,1:3)=0;
            % LTG files
            analysis_2_LTG{fil-2}(sweep).det_peaks{repeat}(stim,1:3)=0;
        end

% test for each start time of a laser puls if it has a corresponing
% peak in the recorded trace within a given spike window (sw). create 
% analysis_2.det_peaks and give vlue 1 if a peak is detected and 0 if no peak
% is detected withing the spike window. Also give the time and voltage
% of each peak if detected within the spike window.

        if analysis_ctrl{1, sweep}.spike_nr(1,repeat)==0;
        continue
        end
        for stim=1:size(analysis_2_ctrl{fil-2}(sweep).laser_peaks,1);
            for spik=1:size(analysis_2_ctrl{fil-2}(sweep).spike_peaks{1,repeat},1);
                min_spike_window=analysis_2_ctrl{fil-2}(sweep).laser_peaks(stim,1);
                max_spike_window=analysis_2_ctrl{fil-2}(sweep).laser_peaks(stim,1)+sw;
                spike=analysis_ctrl{1,sweep}.spikes{1,repeat}(spik);
                if analysis_2_ctrl{fil-2}(sweep).det_peaks{repeat}(stim)==1;
                    continue
                end
                if spike > min_spike_window && spike < max_spike_window;
                    analysis_2_ctrl{fil-2}(sweep).det_peaks{repeat}(stim)=1;
                    analysis_2_ctrl{fil-2}(sweep).det_peaks{repeat}(stim,2)=...
                        analysis_ctrl{1,sweep}.spikes{1,repeat}(spik);
                    analysis_2_ctrl{fil-2}(sweep).det_peaks{repeat}(stim,3)=...
                       analysis_ctrl{1,sweep}.spikes{1,repeat}(spik,2);
                else
                    analysis_2_ctrl{fil-2}(sweep).det_peaks{repeat}(stim)=0;
                    analysis_2_ctrl{fil-2}(sweep).det_peaks{repeat}(stim,2)=0;
                    analysis_2_ctrl{fil-2}(sweep).det_peaks{repeat}(stim,3)=0;
                end
            end
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    %And again for LTG files
    
    if analysis_LTG{1, sweep}.spike_nr(1,repeat)==0;
        continue
    end
        for stim=1:size(analysis_2_LTG{fil-2}(sweep).laser_peaks,1);
            for spik=1:size(analysis_2_LTG{fil-2}(sweep).spike_peaks{1,repeat},1);
                min_spike_window=analysis_2_LTG{fil-2}(sweep).laser_peaks(stim,1);
                max_spike_window=analysis_2_LTG{fil-2}(sweep).laser_peaks(stim,1)+sw;
                spike=analysis_LTG{1,sweep}.spikes{1,repeat}(spik);
                if analysis_2_LTG{fil-2}(sweep).det_peaks{repeat}(stim)==1;
                    continue
                end
                if spike > min_spike_window && spike < max_spike_window;
                    analysis_2_LTG{fil-2}(sweep).det_peaks{repeat}(stim)=1;
                    analysis_2_LTG{fil-2}(sweep).det_peaks{repeat}(stim,2)=...
                        analysis_LTG{1,sweep}.spikes{1,repeat}(spik);
                    analysis_2_LTG{fil-2}(sweep).det_peaks{repeat}(stim,3)=...
                       analysis_LTG{1,sweep}.spikes{1,repeat}(spik,2);
                else
                    analysis_2_LTG{fil-2}(sweep).det_peaks{repeat}(stim)=0;
                    analysis_2_LTG{fil-2}(sweep).det_peaks{repeat}(stim,2)=0;
                    analysis_2_LTG{fil-2}(sweep).det_peaks{repeat}(stim,3)=0;
                end
            end
        end
    end
    
%Calculate the succes rates per stimulus intensity

for stim=1:size(analysis_2_ctrl{fil-2}(sweep).det_peaks{1, repeat},1);
    %For ctrl files
    repeat1_c=analysis_2_ctrl{fil-2}(sweep).det_peaks{1,1}(stim,1);
    repeat2_c=analysis_2_ctrl{fil-2}(sweep).det_peaks{1,2}(stim,1);
    repeat3_c=analysis_2_ctrl{fil-2}(sweep).det_peaks{1,3}(stim,1);
    analysis_2_ctrl{fil-2}(sweep).succes_rate(stim,1)=(repeat1_c+repeat2_c+repeat3_c)/3;
    %For LTG files
    repeat1_L=analysis_2_LTG{fil-2}(sweep).det_peaks{1,1}(stim,1);
    repeat2_L=analysis_2_LTG{fil-2}(sweep).det_peaks{1,2}(stim,1);
    repeat3_L=analysis_2_LTG{fil-2}(sweep).det_peaks{1,3}(stim,1);
    analysis_2_LTG{fil-2}(sweep).succes_rate(stim,1)=(repeat1_L+repeat2_L+repeat3_L)/3;
end

analysis_2_ctrl{fil-2}(1).mean_succes_rate(sweep,1)=mean(analysis_2_ctrl{fil-2}(sweep).succes_rate);
analysis_2_LTG{fil-2}(1).mean_succes_rate(sweep,1)=mean(analysis_2_LTG{fil-2}(sweep).succes_rate);        

%Calculate the cumulative succes rates per sweep (this could be stim. 
%frequency, stim intesnity etc.) at each laser stimulus.

for repeat=1:size(analysis_ctrl{1, 1}.spikes,2);
    tot_suc_det_spike_c=0;
    tot_suc_det_spike_L=0;
    for stim=1:size(analysis_2_ctrl{fil-2}(sweep).det_peaks{1, repeat},1);
        %For control
        tot_suc_det_spike_c=tot_suc_det_spike_c + analysis_2_ctrl{fil-2}(sweep).det_peaks{1,repeat}(stim,1);
        analysis_2_ctrl{fil-2}(sweep).cumulative_succes_rate {repeat}(stim,1)=...
        tot_suc_det_spike_c/stim;
        %For LTG
        tot_suc_det_spike_L=tot_suc_det_spike_L + analysis_2_LTG{fil-2}(sweep).det_peaks{1,repeat}(stim,1);
        analysis_2_LTG{fil-2}(sweep).cumulative_succes_rate {repeat}(stim,1)=...
        tot_suc_det_spike_L/stim;
    end
end

% Calculate the mean cumulative succes rate of all repeats per stimulus
    for stim=1:size(analysis_2_ctrl{fil-2}(sweep).det_peaks{1, repeat},1);
        analysis_2_ctrl{fil-2}(sweep).cumulative_succes_rate {4}(stim,1)=...
        (analysis_2_ctrl{fil-2}(sweep).cumulative_succes_rate {1}(stim,1)+...
        analysis_2_ctrl{fil-2}(sweep).cumulative_succes_rate {2}(stim,1)+...
        analysis_2_ctrl{fil-2}(sweep).cumulative_succes_rate {3}(stim,1))/3;
    %For LTG
        analysis_2_LTG{fil-2}(sweep).cumulative_succes_rate {4}(stim,1)=...
        (analysis_2_LTG{fil-2}(sweep).cumulative_succes_rate {1}(stim,1)+...
        analysis_2_LTG{fil-2}(sweep).cumulative_succes_rate {2}(stim,1)+...
        analysis_2_LTG{fil-2}(sweep).cumulative_succes_rate {3}(stim,1))/3;
    end
    end
end
end