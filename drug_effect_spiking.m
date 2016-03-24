% Function to assess the effect of a drug on spiking in cell type.
% Input is two folders (ctrl/drug), run side by side (paired).
% Output is result set (struct) for both and ratio over cells.
% Function created 27/7/2015 by SdK
% Potentially useful to add a test for the cell.

% Function assumes two folders with equal length.
% Each file number corresponds to same cells (ctrl and drug).
function [result_ctrl, result_drug, result_matrix] = drug_effect_spiking(ctrl_folder, drug_folder, sensitivity)

close all

% State the input folders and parameters.
ctrl_files  = dir(ctrl_folder);
drug_files  = dir(drug_folder);
sens        = sensitivity;
folder_size = size(ctrl_files,1) - 2; % Only for Windows

% Check if the folders are the same size.
if size(ctrl_files,2) ~= size(drug_files,2)
    error('Folder size is not equal')
end
    
% Create the structs for the analysis results
result_ctrl = {};
result_drug = {};

% Create a result matrix for the total.
result_matrix = nan(size(ctrl_files,2)-2, 5);

% Set the counter for the cell.
recording = 0;

figure; hold on;
for fil = 3:size(ctrl_files)
    
    % Click the counter and assign subplot location.
    recording      = recording + 1;
    cell_id_ctrl   = strcat(ctrl_folder,filesep,ctrl_files(fil,1).name);
    cell_id_drug   = strcat(drug_folder,filesep,drug_files(fil,1).name);
    subplot(ceil(sqrt(folder_size)),ceil(sqrt(folder_size)),recording);
   
    % Run a spike analysis on the control set and the drug set.
    % Plot the highest laser intensity recordings and check detection.
    load(cell_id_ctrl);
    [analysis_ctrl, meta_ctrl] = spike_analysis_opto(cell_id_ctrl,sens); 
    if ~isempty(analysis_ctrl{1,end}.spikes{1,end})
        plot(exper(1,end).time,exper(1,end).v_rec(:,end),'k'); hold on;
        plot(analysis_ctrl{1,end}.spikes{1,end}(:,1),analysis_ctrl{1,end}.spikes{1,end}(:,2),'ok');
    end
    
    % For the drug set (second folder). 
    [analysis_drug, meta_drug] = spike_analysis_opto(cell_id_drug,sens);
    load(cell_id_drug);
    if ~isempty(analysis_drug{1,end}.spikes{1,end})
        plot(exper(1,end).time,exper(1,end).v_rec(:,end),'r'); hold on;
        plot(analysis_drug{1,end}.spikes{1,end}(:,1),analysis_drug{1,end}.spikes{1,end}(:,2),'or');
    end
    
    % Save the cell names in the corresponding result files.
    % Add the cell id to the plots.
    result_ctrl(recording).recording_id = meta_ctrl.cellname;
    result_drug(recording).recording_id = meta_drug.cellname;
    title(result_ctrl(recording).recording_id);
    
    % Determine the unique laser intensitiy values (in order of appeareance)
    % Is used for later sorting of the results for making it an output matrix.
    result_ctrl(recording).laser_ints_uniq(:,:)    = myunique(meta_ctrl.laser_ints);
    result_drug(recording).laser_ints_uniq(:,:)    = myunique(meta_drug.laser_ints);

    % Determine whether the number of intensities is equal, set set size.
    if all(result_ctrl(recording).laser_ints_uniq(:,:) == result_drug(recording).laser_ints_uniq(:,:))
            set_size = size(meta_ctrl.laser_ints,2);
    else continue % error('Laser Intensities are not equal') 

    end
    
    % Pre allocate the matrices for speed and record the spike_nrs.
    result_ctrl(recording).spike_nr   = nan(set_size,meta_ctrl.nr_repeats);
    result_drug(recording).spike_nr   = nan(set_size,meta_drug.nr_repeats);
    for node = 1:set_size
        result_ctrl(recording).spike_nr(node,:)  = analysis_ctrl{1,node}.spike_nr;
        result_drug(recording).spike_nr(node,:)  = analysis_drug{1,node}.spike_nr;
        for repeat = 1:meta_ctrl.nr_repeats
            if analysis_ctrl{1,node}.spike_nr(repeat) > 1;
                result_ctrl(recording).inst_freq{node,repeat} = ...
                    analysis_ctrl{1,node}.instant_freq{1,repeat};
                result_ctrl(1,recording).first_freq(node,repeat) = ...
                    result_ctrl(1,recording).inst_freq{node,repeat}(1,repeat);
            end
            if analysis_drug{1,node}.spike_nr(repeat) > 1;
                result_drug(recording).inst_freq{node,repeat} = ...
                    analysis_drug{1,node}.instant_freq{repeat};
                result_drug(1,recording).first_freq(node,repeat) = ...
                    result_drug(1,recording).inst_freq{node,repeat}(1,repeat);
            end
        end
    end
