function ISI_plot=ISI(analysis_ctrl, analysis_LTG, which_cells, which_traces, window)

% This function calculates the times between two spikes following a single
% laser pulse (doublet) when it occures. It plots these times in a
% histogram and in a graph per  stimulus number. Input is a analysis_ctrl
% and LTG struct, which cells and traces are of interest and the time window
% whithin which the spikes must follow the laser pulse to be counted as
% valid. PAS 23-06-2016.

% Plot in a new figure for each new cell
for cell=[which_cells];
    figure(cell);
    nr_sw=size(which_traces,2);
    c=0;
    % Plot in a new subplot for each new sweep
    for sweep=[which_traces];
        c=c+1;       
        subplot(nr_sw,2,c); 
            % Copy the laser times from the analysis struct
            lasertimes_ctrl=analysis_ctrl{1,cell}(sweep).laser_peaks;
             % Copy the spike times per repeat for every repeat
             for repeat=1:size(analysis_ctrl{1, cell}(sweep).spike_peaks,2);
                 spiketimes_ctrl{1,repeat}=analysis_ctrl{1,cell}(sweep).spike_peaks{1,repeat};
                % The number of laser stimulations 
                 for stim=1:size(lasertimes_ctrl,1);
                     % Find every spike within the spike window 
                     SAL_ctrl=find(spiketimes_ctrl{1,repeat} > lasertimes_ctrl(stim)...
                      & spiketimes_ctrl{1,repeat} < (lasertimes_ctrl(stim) + window));
                    % When no spike is found within the the window, find
                    % returns an empty vector, replace the empty cell. When
                    %there are no doublets following a laser pulse (so less
                    %then 2 spike within the window) place a NaN en continue 
                    %to the next laser stimulus.
                  
                     if size(SAL_ctrl, 1)<2
                        ISI_ctrl{1,repeat}(stim,:)=NaN;
                         continue
                         %Else take the first to spike times (doublet) of this stimulus 
                         %and put them  in the variable
                     else
                         SAL_ctrl(1)=spiketimes_ctrl{1,repeat}(SAL_ctrl(1));
                         SAL_ctrl(2)=spiketimes_ctrl{1,repeat}(SAL_ctrl(2));
                     end
                        %Calculate the time between these spikes (ISI) by
                        %suprtracting one from the other. 
                      ISI_ctrl{1,repeat}(stim,:)=SAL_ctrl(2)-SAL_ctrl(1);
                 end
             end
             %Combine the repeats in vecors and a matrix individualy so
             %they can be easely plotted in a histogram and regular plot
             %sepperately.
             comb_ISI_ctrl=[ISI_ctrl{1,1};ISI_ctrl{1,2};ISI_ctrl{1,3}];  
             c_ISI_ctrl=[ISI_ctrl{1,1},ISI_ctrl{1,2},ISI_ctrl{1,3}];
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DO the same thing for the LTG condition.
            lasertimes_LTG=analysis_LTG{1,cell}(sweep).laser_peaks;
             % Copy the spike times per repeat for ev]ery repeat
             for repeat=1:size(analysis_LTG{1, cell}(sweep).spike_p.eaks,2);
                 spiketimes_LTG{1,repeat}=analysis_LTG{1,cell}(sweep).spike_peaks{1,repeat};
                % The number of laser stimulations .
                 for stim=1:size(lasertimes_LTG,1);
                     % Find every spike within the spike window 
                     SAL_LTG=find(spiketimes_LTG{1,repeat} > lasertimes_LTG(stim)...
                      & spiketimes_LTG{1,repeat} < (lasertimes_LTG(stim) + window))
                  
                       if size(SAL_LTG, 1)<2
                        ISI_LTG{1,repeat}(stim,:)=NaN;
                         continue
                     else
                         SAL_LTG(1)=spiketimes_LTG{1,repeat}(SAL_LTG(1));
                         SAL_LTG(2)=spiketimes_LTG{1,repeat}(SAL_LTG(2));
                     end
                   
                      ISI_LTG{1,repeat}(stim,:)=SAL_LTG(2)-SAL_LTG(1);   
                 end
             end
             comb_ISI_LTG=[ISI_LTG{1,1};ISI_LTG{1,2};ISI_LTG{1,3}];  
              c_ISI_LTG=[ISI_LTG{1,1},ISI_LTG{1,2},ISI_LTG{1,3}];

             x=size(analysis_ctrl{1, cell}(2).laser_peaks ,1);
        %Plot the control and LTG Interstimulus inteval times in a histogram of the
        %current cell and sweep. And add titels, legends etc.
        histogram(comb_ISI_ctrl,0:window,'FaceColor','k')
        hold on
        histogram(comb_ISI_LTG,0:window,'FaceColor','r') 
        a=num2str(analysis_ctrl{1, cell}(1).laser_intensity(sweep));
        axis([0 window 0 25]);
        xlabel('Inter spike interval (ms)');
        ylabel('nr of spikes');
        title(['stimulus intensity: ' a]);
        legend('Control', 'LTG');
        alpha(.3);
        c=c+1;
        
        %Plot the Interstimulus time intevals per laser pulse.
        subplot(nr_sw,2,c);
        plot(c_ISI_ctrl,'k*')
        hold on
        axis([0 x 0 window]); 
        plot(c_ISI_LTG,'r*')
        xlabel('Stimulus number');
        ylabel('ISI (ms)');
        title(['stimulus intensity: ' a]);
%       legend('Control', 'LTG');
    end
end
end