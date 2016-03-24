function [dist_AB, dist_BA] = spike_triggered_average(spike_t_A, spike_t_B, ways)
% Function to determine Spike Triggered Average of two cells.
% Input is two cells with arrays filled with spike times (in ms).
% Also a parameter to determine 1 or 2 way detection.
% Output is a spike triggered average in two directions.
% First created 8th of December 2015

% Find only works with integers, so we round both vectors.
% Possibly make a decision on to round up/down?
spike_t_A = round(spike_t_A);
spike_t_B = round(spike_t_B);

% Use an index counter for the intervals.
index_AB     = 0;
index_BA     = 0;

prec_AB = [];

% First do it for vector A -> B
% For every spike in the vector. 
for spike = 1:size(spike_t_A,1)
    
    % Determine the indices of the preceding and following spike.
    % Which spike in B precedes/follows the A spike?
    i_lower  = find(spike_t_B <= spike_t_A(spike),1,'last');
    i_higher = find(spike_t_B >= spike_t_A(spike),1,'first');
    
    if isempty(i_lower)
        i_lower = 0;
    end
    
    if isempty(i_higher)
        i_higher = 0;
    end
    
    % Determine the time of the preceding/following spike.
    % Can only do this if you found a spike.
    if i_lower > 0 && i_higher > 0;
        lower_than_b  = spike_t_B(i_lower);
        higher_than_b = spike_t_B(i_higher);
        
        index_AB = index_AB + 1;
        % Determine the time from spike in A
        prec_AB(index_AB) = lower_than_b - spike_t_A(spike);
        foll_AB(index_AB) = higher_than_b - spike_t_A(spike);
    end 
end

% Likewise but then for vector B -> A
for spike = 1:size(spike_t_B,1)
    
    % Determine the indices of the preceding and following spike.
    % Which spike in B precedes/follows the A spike?
    i_lower  = find(spike_t_A <= spike_t_B(spike),1,'last');
    i_higher = find(spike_t_A >= spike_t_B(spike),1,'first');
    
    if isempty(i_lower)
        i_lower = 0;
    end
    
    if isempty(i_higher)
        i_higher = 0;
    end
    
    % Determine the time of the preceding/following spike.
    % Can only do this if you found a spike.
    if i_lower > 0 && i_higher > 0;
        lower_than_a  = spike_t_A(i_lower);
        higher_than_a = spike_t_A(i_higher);
        
        index_BA = index_BA + 1;
        % Determine the time from spike in A
        prec_BA(index_BA) = lower_than_a- spike_t_B(spike);
        foll_BA(index_BA) = higher_than_a - spike_t_B(spike);
    end 
end

% Concatenate the results of preceding and following.
dist_AB = [prec_AB foll_AB];
dist_BA = [prec_BA foll_BA];

end
