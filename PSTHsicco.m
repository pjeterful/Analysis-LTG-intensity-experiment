function [freq_set, time_set, success_set] = PSTHsicco(detected_units_t, stimulus_t, window)
% Function to create data for a peri stimulus time histogram.
% Input is two structs with detected units and stimuli (lenghts vary)
% Additional input is a selection window.
% Output is a PTSH per sweep (e.g. laser frequency) and a success plot)
% Output includes absolute times and relative times. 

output_struct      = detected_units_t;
command_struct     = stimulus_t;
reliability_window =  window;

sweeps             = size(output_struct.spike_nr,1);
repeats            = size(output_struct.spike_nr,2);

% For now hardcode the structs
for sweep = 1:sweeps
    % Initialize/clear the rel/abs time sets.
    freq_rep_set = [];
    abst_rep_set = [];
    
    % Determine nr of stims here for the success plot.
    stims        = size(command_struct{1,sweep},2);
    for repeat = 1:repeats
        
        if ~isempty(output_struct.inst_freq{sweep,repeat})
            unit_set        = output_struct.inst_freq{sweep,repeat}(:,2);
            unit_set(end+1) = output_struct.inst_freq{sweep,repeat}(end,3);
        
            % Determine a spike triggered average, one way (comm -> units)
            index_unit      = 0;
            LU_interval     = [];
            for stim = 1:size(command_struct{1,sweep},2)
            
                % DAC commands are in 0.1 ms, need to bring to ms.
                % Then find the first unit after the stimulus.
                % Indicate 2 in the second paramter to find the next 2.
                stimulus = command_struct{1,sweep}(stim)/10;
                i_higher = find(unit_set >= stimulus,1,'first');
            
                % Replace index with a 0 if there is no later unit.
                if isempty(i_higher)
                    i_higher = 0;
                end
                
                % Only look for a value when there is a value to look for.
                if i_higher >= 1
                    following_s            = unit_set(i_higher);
                    
                    % Create vector with the interval times, using index.
                    index_unit              = index_unit + 1;
                    LU_abs_time(index_unit) = following_s;
                    LU_interval(index_unit) = following_s - stimulus;
                end
            end
        else
            LU_abs_time = NaN;
            LU_interval = NaN;
        end
        % Save the interval times and the absolute times;
        abst_rep_set = [abst_rep_set LU_abs_time];
        freq_rep_set = [freq_rep_set LU_interval];
    end
    freq_set{1,sweep} = freq_rep_set;
    time_set{1,sweep} = abst_rep_set;
    
    % Select the data for the window.
    window_selec         = find(freq_set{1,sweep} < window);
    freq_set{1,sweep}    = freq_set{1,sweep}(window_selec);
    time_set{1,sweep}    = time_set{1,sweep}(window_selec);
    success_set(1,sweep) = size(freq_set{1,sweep},2)/(stims*repeats);
            
end

end
