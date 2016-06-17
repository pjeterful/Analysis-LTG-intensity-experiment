function gp=plot_general(analysis, which_cells, which_traces, which_repeat)

%plot all repeats of the recorded volage trace with the laser stimulations
%and highlight peaks detected within the given spike_window by peakdet.m 
%per sweep. If all peaks are to be highlighted use:
% x_spike=analysis{1,sweep}.spikes{1,repeat}(:,1);
% y_spike=analysis{1,sweep}.spikes{1,repeat}(:,2); 
%instead of current x_spike and y_spike

repeat=which_repeat;

for cell=[which_cells];
    figure(cell);
    nr_sw=size(which_traces,2);
    c=0;
    for sweep=[which_traces];
    c=c+1;       
    subplot(nr_sw,1,c);
    %t=analysis{1, cell}(sweep).laser_peaks(:,1);
    %t=t';
    
   % x_spike=analysis{1,cell}(sweep).det_peaks{1,repeat}(:,2);
  %  y_spike=analysis{1,cell}(sweep).det_peaks{1,repeat}(:,3);
    hold on
    plot(analysis{1,cell}(sweep).time, analysis{1,cell}(sweep).spike_trace(:,repeat),'k')
     %plot([t;t],[(ones(size(t))*2-0.5);(zeros(size(t))*2-0.5)],'b-');
    a=num2str(analysis{1, cell}(1).laser_intensity(sweep));
    title(['stimulus intensity: ' a]);
    end
end
hold off
end
