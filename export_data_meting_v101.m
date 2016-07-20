function [exper, meta] = export_data_meting_v101(up_folder,down_folder)% ,meta_folder)
% This script exports data directly from a Meting file
% Input is Neuron Meting file, output is Export struct
% Rewrite of previous version by LvdV, FZ and SdK
% First created in HL May 7th 2014, Adapted until May 14th
% Improved for version 101, October 16, 2014

% Necessary adaptations:
% - Redefine structure, traces in the exper.line(x), not exper(x).line
% - Also make nr_sweeps etc. metadata in exp.format for example.
% - Determine the number of repeats in every sweep.

cd(up_folder)
metingfiles = dir(up_folder);
metingfiles = metingfiles(~strncmpi('.', {metingfiles.name}, 1));

% Run over the files in distinct folder to extract and save exper and meta
% On windows you should skip the first two files, on mac first 3.
for fil = 1:size(metingfiles,1)
    cd(up_folder)
    load(metingfiles(fil,1).name)

    % Create a struct for the exported Meting file and some empty structs
    exper = {};
    meta  = {};

    % % Check whether we're working with the right version
    % if Meting(1,1).version ~= 101000;
    %     error('The Meting is saved below version 101: too low')
    % end

    % Determine the dimensions of the Meting struct extracted from
    % Sweeps are the number of run individual recorded traces
    % Sets are sweeps that form functional entities, sets of recordings
    % Repeats are repetitions of the same sweeps

    % Check whether a recording was repeated (check this one again)
    % Only checks the repeats of the first one.
    % % Determine the total number of nodes and thus sweeps
    meta.nr_sweeps       = size(Meting,2);
    meta.nr_repeats      = size(Meting(1).adc,3);

    % Check for multiple sets by determining name of protocol in Meting file
    for sweeps = 1:meta.nr_sweeps
        naampje{sweeps} = Meting(1,sweeps).serienaam;
    end

    % From this derive the number of sets and sweeps within that set
    meta.nr_sets       = size(unique(naampje),2);
    meta.nr_set_parts  = size(naampje,2)/meta.nr_sets;

    % Determine the length of the adc and dac traces.
    % ADC is the number of rows, DAC is total allocated time points
    % These will not be used in other scripts
    len_sweep_adc = size(Meting(1).adc(:,1),1);
    if ~isempty(Meting(1,1).cdac)
        len_sweep_dac = sum(Meting(1,1).cdac{1,1}(:,1));
