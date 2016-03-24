% Method to do spike detection on light application protocol
% Input is a exper file from a current clamp experiment (with laser)
% Output is an anaylysis struct with the analysis per node, also a meta
% struct with some additional information on the 'entire' recording.
% Created by SdK March 6th 2014, tried Git on this file (12/1/15, SdK). 

function [analysis, meta] = spike_analysis_opto(cell_name,sensitivity)

% Create two structs, which will be overwritten at the end of function.
meta      = {};
analysis  = {};

% Load the cell exper and meta struct, to use for the function itself.
sLoad    = load(cell_name);
exper    = sLoad.exper;
meta     = sLoad.meta;

% Set the peak detection sensitivity 
sens     = sensitivity;

% Put some helpful desciptives in the analysis struct (experiment specs).
% Determine the laser intensity from the laser_int_comm (updated).
% Determine the current command from the i_hold (Needs to be improved).
for node = 1:size(exper,2)
    analysis{1,node}.time           = exper(1,node).time;
    analysis{1,node}.laser_comm     = exper(1,node).laser_comm;
    analysis{1,node}.laser_int_max  = ceil(max(exper(1,node).laser_int_comm));
    
    % Need to determine what the current step is, taking the max is not
    % sufficient if there are also negative currents. To take the correct
    % current step, use this approach (half time value - start time value).
    analysis{1,node}.i_comm         = ...
        round((exper(1,node).i_comm(end/2)-exper(1,node).i_comm(1)));
    if exper(1,node).nr_laser_stim == 0
        analysis{1,node}.laser_interval       = 0;
        analysis{1,node}.laser_frequency      = 0;
        continue
    end
    if exper(1,node).nr_laser_stim == 1
        analysis{1,node}.laser_frequency = 1;
        continue
    end
    analysis{1,node}.laser_interval       = ...
        (exper(1,node).l_dac_endtimes(3)-exper(1,node).l_dac_endtimes(1))/10;
    analysis{1,node}.laser_frequency      = ...
        1000/analysis{1,node}.laser_interval;
end

% Run a spike detection on all the sweeps, depending on size exper
% Use peakdet (function) for this, third parameter scales to time (actual)
% This gives a struct with matrices with time and peak (length = number)
for node = 1:size(exper,2)
    % Before setting out on peakdetection determine the stability of the
    % recording by looking at the start Vm of the sweep over time.
    for repeat = 1:meta.nr_repeats
        % Calculate the Vm at start of sweep to onset health
        analysis{1,node}.Vm_start(repeat)        = ...
            mean(exper(1,node).v_rec(1:200,repeat),1);
    end 
    % Calculate the drift per node to find the stability of the recording.
    analysis{1,node}.Vm_drift                    = ...
        analysis{1,node}.Vm_start(1) - analysis{1,node}.Vm_start(end);
    
    % Find the spikes, determine spike intervals and time of peak
    % Use intervals to calculate the instantaneous spike frequency
    for repeat = 1:meta.nr_repeats
        
       % For fluctuating Vm recordings, can use the std for the sensitivity.
       % This becomes less reliable when spikes are smaller.
       % This is specifically adapted for juxtacellular recordings.
        if sens == 'juxta'
            baseline = find(exper(1,node).time == 25);
            sens_max = max(exper(1,node).v_rec(1:baseline,repeat)) - ... 
                mean(exper(1,node).v_rec(1:baseline,repeat));
            std_dev = std(exper(1,node).v_rec(:,repeat));
            sens =(sens_max * 7) + std_dev * 2 ;
        end
        
        analysis{1,node}.spikes{repeat}          = ...
            peakdet(exper(1,node).v_rec(:,repeat),sens,exper(1,node).time);
        % Get total number of spikes in a specific sweep - useful readout
        analysis{1,node}.spike_nr(1,repeat)      = ...
            size(analysis{1,node}.spikes{1,repeat},1); 
        if analysis{1,node}.spike_nr(1,repeat) < 2;
            continue
        end
        % Now calculate the interval using diff(), specifically take first
        % column (time). Get spike intervals and instant frequency.
        analysis{1,node}.spike_intervals{repeat}(:,1) = ...
            diff(analysis{1,node}.spikes{repeat}(:,1)); 
        analysis{1,node}.instant_freq{repeat}(:,1)    = ...
            1000./analysis{1,node}.spike_intervals{1,repeat}(:,1);
        
        % Save the start time (timed at 1st of 2 spikes) for the inst_freq
        for timing = 1:(size(analysis{1,node}.spikes{repeat},1)-1)
            analysis{1,node}.spike_intervals{repeat}(timing,2) = ...
                analysis{1,node}.spikes{repeat}(timing,1);
            analysis{1,node}.instant_freq{repeat}(timing,2)    = ...
                analysis{1,node}.spikes{repeat}(timing,1);
        end
        
        % Save the end time (timed at 2nd of 2 spikes) for the inst_freq
        for timing = 1:(size(analysis{1,node}.spikes{repeat},1)-1)
            analysis{1,node}.spike_intervals{repeat}(timing,3) = ...
                analysis{1,node}.spikes{repeat}(timing+1,1);
            analysis{1,node}.instant_freq{repeat}(timing,3)    = ...
                analysis{1,node}.spikes{repeat}(timing+1,1);
        end
    end
    % Create mean and std values per node.
    analysis{1,node}.spike_average       = mean(analysis{1,node}.spike_nr);
    analysis{1,node}.spike_std           = std(analysis{1,node}.spike_nr);
    % Also calculate the depolarization caused by the current injection
    % Useful for determining depolarization block on action potentials.
    analysis{1,node}.actual_depol        = ....
        depolarization(exper(1,node).v_rec,exper(1,node).time,250,300,10,20);
    % Determine the 'actual spike height' from current injected baseline. 
    for repeat = 1:meta.nr_repeats
        if analysis{1,node}.spike_nr(1,repeat) > 1;
            analysis{1,node}.norm_spike_depol{repeat}(:,1) = ...
                analysis{1,node}.spikes{1,repeat}(:,1);
           analysis{1,node}.norm_spike_depol{repeat}(:,2) = ....
                analysis{1,node}.spikes{1,repeat}(:,2) - ...
            (analysis{1,node}.Vm_start(repeat) + analysis{1,node}.actual_depol(repeat));
            % Flag the depolarization blocks on a very rough basis.
            % Actually need to do this with a proper fit, not for now.
            if min(analysis{1,node}.norm_spike_depol{repeat}) < 20
                analysis{1,node}.dep_block_det(1,repeat) = 1;
            else 
                analysis{1,node}.dep_block_det(1,repeat) = 0;
            end
        end
    end
end

% Assigning the analysis result to a specific set
% This is part of another struct named meta.
for node = 1:meta.nr_sweeps 
    % Make lists of the current intensities and the laser frequencies
    analysis{1,node}.sweep_nr = node;
    meta.nr_laser_stims(node)      = exper(1,node).nr_laser_stim;
    meta.laser_ints(node)          = analysis{1,node}.laser_int_max;
    meta.current_ints(node)        = analysis{1,node}.i_comm;
    meta.laser_freqs(node)         = analysis{1,node}.laser_frequency;
end

end

