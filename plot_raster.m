%make a raster plot with detected spikes within the given spike_window of 
%all repeats of different frequencies in one plot
for sweep=1:size(analysis_2,2);
   for repeat=1:size(analysis_2(1).det_peaks,2);
    t=analysis_2(sweep).det_peaks{1,repeat}(:,2);
    t=t';
    subplot((size(analysis_2,2)),1,sweep);
    hold on
    plot([t;t],[(ones(size(t))+3-repeat);(zeros(size(t))+3-repeat)],'k-');
    axis([0, 1000,-1, 3]);
    %ylabel([analysis{1, sweep}.laser_frequency]);
end
    %axis([0, 1000,-1, 3]);
    %xlabel('time (ms)');

hold off
end