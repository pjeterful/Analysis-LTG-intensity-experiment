 %This function creates a new variable nr_spikes in each cell for each
 %sweep, this variable containes the number of spikes following a laser
 %stimulus puls within a giving window. This will be given for each repeat
 %and in the last column the average. Input is an analysis_ctrl and LTG
 %file, a timewindow (ms) after the laser within which the spikes should be counted
 %and the size of the reading frame of the running average, the standard
 %value for the frame is 5.
 %created 14-5-2016.
 
 function [analysis_ctrl, analysis_LTG]=create_doublet(analysis_ctrl, analysis_LTG, window, frame)
 if isfield(analysis_ctrl{1, 1},'laser_intensity')==1
 for cell=1:size(analysis_ctrl,2);    
     for sweep=1:size(analysis_ctrl{1, cell}(1).laser_intensity  ,1) 
         %Save the lasertimes for each laser stimulus lper sweep.
         lasertimes_ctrl=analysis_ctrl{1,cell}(sweep).laser_peaks;
         nr_repeats=size(analysis_ctrl{1, cell}(sweep).spike_peaks,2);
         for repeat=1:nr_repeats;
             %Save the times of the spikes for each reapeat.
             spikes_ctrl{1,repeat}=analysis_ctrl{1,cell}(sweep).spike_peaks{1,repeat};               
             for stim=1:size(lasertimes_ctrl,1);
                 %Find the spikes following a laser puls, within 
                 %the giving window for each repeat and sweep.
                 SAL_ctrl=find(spikes_ctrl{1,repeat} > lasertimes_ctrl(stim)...
                      & spikes_ctrl{1,repeat} < (lasertimes_ctrl(stim) + window));
                  %If none are found set the amount of found spikes to zero,
                  %otherwhise count the amount of found spikes per laser
                  %stiumulus for each repeat and sweep.
                 if  isempty (SAL_ctrl);
                      analysis_ctrl{1,cell}(sweep).nr_spikes(stim,repeat)=0;
                 else
                      analysis_ctrl{1,cell}(sweep).nr_spikes(stim,repeat)=size(SAL_ctrl,1);
                 end
             end
         end
       % Ceate a mean per sweep
         analysis_ctrl{1,cell}(1).mean_nr_spikes(sweep,1)=...
         mean(mean(analysis_ctrl{1,cell}(sweep).nr_spikes));
         % Calculate the mean amount of spikes of all repeats per sweep and
         % cell. Place this value in the last column.
         analysis_ctrl{1,cell}(sweep).nr_spikes(:,nr_repeats)=...
         mean(analysis_ctrl{1,cell}(sweep).nr_spikes,2); 
         %create a running average of the douclets
         av_doublet_ctrl=analysis_ctrl{1,cell}(sweep).nr_spikes(:,nr_repeats)';
         mask= ones (1,frame)/frame;
         analysis_ctrl{1,cell}(sweep).running_average_nr_spikes=...
         conv(av_doublet_ctrl, mask)';
         sctrl=size(analysis_ctrl{1,cell}(sweep).running_average_nr_spikes,1);
         %Cut of the acces values created by the moving average at the end
         analysis_ctrl{1,cell}(sweep).running_average_nr_spikes=...
         analysis_ctrl{1,cell}(sweep).running_average_nr_spikes(1:(sctrl-frame+1));
         %Because the running avregages are devided by the window, the values 
         %without a complete window should be multiplicated by the window*
         %the number values in the window at that point.
         for f=1:frame;
            analysis_ctrl{1,cell}(sweep).running_average_nr_spikes(f,1)=...
            analysis_ctrl{1,cell}(sweep).running_average_nr_spikes(f,1)/f*frame;
         end
     end
 end
 
 %Dow the same for the LTG file.
 for cell=1:size(analysis_LTG,2);
     for sweep=1:size(analysis_LTG{1, cell}(1).laser_intensity  ,1)  
         lasertimes_LTG=analysis_LTG{1,cell}(sweep).laser_peaks;
         nr_repeats=size(analysis_LTG{1, cell}(sweep).spike_peaks,2);
         for repeat=1:nr_repeats;
             spikes_LTG{1,repeat}=analysis_LTG{1,cell}(sweep).spike_peaks{1,repeat};               
             for stim=1:size(lasertimes_LTG,1);
                 SAL_LTG=find(spikes_LTG{1,repeat} > lasertimes_LTG(stim)...
                      & spikes_LTG{1,repeat} < (lasertimes_LTG(stim) + window));      
                 if  isempty (SAL_LTG);
                      analysis_LTG{1,cell}(sweep).nr_spikes(stim,repeat)=0;
                 else
                      analysis_LTG{1,cell}(sweep).nr_spikes(stim,repeat)=size(SAL_LTG,1);
                 end
             end
         end
       % Ceate a mean per sweep
         analysis_LTG{1,cell}(1).mean_nr_spikes(sweep,1)=...
         mean(mean(analysis_LTG{1,cell}(sweep).nr_spikes));
       % Calculate the mean amount of spikes of all repeats per sweep and
       % cell. Place this value in the last column.
         analysis_LTG{1,cell}(sweep).nr_spikes(:,nr_repeats+1)=...
         mean(analysis_LTG{1,cell}(sweep).nr_spikes,2);
       % Create a running average of the doublets
         av_doublet_LTG=analysis_LTG{1,cell}(sweep).nr_spikes(:,nr_repeats+1)';
         mask= ones (1,frame)/frame;
         analysis_LTG{1,cell}(sweep).running_average_nr_spikes=...
         conv(av_doublet_LTG, mask)';
         sLTG=size(analysis_LTG{1,cell}(sweep).running_average_nr_spikes,1);
         %Cut of the acces values created by the moving average at the end
         analysis_LTG{1,cell}(sweep).running_average_nr_spikes=...
         analysis_LTG{1,cell}(sweep).running_average_nr_spikes(1:(sLTG-frame+1));
         %Because the running avregages are devided by the window, the values 
         %without a complete window should be multiplicated by the window*
         %the number values in the window at that point.
         for f=1:frame;
            analysis_LTG{1,cell}(sweep).running_average_nr_spikes(f,1)=...
            analysis_LTG{1,cell}(sweep).running_average_nr_spikes(f,1)/f*frame;
         end
     end
 end
 end
 
  if isfield(analysis_ctrl{1, 1},'elec_intensity')==1
 for cell=1:size(analysis_ctrl,2);    
     for sweep=1:size(analysis_ctrl{1, cell}(1).elec_intensity  ,1)  
         %Save the lasertimes for each laser stimulus lper sweep.
         stimulustimes_ctrl=analysis_ctrl{1,cell}(sweep).stimulus_peaks;
         nr_repeats=size(analysis_ctrl{1, cell}(sweep).spike_peaks,2);
         for repeat=1:nr_repeats;
             %Save the times of the spikes for each reapeat.
             spikes_ctrl{1,repeat}=analysis_ctrl{1,cell}(sweep).spike_peaks{1,repeat};               
             for stim=1:size(stimulustimes_ctrl,1);
                 %Find the spikes following a laser puls, within 
                 %the giving window for each repeat and sweep.
                 SAL_ctrl=find(spikes_ctrl{1,repeat} > stimulustimes_ctrl(stim)...
                      & spikes_ctrl{1,repeat} < (stimulustimes_ctrl(stim) + window));
                  %If none are found set the amount of found spikes to zero,
                  %otherwhise count the amount of found spikes per stimulus
                  %stiumulus for each repeat and sweep.
                 if  isempty (SAL_ctrl);
                      analysis_ctrl{1,cell}(sweep).nr_spikes(stim,repeat)=0;
                 else
                      analysis_ctrl{1,cell}(sweep).nr_spikes(stim,repeat)=size(SAL_ctrl,1);
                 end
             end
         end
       % Ceate a mean per sweep
         analysis_ctrl{1,cell}(1).mean_nr_spikes(sweep,1)=...
         mean(mean(analysis_ctrl{1,cell}(sweep).nr_spikes));
         % Calculate the mean amount of spikes of all repeats per sweep and
         % cell. Place this value in the last column.
         analysis_ctrl{1,cell}(sweep).nr_spikes(:,nr_repeats+1)=...
         mean(analysis_ctrl{1,cell}(sweep).nr_spikes,2); 
         %create a running average of the douclets
         av_doublet_ctrl=analysis_ctrl{1,cell}(sweep).nr_spikes(:,nr_repeats+1)';
         mask= ones (1,frame)/frame;
         analysis_ctrl{1,cell}(sweep).running_average_nr_spikes=...
         conv(av_doublet_ctrl, mask)';
         sctrl=size(analysis_ctrl{1,cell}(sweep).running_average_nr_spikes,1);
         %Cut of the acces values created by the moving average at the end
         analysis_ctrl{1,cell}(sweep).running_average_nr_spikes=...
         analysis_ctrl{1,cell}(sweep).running_average_nr_spikes(1:(sctrl-frame+1));
         %Because the running avregages are devided by the window, the values 
         %without a complete window should be multiplicated by the window*
         %the number values in the window at that point.
         for f=1:frame;
            analysis_ctrl{1,cell}(sweep).running_average_nr_spikes(f,1)=...
            analysis_ctrl{1,cell}(sweep).running_average_nr_spikes(f,1)/f*frame;
         end
     end
 end
 
 %Dow the same for the LTG file.
 for cell=1:size(analysis_LTG,2);
    for sweep=1:size(analysis_LTG{1, cell}(1).elec_intensity  ,1) 
         stimulustimes_LTG=analysis_LTG{1,cell}(sweep).stimulus_peaks;
         nr_repeats=size(analysis_LTG{1, cell}(sweep).spike_peaks,2);
         for repeat=1:nr_repeats;
             spikes_LTG{1,repeat}=analysis_LTG{1,cell}(sweep).spike_peaks{1,repeat};               
             for stim=1:size(stimulustimes_LTG,1);
                 SAL_LTG=find(spikes_LTG{1,repeat} > stimulustimes_LTG(stim)...
                      & spikes_LTG{1,repeat} < (stimulustimes_LTG(stim) + window));      
                 if  isempty (SAL_LTG);
                      analysis_LTG{1,cell}(sweep).nr_spikes(stim,repeat)=0;
                 else
                      analysis_LTG{1,cell}(sweep).nr_spikes(stim,repeat)=size(SAL_LTG,1);
                 end
             end
         end
       % Ceate a mean per sweep
         analysis_LTG{1,cell}(1).mean_nr_spikes(sweep,1)=...
         mean(mean(analysis_LTG{1,cell}(sweep).nr_spikes));
       % Calculate the mean amount of spikes of all repeats per sweep and
       % cell. Place this value in the last column.
         analysis_LTG{1,cell}(sweep).nr_spikes(:,nr_repeats+1)=...
         mean(analysis_LTG{1,cell}(sweep).nr_spikes,2);
       % Create a running average of the doublets
         av_doublet_LTG=analysis_LTG{1,cell}(sweep).nr_spikes(:,nr_repeats+1)';
         mask= ones (1,frame)/frame;
         analysis_LTG{1,cell}(sweep).running_average_nr_spikes=...
         conv(av_doublet_LTG, mask)';
         sLTG=size(analysis_LTG{1,cell}(sweep).running_average_nr_spikes,1);
         %Cut of the acces values created by the moving average at the end
         analysis_LTG{1,cell}(sweep).running_average_nr_spikes=...
         analysis_LTG{1,cell}(sweep).running_average_nr_spikes(1:(sLTG-frame+1));
         %Because the running avregages are devided by the window, the values 
         %without a complete window should be multiplicated by the window*
         %the number values in the window at that point.
         for f=1:frame;
            analysis_LTG{1,cell}(sweep).running_average_nr_spikes(f,1)=...
            analysis_LTG{1,cell}(sweep).running_average_nr_spikes(f,1)/f*frame;
         end
     end
 end
 end
 
 
 end   