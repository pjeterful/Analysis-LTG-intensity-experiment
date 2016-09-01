function[analysis_ctrl,analysis_LTG]=create_SSI(analysis_ctrl,analysis_LTG,window)

nr_cells=size(analysis_LTG,2);
for cell=1:nr_cells;
    nr_sweeps=size(analysis_LTG{1, cell}(1).laser_intensity,1);
    for sweep=1:nr_sweeps;
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
                         analysis_LTG{1,cell}(sweep).SSI(stim,repeat)=NaN;
                     elseif spiketimes_LTG{1,repeat}(spikes_after_laser_LTG(stim,repeat),1)...
                         -lasertimes_LTG(stim)<1 ; 
                         analysis_LTG{1,cell}(sweep).SSI(stim,repeat)=NaN;
                     else
                         analysis_LTG{1,cell}(sweep).SSI(stim,repeat)=...
                         spiketimes_LTG{1,repeat}(spikes_after_laser_LTG(stim,repeat),1)...
                         -lasertimes_LTG(stim) ; 
                     end
                 end
                 if isnan(analysis_LTG{1,cell}(sweep).SSI(1,repeat));
                     analysis_LTG{1,cell}(1).FS_SSI(sweep,repeat)=NaN;
                     continue
                 else
                    analysis_LTG{1,cell}(1).FS_SSI(sweep,repeat)=...
                        analysis_LTG{1,cell}(sweep).SSI(1,repeat);
                 end
                 
             end
    end
    analysis_LTG{1, cell}(1).mean_FS_SSI=mean(analysis_LTG{1, cell}(1).FS_SSI(:,1:size(analysis_LTG{1, cell}(sweep).spike_peaks,2)),2);
    inv_FS_SSI=analysis_LTG{1,cell}(1).mean_FS_SSI';
    [row,f(cell)]=find(isnan(inv_FS_SSI)==0,1);
    norm_int(cell)=analysis_LTG{1,cell}(1).laser_intensity(f(cell));
    for int=f(cell):size(analysis_LTG{1,cell}(1).FS_SSI,1);
    analysis_LTG{1,cell}(1).NORM_FS_SSI(int-f(cell)+1,1)=analysis_LTG{1,cell}(1).laser_intensity(int)-norm_int(cell)+1;
    analysis_LTG{1,cell}(1).NORM_FS_SSI(int-f(cell)+1,2:4)=analysis_LTG{1,cell}(1).FS_SSI(int,1:3);
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nr_cells=size(analysis_ctrl,2);
for cell=1:nr_cells;
    nr_sweeps=size(analysis_ctrl{1, cell}(1).laser_intensity,1);
    for sweep=1:nr_sweeps;
         % Calcuate the post stimulus times of all detected laser peaks for
             % the ctrl conditions. Copy the laser times from the analysis struct
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
                         analysis_ctrl{1,cell}(sweep).SSI(stim,repeat)=NaN;
                     elseif spiketimes_ctrl{1,repeat}(spikes_after_laser_ctrl(stim,repeat),1)...
                         -lasertimes_ctrl(stim)<1;
                         analysis_ctrl{1,cell}(sweep).SSI(stim,repeat)=NaN;
                     else
                         analysis_ctrl{1,cell}(sweep).SSI(stim,repeat)=...
                         spiketimes_ctrl{1,repeat}(spikes_after_laser_ctrl(stim,repeat),1)...
                         -lasertimes_ctrl(stim) ; 
                     end
                 end
                   if isnan(analysis_ctrl{1,cell}(sweep).SSI(1,repeat));
                       analysis_ctrl{1,cell}(1).FS_SSI(sweep,repeat)=NaN;
                     continue
                 else
                    analysis_ctrl{1,cell}(1).FS_SSI(sweep,repeat)=...
                        analysis_ctrl{1,cell}(sweep).SSI(1,repeat);
                 end
             end
    end
    analysis_ctrl{1, cell}(1).mean_FS_SSI=mean(analysis_ctrl{1, cell}(1).FS_SSI(:,1:size(analysis_LTG{1, cell}(sweep).spike_peaks,2)),2);
    for int=f(cell):size(analysis_ctrl{1,cell}(1).FS_SSI,1);
    analysis_ctrl{1,cell}(1).NORM_FS_SSI(int-f(cell)+1,1)=analysis_ctrl{1,cell}(1).laser_intensity(int)-norm_int(cell)+1;
    analysis_ctrl{1,cell}(1).NORM_FS_SSI(int-f(cell)+1,2:4)=analysis_ctrl{1,cell}(1).FS_SSI(int,1:3);
end
end
end

            