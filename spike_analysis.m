function [analysis, meta] = spike_analysis(cell_name,sensitivity)
% Method to do spike detection on light application protocol
% Input is a exper file from a current clamp experiment (with laser)
% Output is an anaylysis struct with the analysis per node, also a meta
% struct with some additional information on the 'entire' recording.
% Created by SdK March 6th 2014, tried Git on this file (12/1/15, SdK).
% Changed to spike_analysis 4/4/16 to be more universally useful.
% Create two structs, which will be overwritten at the end of function.

meta      = {};
analysis  = {};

% Load the cell exper and meta struct, to use for the function itself.
sLoad    = load(cell_name);
exper    = sLoad.exper;
meta     = sLoad.meta;

% Set the peak detection sensitivity 
sens        = sensitivity;
sample_rate = size(exper(1).time,1)/exper(1).time(end);

%% Determine the commands (i_comm & laser_comm) from the original file.
% Determine the laser intensity from the laser_int_comm (updated).
% Determine the current command from the i_hold (Needs to be improved).

for node = 1:size(exper,2)
    analysis{1,node}.time           = exper(1,node).time;
    
    if isfield(exper,'laser_comm') == 1;
        analysis{1,node}.laser_comm     = exper(1,node).laser_comm;
        analysis{1,node}.laser_int_max  = ceil(max(exper(1,node).laser_int_comm));
    
        if exper(1,node).nr_laser_stim == 0
            analysis{1,node}.laser_interval       = 0;
            analysis{1,node}.laser_frequency      = 0;
        end
        
        if exper(1,node).nr_laser_stim == 1
            analysis{1,node}.laser_frequency = 1;
            analysis{1,node}.laser_times = exper(1,node).l_dac_endtimes(1:2:end-1);
            analysis{1,node}.laser_interval  = 0;
        end
        
        if exper(1,node).nr_laser_stim > 1
            analysis{1,node}.laser_interval       = ...
                (exper(1,node).l_dac_endtimes(3)-exper(1,node).l_dac_endtimes(1))/10;
            analysis{1,node}.laser_frequency      = ...
                1000/analysis{1,node}.laser_interval;
            analysis{1,node}.laser_times = exper(1,node).l_dac_endtimes(1:2:end-1);
        end
    end
end
    
% Need to determine what the current step is, taking the max is not
% sufficient if there are also negative currents. To take the correct
% current step, use this approach (half time value - start time value).
% Also calculate the depolarization caused by the current injection
% Useful for determining depolarization block on action potentials.
% Also, at different modalities (dual clamp) there can be different
% i_comms.
for modality = 1:size(exper,1);
    for node = 1:size(exper,2)
        
        % Extract the command current if there was one.
        if isfield(exper,'i_comm') == 1;
            
            % Determine the command current, taking into account that not
            % all the i_comms are actual inputs (also 0 pA possible).
            % The command current is here the delta I, compared to the
            % start.
            if (size(exper(modality,node).i_dac_endtimesII,1) > 2) == 1
                start_ind = exper(modality,node).i_dac_endtimes(1)+1;

                analysis{modality,node}.i_comm         = ...
                    round((exper(modality,node).i_comm(start_ind)-exper(modality,node).i_comm(1)));
            else
                start_ind = exper(modality,node).i_dac_endtimes(1)/2;
                analysis{modality,node}.i_comm         = ...
                    round(exper(modality,node).i_comm(end/2)) - round(exper(modality,node).i_comm(1));
            end 
            
            for repeat = 1:size(exper(modality,node).v_rec,2)
                
                % Determine the start depolarization, the end
                % depolarization, their difference and the absolute per
                % repeat of the experiment.
                analysis{modality,node}.Vm_start(1,repeat)       = ...
                mean(exper(modality,node).v_rec(1:100,repeat),1);

                analysis{modality,node}.Vm_end(1,repeat)         = ...
                mean(exper(modality,node).v_rec(end-100:end,repeat),1);

                analysis{modality,node}.Vm_drift(1,repeat)       = ...
                    analysis{modality,node}.Vm_start(repeat) - analysis{modality,node}.Vm_end(repeat);

                analysis{modality,node}.Vm_depol_act(1,repeat)   = ...
                    mean(exper(modality,node).v_rec(start_ind:start_ind + 1000),2);
                
                analysis{modality,node}.Vm_depol_norm(1,repeat)       = ...
                    mean(exper(modality,node).v_rec(start_ind:start_ind + 1000),2) - ...
                    analysis{modality,node}.Vm_start(repeat);
            end
        end    
    end
end