%   Check whether the ADC and DAC were both recorded well (are equal length)
%        if len_sweep_dac ~= len_sweep_adc;
%          error('ADC and DAC do not have same length')
%       end
    end

    % Allocate exper.strcts with NaNs, saving memory
    % Go to the level of abstraction needed right away
    % No talking about DAC or ADC, this is in V and I directly
    for sweeps = 1:meta.nr_sweeps
        exper(sweeps).time       = nan*ones(len_sweep_adc,1);
        exper(sweeps).v_rec      = nan*ones(len_sweep_adc,1);
        exper(sweeps).i_rec      = nan*ones(len_sweep_adc,1);
        if ~isempty(Meting(1,1).cdac)
            exper(sweeps).v_comm     = nan*ones(len_sweep_dac,1);
            exper(sweeps).i_comm     = nan*ones(len_sweep_dac,1);
            exper(sweeps).laser_comm = nan*ones(len_sweep_dac,1);
        end
    end

    % Create time array with times scaled to millisecond, do for all traces
    % Use the sec_2_ms scaling to get to the right timescale
    sec_2_ms      = 1000;
    for sweeps = 1:meta.nr_sweeps
        exper(sweeps).time = (([1:1:length(Meting(1,1).adc(:,1))]'/Meting(1,1).ADC.rate)*sec_2_ms);
    end

    % Record some metadata for selecting and namegiving
    % Based on the basic layout of Neuron
    for sweeps = 1:meta.nr_sweeps
        meta.prot        = Meting(1,1).nodenaam;
        meta.filename    = metingfiles(fil).name;
        meta.cellname    = meta.filename(end-19:end-4);
    end

    % Scale adc trace to become current or voltage, depending on recording
    % If statement checks what type of info is in the adc channel
    % Keep repeats together in the same struct, just the next column
    % Updated for next version to also work on multiple amplifiers.
    ticker = 0;
    for channel = 1:size(Meting(1).adc,2)
        if strcmp(Meting(1).ADC.scale(channel).Name,'Im') == 1;
            ticker = ticker + 1;
            for adc_sweeps = 1:meta.nr_sweeps
                for adc_repeats = 1:meta.nr_repeats
                 exper(ticker,adc_sweeps).i_rec(:,adc_repeats) = ...
                     double(Meting(adc_sweeps).adc(:,channel,adc_repeats))* Meting(adc_sweeps).ADC.scale(channel).User/Meting(adc_sweeps).ADC.ints;
                end
            end
        end
    end

    % Will skip the first command if it is not a valid current trace
    % Then will import as potential if the units are correct
    % Changed ADC.scale.Units to ADC.scale.Name (otherwise, double 10xVm).
    ticker = 0;
    for channel = 1:size(Meting(1).adc,2)
        if strcmp(Meting(1).ADC.scale(channel).Name,'Vm') == 1;
            ticker = ticker + 1;
            for adc_sweeps = 1:meta.nr_sweeps
                for adc_repeats = 1:meta.nr_repeats
                    exper(ticker,adc_sweeps).v_rec(:,adc_repeats) = ...
                        double(Meting(adc_sweeps).adc(:,channel,adc_repeats))* ...
                        Meting(adc_sweeps).ADC.scale(channel).User/Meting(adc_sweeps).ADC.ints;
                end
            end
        end
    end
    
    % Also export the Field recording if present. 
    ticker = 0;
    for channel = size(Meting(1).adc,2)
        if strcmp(Meting(1).ADC.scale(channel).Name,'Field-1') == 1;
            ticker = ticker +1;
            for adc_sweeps = 1:meta.nr_repeats
                exper(ticker,adc_sweeps).v_field(:,adc_repeats) = ...
                    double(Meting(adc_sweeps).adc(:,channel,adc_repeats))* ...
                    Meting(adc_sweeps).ADC.scale(channel).User/Meting(adc_sweeps).ADC.ints;
            end
        end
    end
    
    % Exporting the DAC channel is a bit more tricky, it is stored as an
    % assignment rather than a full 32-bit trace. 

    % Will also save the dac assignments from the Meting file so they can be
    % used to construct figures later.

    % We first determine the number of 'assingments' per sweep (this differs!)
    % Then create a 'marks' variable (begin and end), and fill the vector
    % between those marks with the appropriate value (after scaling). 

    for channel = 1:size(Meting(1).DAC.scale,1)
        if strcmp(Meting(1).DAC.scale(channel,1).Units,'mV')
            for dac_sweeps = 1:meta.nr_sweeps
                dac_ass      = size(Meting(1,dac_sweeps).cdac{1,channel},1);
                    for endings = 1:dac_ass
                        exper(dac_sweeps).v_dac_endtimes            = cumsum(Meting(1,dac_sweeps).cdac{1,channel}(1:endings,1));
                        exper(dac_sweeps).v_dac_endtimesII          = nan*ones(length(exper(dac_sweeps).v_dac_endtimes)+1,1);
                        exper(dac_sweeps).v_dac_endtimesII(1,1)     = 0;
                        exper(dac_sweeps).v_dac_endtimesII(2:end,1) = exper(dac_sweeps).v_dac_endtimes(1:end,1);
                    end
                for marks = 1:dac_ass
                    exper(dac_sweeps).v_comm((exper(dac_sweeps).v_dac_endtimesII(marks)+1):exper(dac_sweeps).v_dac_endtimesII(marks+1),1) = ...
                        double(Meting(1,dac_sweeps).cdac{1,channel}(marks,2) * Meting(1,1).DAC.scale(channel,1).User/Meting(1,1).DAC.ints);
                end
            end
        end
    end

    % Use same trick as earlier, search for the right scaling in order to
    % create the vector. Don't import if it is not the trace we're using.
    for channel = 1:size(Meting(1).DAC.scale,1)
        if strcmp(Meting(1).DAC.scale(channel,1).Units,'pA')
            for dac_sweeps = 1:meta.nr_sweeps
                dac_ass      = size(Meting(1,dac_sweeps).cdac{1,channel},1);
                    for endings = 1:dac_ass
                        exper(dac_sweeps).i_dac_endtimes            = cumsum(Meting(1,dac_sweeps).cdac{1,channel}(1:endings,1));
                        exper(dac_sweeps).i_dac_endtimesII          = nan*ones(length(exper(dac_sweeps).i_dac_endtimes)+1,1);
                        exper(dac_sweeps).i_dac_endtimesII(1,1)     = 0;
                        exper(dac_sweeps).i_dac_endtimesII(2:end,1) = exper(dac_sweeps).i_dac_endtimes(1:end,1);
                    end
                    for marks = 1:dac_ass
                    exper(dac_sweeps).i_comm((exper(dac_sweeps).i_dac_endtimesII(marks)+1):exper(dac_sweeps).i_dac_endtimesII(marks+1),1) = ...
                        double(Meting(1,dac_sweeps).cdac{1,channel}(marks,2) * Meting(1,1).DAC.scale(channel,1).User/Meting(1,1).DAC.ints);
                    end
            end
        end
    end

    % Extract the data on the laser DAC as well in order to analyse the
    % optogenetic experiments. Can work for afferent stimulus as well.

    % The intensity DAC is only used when the laser is ON
    % % This is no longer true 
    % The DMD DAC doesn't provide interesting information for analysis
    % Choice comes down to the intensity DAC(3) = ON/OFF and % in one!
    % strcmp statement works fine but in versions higher than 101 Blue is
    % capital, therefore the or statement.

    for channel = 1:size(Meting(1).DAC.scale,1)
        if or(strcmp(Meting(1).DAC.scale(channel,1).Name,'blue-TTL'),strcmp(Meting(1).DAC.scale(channel,1).Name,'Blue-TTL'))
            for dac_sweeps = 1:meta.nr_sweeps
                dac_ass      = size(Meting(1,dac_sweeps).cdac{1,channel},1);
                    for endings = 1:dac_ass
                        exper(dac_sweeps).l_dac_endtimes            = cumsum(Meting(1,dac_sweeps).cdac{1,channel}(1:endings,1));
                        exper(dac_sweeps).l_dac_endtimesII          = nan*ones(length(exper(dac_sweeps).l_dac_endtimes)+1,1);
                        exper(dac_sweeps).l_dac_endtimesII(1,1)     = 0;
                        exper(dac_sweeps).l_dac_endtimesII(2:end,1) = exper(dac_sweeps).l_dac_endtimes(1:end,1);
                        exper(dac_sweeps).nr_laser_stim             = (size(exper(dac_sweeps).l_dac_endtimes,1)-1)/2;
                    end
                    for marks = 1:dac_ass
                        exper(dac_sweeps).laser_comm((exper(dac_sweeps).l_dac_endtimesII(marks)+1):exper(dac_sweeps).l_dac_endtimesII(marks+1),1) = ...
                            double(Meting(1,dac_sweeps).cdac{1,channel}(marks,2) * Meting(1,1).DAC.scale(channel,1).User/Meting(1,1).DAC.ints);
                    end
            end
        end
    end

    % Determine the actual intensity of the laser
    % Use a very similar approach as with the TTL 
    for channel = 1:size(Meting(1).DAC.scale,1)
        if strcmp(Meting(1).DAC.scale(channel,1).Name,'Blue-Int')
            for dac_sweep = 1:meta.nr_sweeps
                dac_ass      = size(Meting(1,dac_sweep).cdac{1,channel},1);
                    for endings = 1:dac_ass
                        exper(dac_sweep).l_i_dac_endtimes            = cumsum(Meting(1,dac_sweep).cdac{1,channel}(1:endings,1));
                        exper(dac_sweep).l_i_dac_endtimesII          = nan*ones(length(exper(dac_sweep).l_i_dac_endtimes)+1,1);
                        exper(dac_sweep).l_i_dac_endtimesII(1,1)     = 0;
                        exper(dac_sweep).l_i_dac_endtimesII(2:end,1) = exper(dac_sweep).l_i_dac_endtimes(1:end,1);
                    end
                    for marks = 1:dac_ass
                        exper(dac_sweep).laser_int_comm((exper(dac_sweep).l_i_dac_endtimesII(marks)+1):exper(dac_sweep).l_i_dac_endtimesII(marks+1),1) = ...
                            double(Meting(1,dac_sweep).cdac{1,channel}(marks,2) * Meting(1,1).DAC.scale(channel,1).User/Meting(1,1).DAC.ints);
                    end
            end
        end
    end
    
    % In case of an experiment using a stimulus electrode instead of laser
    % stimulation save the i_dac endtimes of the the stimulus electrode.
     
    for channel = 1:size(Meting(1).DAC.scale,1)
        if strcmp(Meting(1).DAC.scale(channel,1).Units,'uA');
            for dac_sweeps = 1:meta.nr_sweeps
                dac_ass      = size(Meting(1,dac_sweeps).cdac{1,channel},1);
                    for endings = 1:dac_ass
                        exper(dac_sweeps).stim_l_dac_endtimes            = cumsum(Meting(1,dac_sweeps).cdac{1,channel}(1:endings,1));
                        exper(dac_sweeps).stim_l_dac_endtimesII          = nan*ones(length(exper(dac_sweeps).stim_l_dac_endtimes)+1,1);
                        exper(dac_sweeps).stim_l_dac_endtimesII(1,1)     = 0;
                        exper(dac_sweeps).stim_l_dac_endtimesII(2:end,1) = exper(dac_sweeps).stim_l_dac_endtimes(1:end,1);
                        exper(dac_sweeps).nr_electrode_stim             = (size(exper(dac_sweeps).stim_l_dac_endtimes,1)-1)/3;
                    end
                    for marks = 1:dac_ass
                        exper(dac_sweeps).electrode_comm((exper(dac_sweeps).stim_l_dac_endtimesII(marks)+1):exper(dac_sweeps).stim_l_dac_endtimesII(marks+1),1) = ...
                            double(Meting(1,dac_sweeps).cdac{1,channel}(marks,2) * Meting(1,1).DAC.scale(channel,1).User/Meting(1,1).DAC.ints);
                    end
            end
        end
    end

    % In the Noise experiments spike detections are used to time the laser
    % Use the isfield function to do conditional import of detect and used
    % SPIKES.detected are the spikes detected in the 'save' Meting
    % SPIKES.used laser application times (can differ per sweep)
    % Need to derive the selection that was used, now only the interval can be found. 
    % This type of 'saving' is only used in versions of Neuron over V220,
    % can be used as a filter (better probably).

%    for channel = 1:size(Meting,2)
%        if isfield(Meting,'SPIKES') == 1;
%            for dac_sweep = 1:meta.nr_sweeps
%                exper(1,dac_sweep).detected_spike_times = Meting(1,dac_sweep).SPIKES.detect;
%                exper(1,dac_sweep).laser_times          = Meting(1,dac_sweep).SPIKES.used;
%                % Due to the fact that the selection is missing right now
%                % (23/2/15) we need to derive it from these two values above.
%               if isempty(exper(1,dac_sweep).detected_spike_times)
%                   continue
%                end
%               % Check the possible effect of rounding off!!!
%                exper(1,dac_sweep).laser_pretime      = round(exper(1,dac_sweep).laser_times(1,1) - exper(1,dac_sweep).detected_spike_times(1,1));
%                exper(1,dac_sweep).AP_selection_times = exper(1,dac_sweep).laser_times - exper(1,dac_sweep).laser_pretime;
%            end     
%        end
%    end

    % Function here to save the file
    cd(down_folder);
    save(meta.cellname,'exper','meta');

%     % Save the meta seperately
%     cd(meta_folder)
%     save(meta.cellname,'meta');

    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End