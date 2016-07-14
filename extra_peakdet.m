function [temp]=extra_peakdet(analysis,which_cells,delta)
%This function can be used to perform an extra peak detection when the
%standard peak detection used in spike analysis is not working optimally,
%in this peak detection the delta can be adjusted manually. Inputs are a
%analysis struct, on which cells the peakdetection should be performed and
%the delta used for the peakdetection.
for cell=[which_cells];
    for sweep=1:size(analysis{1, cell} ,2);
        for repeat=1:size(analysis{1, cell}(sweep).spike_trace,2);
            v=analysis{1, cell}(sweep).spike_trace(:,repeat) ;
            x=analysis{1, cell}(sweep).time;
            temp{1,cell}(sweep).spike_peaks{repeat}=...
            peakdet(v,delta,x);
        end
        temp{1,cell}(sweep).spike_trace=analysis{1, cell}(sweep).spike_trace;
        temp{1,cell}(sweep).time=analysis{1, cell}(sweep).time;  
        temp{1,cell}(sweep).laser_peaks=analysis{1, cell}(sweep).laser_peaks;
    end
    temp{1,cell}(1).laser_intensity=analysis{1, cell}(1).laser_intensity;
end
end