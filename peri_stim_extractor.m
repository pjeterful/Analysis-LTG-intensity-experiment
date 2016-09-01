function [peri_stim_traces] = peri_stim_extractor(signal, time_trace, stimulus_inds, window_rev, window_forw)
% Function to plot any trace, time bound to a stimulus.
% Input is the trace of interest, the time trace corresponding to it,
% the indices (!) of the stimulus and the  before and after window (ms).

stims      = stimulus_inds;
vector     = signal;

% Determine the good and actual sampling rate for the traces.
% Use this to determine the index for the cell.
sample_rate    = size(time_trace,1)/time_trace(end); % In samples/ms.
times          = time_trace;
before_i       = window_rev  * sample_rate; % before_t in samples/ms.
after_i        = window_forw * sample_rate; % after_t in samples/ms.
v_stim         = 0; % Set the counter for the PSs.

for repeat = 1:size(vector,2)

    for stim = 1:size(stims,1)
    
        % Determine the proper indices based on the sample rate.
        time_ind  = stims(stim);
        pre_wind  = time_ind-before_i;
        post_wind = time_ind+after_i;
        
        if pre_wind > 0 && post_wind < size(vector,1) == 1
            v_stim = v_stim + 1; % Use the valid stims as counter.
            % Extract the trace, corresponding times and normalised times.
            peri_stim_traces(v_stim,:,1,repeat)  = vector(pre_wind:post_wind,repeat)';
            peri_stim_traces(v_stim,:,2,repeat)  = times(pre_wind:post_wind)';
            peri_stim_traces(v_stim,:,3,repeat)  = times(pre_wind:post_wind)-times(time_ind)';
            plot(peri_stim_traces(stim,:,3),peri_stim_traces(stim,:,1));
        end
    end

end

end
