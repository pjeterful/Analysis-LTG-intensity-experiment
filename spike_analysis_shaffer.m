function [analysis_ctrl, analysis_LTG]=spike_analysis_shaffer (ctrl_folder, LTG_folder)

% State the input folders and parameters.
ctrl_files  = dir(ctrl_folder);
LTG_files  = dir(LTG_folder);

% Check if the folders are the same size.

if size(ctrl_files,2) ~= size(LTG_files,2)
    error('Folder size is not equal')
end

% Create two structs to save output to.
analysis_ctrl={};
analysis_LTG={};


% Do this for each file
for fil = 3:2:size(ctrl_files);
    load(ctrl_files(fil).name);
    ctrl_exper_IF=exper;
    load(ctrl_files(fil+1).name);
    ctrl_exper_EPIO=exper;
    load(LTG_files(fil).name);
    LTG_exper_IF=exper;
    load(LTG_files(fil+1).name);
    LTG_exper_EPIO=exper;
    
    for sweep=1:size(ctrl_exper_IF,2);
        analysis_ctrl{fil-2}(sweep).time_IF=ctrl_exper_IF(sweep).time;
        analysis_ctrl{fil-2}(sweep).trace_IF=ctrl_exper_IF(sweep).v_rec;
        analysis_LTG{fil-2}(sweep).time_IF=LTG_exper_IF(sweep).time;
        analysis_LTG{fil-2}(sweep).trace_IF=LTG_exper_IF(sweep).v_rec;
    for sweep=1:size(ctrl_exper_EPIO,2);
        analysis_ctrl{fil-2}(sweep).time_EPIO=ctrl_exper_EPIO(sweep).time;
        analysis_ctrl{fil-2}(sweep).trace_EPIO=ctrl_exper_EPIO(sweep).v_rec;
        analysis_LTG{fil-2}(sweep).time_EPIO=LTG_exper_EPIO(sweep).time;
        analysis_LTG{fil-2}(sweep).trace_EPIO=LTG_exper_EPIO(sweep).v_rec;
    end
end
end
    
    