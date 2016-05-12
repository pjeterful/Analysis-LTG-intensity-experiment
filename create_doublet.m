%This function creates a new variable nr_spikes in each cell for each
%sweep, this variable containes the number of spikes following a laser
%stimulus puls within a giving window. This will be given for each repeat
%and in the last column the average. Input is an analysis_ctrl and LTG
%file, and a timewindow (ms) after the laser within which the spikes should be counted.

function [analysis_ctrl, analysis_LTG]=create_doublet(analysis_ctrl, analysis_LTG, window)

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
        % Calculate the mean amount of spikes of all repeats per sweep and
        % cell. Place this value in the last column.
        analysis_ctrl{1,cell}(sweep).nr_spikes(:,4)=mean(analysis_ctrl{1,cell}(sweep).nr_spikes,2);  
    end
end

%Dow the same for the LTG file.
for cell=1:size(analysis_LTG,2);
    for sweep=1:size(analysis_LTG{1,cell},2);  
        lasertimes_LTG=analysis_LTG{1,cell}(sweep).laser_peaks;
        for repeat=1:size(analysis_LTG{1, cell}(sweep).spike_peaks,2);
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
        analysis_LTG{1,cell}(sweep).nr_spikes(:,4)=mean(analysis_LTG{1,cell}(sweep).nr_spikes,2);
    end
end
end          