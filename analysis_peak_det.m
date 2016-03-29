%Git test
function [data]=analysis_peak_det (exper,delta_in_peakdet)
% analysis structures data from exper files, gives a struct containing the times of laser stimulations and detected peaks by peakdet.  
% delta_in_peakdet=delta in peakdetection usualy in action potentials 0.3
% call output variable data_nr for example data_1, data_2 etc. this so function peaks can acces this data 

for nr_sweep=1:size(exper,2); %number of sweeps with different laser protocols
 
    for nr_repeat = 1: size(exper(nr_sweep).v_rec,2); % repeats of a single experiment
        data(nr_sweep).spike_peaks{nr_repeat} = peakdet(exper(nr_sweep).v_rec(:,nr_repeat),delta_in_peakdet,exper(nr_sweep).time); %peak detection of trace
        
        for nr_laser = 1:2:exper(nr_sweep).nr_laser_stim*2; 
            data(nr_sweep).laser_peaks(ceil(nr_laser/2),1) = exper(nr_sweep).l_dac_endtimes(nr_laser,1)/10; %laser stimuli
        end

    end
end