%% Run a spike detection on all the sweeps, depending on size exper
% Use peakdet (function) for this, third parameter scales to time (actual)
% This gives a struct with matrices with time and peak (length = number)
for modality = 1:size(exper,1) % Single/dual patch control.
    for node = 1:size(exper,2)
    
        % Find the spikes, determine spike intervals and time of peak
        % Use intervals to calculate the instantaneous spike frequency
        for repeat = 1:meta.nr_repeats

           % For fluctuating Vm recordings, can use the std for the sensitivity.
           % This becomes less reliable when spikes are smaller.
           % This is specifically adapted for juxtacellular recordings.
            if sens == 'juxta'
                baseline = find(exper(modality,node).time == 25);
                sens_max = max(exper(modality,node).v_rec(modality:baseline,repeat)) - ... 
                    mean(exper(modality,node).v_rec(modality:baseline,repeat));
                std_dev = std(exper(modality,node).v_rec(:,repeat));
                sens = (sens_max * 1) + std_dev * 2;% + (sens_max * 1) 
            end

            % Do the actual peakdetection here using peakdet. 
            analysis{modality,node}.spikes{repeat}          = ...
                peakdet(exper(modality,node).v_rec(:,repeat),sens,exper(1,node).time);
            % Get total number of spikes in a specific sweep - useful readout
            analysis{modality,node}.spike_nr(1,repeat)      = ...
                size(analysis{modality,node}.spikes{1,repeat},1); 
            if analysis{modality,node}.spike_nr(1,repeat) < 2;
                continue
            end
            
            % Now calculate the interval using diff(), specifically take first
            % column (time). Get spike intervals and instant frequency.
            analysis{modality,node}.spike_intervals{repeat}(:,1) = ...
                diff(analysis{modality,node}.spikes{repeat}(:,1)); 
            analysis{modality,node}.instant_freq{repeat}(:,1)    = ...
                1000./analysis{modality,node}.spike_intervals{1,repeat}(:,1);

            % Save the start time (timed at 1st of 2 spikes) for the inst_freq
            for timing = 1:(size(analysis{modality,node}.spikes{repeat},1)-1)
                analysis{modality,node}.spike_intervals{repeat}(timing,2) = ...
                    analysis{modality,node}.spikes{repeat}(timing,1);
                analysis{modality,node}.instant_freq{repeat}(timing,2)    = ...
                    analysis{modality,node}.spikes{repeat}(timing,1);
            end

            % Save the end time (timed at 2nd of 2 spikes) for the inst_freq
            for timing = 1:(size(analysis{modality,node}.spikes{repeat},1)-1)
                analysis{modality,node}.spike_intervals{repeat}(timing,3) = ...
                    analysis{modality,node}.spikes{repeat}(timing+1,1);
                analysis{modality,node}.instant_freq{repeat}(timing,3)    = ...
                    analysis{modality,node}.spikes{repeat}(timing+1,1);
            end
        end
        % Create mean and std values per node.
        analysis{modality,node}.spike_average       = mean(analysis{modality,node}.spike_nr);
        analysis{modality,node}.spike_std           = std(analysis{modality,node}.spike_nr);

        % Determine the 'actual spike height' from current injected baseline. 
        for repeat = 1:meta.nr_repeats
            if analysis{modality,node}.spike_nr(1,repeat) > 1;
                analysis{modality,node}.norm_spike_depol{repeat}(:,1) = ...
                    analysis{modality,node}.spikes{1,repeat}(:,1);
                analysis{modality,node}.norm_spike_depol{repeat}(:,2) = ....
                    analysis{modality,node}.spikes{1,repeat}(:,2) - ...
                (analysis{modality,node}.Vm_start(repeat) + analysis{modality,node}.Vm_depol_norm(repeat));
                % Flag the depolarization blocks on a very rough basis.
                % Actually need to do this with a proper fit, not for now.
                if min(analysis{modality,node}.norm_spike_depol{repeat}) < 20
                    analysis{modality,node}.dep_block_det(1,repeat) = 1;
                else 
                    analysis{modality,node}.dep_block_det(1,repeat) = 0;
                end
            end
    end
end

% Assigning the analysis result to a specific set
% This is part of another struct named meta.
for node = 1:meta.nr_sweeps 
    % Make lists of the current intensities and the laser frequencies
    analysis{modality,node}.sweep_nr = node;
    if isfield(exper,'laser_comm') == 1;
        meta.nr_laser_stims(modality,node)      = exper(modality,node).nr_laser_stim;
        meta.laser_ints(modality,node)          = analysis{modality,node}.laser_int_max;
        meta.laser_freqs(modality,node)         = analysis{modality,node}.laser_frequency;
    end
    
    if isfield(exper,'i_comm') == 1;
        meta.current_ints(node)        = analysis{1,node}.i_comm;
    end
end

end