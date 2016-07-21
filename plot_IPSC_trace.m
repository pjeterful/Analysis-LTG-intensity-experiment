function gp=plot_IPSC_trace(analysis, which_cells, which_traces)

%plot all repeats of the recorded volage trace with the laser stimulations
%and highlight peaks detected within the given spike_window by peakdet.m 
%per sweep. If all peaks are to be highlighted use:
% x_spike=analysis{1,sweep}.spikes{1,repeat}(:,1);
% y_spike=analysis{1,sweep}.spikes{1,repeat}(:,2); 
%instead of current x_spike and y_spike

for cell=[which_cells];
    figure(cell);
    nr_sw=size(which_traces,2);
    c=0;
    for sweep=[which_traces];
    c=c+1;       
    subplot(nr_sw,1,c);
    t=analysis{1, cell}(sweep).laser_peaks(:,1);
    t=t';
    if isfield(analysis{1, cell}(sweep), 'spike_peaks')==1
    if isempty(analysis{1, cell}(sweep).spike_peaks{1, repeat})
        x_spike=0;
        y_spike=0;
    else
   % x_spike=analysis{1,cell}(sweep).spike_peaks{1,repeat}(:,1);
   % y_spike=analysis{1,cell}(sweep).spike_peaks{1,repeat}(:,2);
    end
    else
        x_spike=0;
        y_spike=0;
    end
    nr_repeats=size(analysis{1, cell}(sweep).spike_trace,2);  
    for repeat=1:nr_repeats;
    hold on
    plot(analysis{1,cell}(sweep).time, analysis{1,cell}(sweep).spike_trace(:,repeat),'k',x_spike, y_spike, 'ro')
     plot([t;t],[(ones(size(t))*1000-1000);(zeros(size(t))*1000-1000)],'b-');
    if isfield(analysis{1, cell},'elec_intensity')==1   
    a=num2str(analysis{1, cell}(1).elec_intensity(sweep));
    end
    
    if isfield(analysis{1, cell},'laser_intensity')==1   
    a=num2str(analysis{1, cell}(1).laser_intensity(sweep));
    end
    
    title(['stimulus intensity: ' a]);
    end
end
hold off
end
