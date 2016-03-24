function [intensity]=calculate_intensity(start_intensity, nr_steps, step_size)

for stim=1:nr_steps;
    int(stim,1)=start_intensity*(step_size^stim);
end
intensity=round(int)
end