end

%% Plotting and overview part of the function.

% Improve this to use a ratio as well. 
figure(2); hold on;
for cell_nr = 1:recording
    subplot(ceil(sqrt(folder_size)),ceil(sqrt(folder_size)),cell_nr); hold on;
    % Calculate the spike ratio drug/ctrl and save to result_matrix.
    ratio = mean(result_drug(1,cell_nr).spike_nr./ ...
    result_ctrl(1,cell_nr).spike_nr,2);
    result_matrix(cell_nr,5) = ratio(end); 
    x_values = result_ctrl(cell_nr).laser_ints_uniq;
   
    % Fit the data to a Weibull distribution for the CTRL condition.
    [dblThreshold_C, vec_C_FitX, vec_C_FitY, cFit_C, xThreshold_C] = ...
        weibull_fit(x_values,mean(result_ctrl(1,cell_nr).spike_nr(:,:),2)');
    result_ctrl(cell_nr).X_fifty = xThreshold_C;
    result_ctrl(cell_nr).Y_fifty = dblThreshold_C;
    result_ctrl(cell_nr).cFit    = cFit_C;
    % Same for the DRUG condition.
    [dblThreshold_D, vec_D_FitX, vec_D_FitY, cFit_D, xThreshold_D] = ...
        weibull_fit(x_values,mean(result_drug(1,cell_nr).spike_nr(:,:),2)');
    result_drug(cell_nr).X_fifty = xThreshold_D;
    result_drug(cell_nr).Y_fifty = dblThreshold_D;
    result_drug(cell_nr).cFit    = cFit_D;
   
    % For the result matrix
    result_matrix(cell_nr,1)    = xThreshold_C;
    result_matrix(cell_nr,2)    = dblThreshold_C;
    result_matrix(cell_nr,3)    = xThreshold_D;
    result_matrix(cell_nr,4)    = dblThreshold_D;
    
    % Plot the two fits in the same window. 
    plot(x_values,result_drug(cell_nr).spike_nr,'ro'); 
    plot(cFit_D,'r'); plot(cFit_C,'k')
     % Use plotyy to get a second axis in for the ratio.
    [hAx,hLine1,hLine2] = plotyy(x_values,result_ctrl(cell_nr).spike_nr,x_values,ratio);
    set(hLine1,'Linestyle','none','Marker','o','Color','k')
    set(hAx(2),'YLim',[0 1])
    ylabel('Ratio Drug/Ctrl')
    legend('hide');
    title(result_ctrl(cell_nr).recording_id); hold on;
end

% Plot the instantaneous frequency.
figure(3); hold on;
for cell_nr = 1:recording
    subplot(ceil(sqrt(folder_size)),ceil(sqrt(folder_size)),cell_nr); hold on;
    for repeat = 1:meta_ctrl.nr_repeats
        if result_ctrl(1,cell_nr).spike_nr(end,repeat) > 1;
        plot(result_ctrl(1,cell_nr).inst_freq{end,repeat}(:,2),...
             result_ctrl(1,cell_nr).inst_freq{end,repeat}(:,1),'k')
        end
        % And the drug condition
        if result_drug(1,cell_nr).spike_nr(end,repeat) > 1;
        plot(result_drug(1,cell_nr).inst_freq{end,repeat}(:,2),...
             result_drug(1,cell_nr).inst_freq{end,repeat}(:,1),'r')
        end
    end
    axis([0 1000 0 inf])
    title(result_ctrl(cell_nr).recording_id); hold on;
end

figure(4); hold on;
for cell_nr = 1:recording
    subplot(ceil(sqrt(folder_size)),ceil(sqrt(folder_size)),cell_nr); hold on;
    for repeat = 1:meta_ctrl.nr_repeats
        if result_ctrl(1,cell_nr).spike_nr(end,repeat) > 1;
            plot(result_ctrl(1,cell_nr).laser_ints_uniq,result_ctrl(1,cell_nr).first_freq,'ko')
        end
        if result_drug(1,cell_nr).spike_nr(end,repeat) > 1;
             plot(result_drug(1,cell_nr).laser_ints_uniq,result_drug(1,cell_nr).first_freq,'ro')
        end
    end
    title(result_ctrl(cell_nr).recording_id); hold on;
end

end


