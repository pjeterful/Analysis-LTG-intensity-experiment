function[analysis_ctrl, analysis_LTG]=complete_analysis(ctrl_folder, LTG_folder,window,frame)
% This function performs the analysis of electrophiyiological data acquired
% by recording done by NEURON, inputs are a folder containing control files
%, a folder containing drug files, a spike window after a laser pulse within 
% which a spike is counted as related to the laser pulse (15 ms) and the
% size of the reading frame for creating a running average of the nr of
% spikes, this is the half-unbinding rate of the drug used translated to
% the number of laser pulses occuring within this timespan, for LTG at 40
% Hz stimulation the frame is 5.
    [analysis_ctrl, analysis_LTG]=spike_analysis_LTG_new(ctrl_folder, LTG_folder);
    [analysis_ctrl, analysis_LTG]=create_succes_rate(analysis_ctrl, analysis_LTG, window);
    [analysis_ctrl, analysis_LTG]=create_doublet(analysis_ctrl,analysis_LTG,window,frame);
    [analysis_ctrl,analysis_LTG]=create_SSI(analysis_ctrl,analysis_LTG,window);
end