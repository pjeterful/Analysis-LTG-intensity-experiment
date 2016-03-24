sweep=1;
    repeat=1;
    sw=9;
    
for stim=1:size(analysis_2(sweep).laser_peaks,1);
     min_spike_window=analysis_2(sweep).laser_peaks(stim,1);
     max_spike_window=analysis_2(sweep).laser_peaks(stim,1)+sw;
     spike=analysis{1,sweep}.spikes{1,repeat};
     min_spike_window=round(min_spike_window);
     max_spike_window=round(max_spike_window);
     spike=round(spike);
     det_spike=find(spike > min_spike_window,1,'first')
end
