% Calcutlate the post stimulus times of all the first peak times following a
% laser stimulation and plot a post-stimulus time histogram. inputs are an
% analysis struct, the cell number of interest, the sweep number of
% interest, and a time window (ms) where the respons peak must fall
% within. Outputs are post-stimulus time histograms of control and LTG conditions
% per sweep in a subplot and per cell in a new window.  PAS 03-14-2016

function psth_plot=psthpiet(analysis_ctrl, analysis_LTG, which_cells, which_traces, window)

% Plot in a new figure for each new cell
for cell=[which_cells];
    figure(cell);
    nr_sw=size(which_traces,2);
    c=0;
   % Plot in a new subplot for each new sweep
    for sweep=[which_traces];
        c=c+1;       
        subplot(nr_sw,2,c);
            % Calcuate the post stimulus times of all detected laser peaks for
            % the control conditions. Copy the laser times from the analysis struct
            lasertimes_ctrl=analysis_ctrl{1,cell}(sweep).laser_peaks;
             % Copy the spike times per repeat for ev]ery repeat
             for repeat=1:size(analysis_ctrl{1, cell}(sweep).spike_peaks,2);
                 spiketimes_ctrl{1,repeat}=analysis_ctrl{1,cell}(sweep).spike_peaks{1,repeat};
                % The number of laser stimulations 
                 for stim=1:size(lasertimes_ctrl,1);
                     % Find every first spike within the spike window 
                     SAL_ctrl=find(spiketimes_ctrl{1,repeat} > lasertimes_ctrl(stim)...
                      & spiketimes_ctrl{1,repeat} < (lasertimes_ctrl(stim) + window),1);
                    % When no spike is found within the the window, find
                    % returns an empty vector, replace the empty cell
                    % with a 0.
                     if isempty (SAL_ctrl);
                         SAL_ctrl=0;
                     end
                     % If the cell containes a zero put a NaN in the new
                     % struct, if not, substract the laser time from the
                     % corresponding spike time
                     spikes_after_laser_ctrl(stim,repeat)=SAL_ctrl;
                     if spikes_after_laser_ctrl(stim,repeat)==0;
                        PST_ctrl{1,repeat}(stim,:)=NaN;
                     else
                        PST_ctrl{1,repeat}(stim,:)=...
                        spiketimes_ctrl{1,repeat}(spikes_after_laser_ctrl(stim,repeat))...
                        -lasertimes_ctrl(stim) ; 
                     end
                 end
             end
        % Combine all repeats into one aray
        comb_PST_ctrl=[PST_ctrl{1,1};PST_ctrl{1,2};PST_ctrl{1,3}];
        c_PST_ctrl=[PST_ctrl{1,1},PST_ctrl{1,2},PST_ctrl{1,3}];    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

             % Calcuate the post stimulus times of all detected laser peaks for
             % the LTG conditions. Copy the laser times from the analysis struct
            lasertimes_LTG=analysis_LTG{1,cell}(sweep).laser_peaks;
             % Copy the spike times per repeat for ev]ery repeat
             for repeat=1:size(analysis_LTG{1, cell}(sweep).spike_peaks,2);
                 spiketimes_LTG{1,repeat}=analysis_LTG{1,cell}(sweep).spike_peaks{1,repeat};
                % The number of laser stimulations 
                 for stim=1:size(lasertimes_LTG,1);
                     % Find every first spike within the spike window
                     SAL_LTG=find(spiketimes_LTG{1,repeat} > lasertimes_LTG(stim)...
                     & spiketimes_LTG{1,repeat} < (lasertimes_LTG(stim) + window),1);
                    % When no spike is found within the the window, find
                    % returns an empty vector, replace the empty cell
                    % with a 0. 
                    if isempty (SAL_LTG);
                        SAL_LTG=0;
                    end
                     % If the cell containes a zero put a NaN in the new
                     % struct, if not, substract the laser time from the
                     % corresponding spike time
                     spikes_after_laser_LTG(stim,repeat)=SAL_LTG;
                     if spikes_after_laser_LTG(stim,repeat)==0;
                         PST_LTG{1,repeat}(stim,:)=NaN;
                     else
                         PST_LTG{1,repeat}(stim,:)=...
                         spiketimes_LTG{1,repeat}(spikes_after_laser_LTG(stim,repeat))...
                         -lasertimes_LTG(stim) ; 
                     end
                 end
             end
        % Combine all repeats into one aray     
        comb_PST_LTG=[PST_LTG{1,1};PST_LTG{1,2};PST_LTG{1,3}];
        c_PST_LTG=[PST_LTG{1,1},PST_LTG{1,2},PST_LTG{1,3}];
         
        %Plot the control and LTG post-stimulus times in a histogram of the
        %current cell and sweep. And add titels, legends etc.
        histogram(comb_PST_ctrl,0:window,'FaceColor','b')
        hold on
        histogram(comb_PST_LTG,0:window,'FaceColor','r') 
        a=num2str(analysis_ctrl{1, cell}(1).laser_intensity(sweep));
        xlabel('Post stimulus time (ms)');
        ylabel('nr of spikes');
        title(['stimulus intensity: ' a]);
        legend('Control', 'LTG');
        alpha(.3);
        c=c+1;
        
        
        subplot(nr_sw,2,c);
        plot(c_PST_ctrl,'b*')
        hold on
        plot(c_PST_LTG,'r*')
        xlabel('Stimulus number');
        ylabel('Post stimulus time (ms)');
        title(['stimulus intensity: ' a]);
%        legend('Control', 'LTG');
    end
end
end