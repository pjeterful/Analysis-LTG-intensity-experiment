function [analysis_ctrl, analysis_LTG]=create_succes_rate(analysis_ctrl, analysis_LTG, window)
for cell=1:size(analysis_ctrl,2);
     for sweep=1:size(analysis_ctrl{1,cell},2);  
         %Save the lasertimes for each laser stimulus lper sweep.
         lasertimes_ctrl=analysis_ctrl{1,cell}(sweep).laser_peaks;
         for repeat=1:size(analysis_ctrl{1, cell}(sweep).spike_peaks,2);
             %Save the times of the spikes for each reapeat.
             spikes_ctrl{1,repeat}=analysis_ctrl{1,cell}(sweep).spike_peaks{1,repeat};               
             for stim=1:size(lasertimes_ctrl,1);
                 %Find the spikes following a laser puls, within 
                 %the giving window for each repeat and sweep.
                 SAL_ctrl=find(spikes_ctrl{1,repeat} > lasertimes_ctrl(stim)...
                      & spikes_ctrl{1,repeat} < (lasertimes_ctrl(stim) + window),1);
                  %If none are found set the amount of found spikes to zero,
                  %otherwhise count the amount of found spikes per laser
                  %stiumulus for each repeat and sweep.
                 if  isempty (SAL_ctrl);
                      temp_ctrl{1,cell}(sweep).det_peaks(stim,repeat)=0;
                 else
                      temp_ctrl{1,cell}(1,sweep).det_peaks(stim,repeat)=1;
                 end
             end
         end
         analysis_ctrl{cell}(sweep).succes_rate=mean(temp_ctrl{1,cell}(sweep).det_peaks,2);
         analysis_ctrl{cell}(1).mean_succes_rate(sweep,1)=mean(analysis_ctrl{cell}(sweep).succes_rate,1);
     end
     
          for sweep=1:size(analysis_LTG{1,cell},2);  
         %Save the lasertimes for each laser stimulus lper sweep.
         lasertimes_LTG=analysis_LTG{1,cell}(sweep).laser_peaks;
         for repeat=1:size(analysis_LTG{1, cell}(sweep).spike_peaks,2);
             %Save the times of the spikes for each reapeat.
             spikes_LTG{1,repeat}=analysis_LTG{1,cell}(sweep).spike_peaks{1,repeat};               
             for stim=1:size(lasertimes_LTG,1);
                 %Find the spikes following a laser puls, within 
                 %the giving window for each repeat and sweep.
                 SAL_ctrl=find(spikes_LTG{1,repeat} > lasertimes_LTG(stim)...
                      & spikes_LTG{1,repeat} < (lasertimes_LTG(stim) + window),1);
                  %If none are found set the amount of found spikes to zero,
                  %otherwhise count the amount of found spikes per laser
                  %stiumulus for each repeat and sweep.
                 if  isempty (SAL_ctrl);
                      temp_LTG{1,cell}(sweep).det_peaks(stim,repeat)=0;
                 else
                      temp_LTG{1,cell}(sweep).det_peaks(stim,repeat)=1;
                 end
             end
         end
         analysis_LTG{cell}(sweep).succes_rate=mean(temp_LTG{1,cell}(sweep).det_peaks,2);
         analysis_LTG{cell}(1).mean_succes_rate(sweep,1)=mean(analysis_LTG{cell}(sweep).succes_rate,1);
          end
end
end
     