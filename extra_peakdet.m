function [temp]=extra_peakdet(analysis,which_cells,delta)
for cell=[which_cells];
    for sweep=1:size(analysis{1, cell} ,2);
        for repeat=1:size(analysis{1, cell}(sweep).spike_trace,2);
            v=analysis{1, cell}(sweep).spike_trace(:,repeat) ;
            x=analysis{1, cell}(sweep).time;
            temp{1,cell}(sweep).det_peaks{repeat}=...
            peakdet(v,delta,x);
        end
        temp{1,cell}(sweep).spike_trace=analysis{1, cell}(sweep).spike_trace;
        temp{1,cell}(sweep).time=analysis{1, cell}(sweep).time;  
        temp{1,cell}(sweep).laser_peaks=analysis{1, cell}(sweep).laser_peaks;
    end
    temp{1,cell}(1).laser_intensity=analysis{1, cell}(1).laser_intensity;
end
end