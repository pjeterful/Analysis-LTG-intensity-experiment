function [analysis_ctrl]=create_doublet(analysis_ctrl, window)

for cell=1:size(analysis_ctrl,2);
    for sweep=1:size(analysis_ctrl{1,cell},2);  
        lasertimes_ctrl=analysis_ctrl{1,cell}(sweep).laser_peaks;
        for repeat=1:size(analysis_ctrl{1, cell}(sweep).spike_peaks,2);
            spikes_ctrl{1,repeat}=analysis_ctrl{1,cell}(sweep).spike_peaks{1,repeat}; 
 %           for spik=1:size(spikes_ctrl{1,repeat},1);
 %              spike_heights_ctrl{1,repeat}(1,spik)=analysis_ctrl{1, cell}(sweep).spike_trace(spik,repeat) ;
 %           end               
            for stim=1:size(lasertimes_ctrl,1);
                SAL_ctrl=find(spikes_ctrl{1,repeat} > lasertimes_ctrl(stim)...
                     & spikes_ctrl{1,repeat} < (lasertimes_ctrl(stim) + window));      
                if  isempty (SAL_ctrl);
                     analysis_ctrl{1,cell}(sweep).nr_spikes(stim,repeat)=0;
                else
                     analysis_ctrl{1,cell}(sweep).nr_spikes(stim,repeat)=size(SAL_ctrl,1);
                end
            end
        end
    end
end
            