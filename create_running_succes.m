function [analysis_ctrl, analysis_LTG]=create_running_succes(analysis_ctrl, analysis_LTG, window)

for cell=1:size(analysis_ctrl,2);
    for sweep=1:size(analysis_ctrl{1,cell},2);  
av_det_peaks_ctrl=(analysis_ctrl{1, cell}(sweep).det_peaks{1, 1}(:,1)  +...
     analysis_ctrl{1, cell}(sweep).det_peaks{1, 2}(:,1) +...
     analysis_ctrl{1, cell}(sweep).det_peaks{1, 3}(:,1))/3;
av_det_peaks_ctrl2=av_det_peaks_ctrl';          
mask= ones (1,window)/window;
analysis_ctrl{1,cell}(sweep).running_average_succes=conv(av_det_peaks_ctrl2, mask, 'valid')';
    end
end

for cell=1:size(analysis_LTG,2);
    for sweep=1:size(analysis_LTG{1,cell},2);
av_det_peaks_LTG=(analysis_LTG{1, cell}(sweep).det_peaks{1, 1}(:,1)  +...
     analysis_LTG{1, cell}(sweep).det_peaks{1, 2}(:,1) +...
     analysis_LTG{1, cell}(sweep).det_peaks{1, 3}(:,1))/3;
av_det_peaks_LTG2=av_det_peaks_LTG';          
mask= ones (1,window)/window;
analysis_LTG{1,cell}(sweep).running_average_succes=conv(av_det_peaks_LTG2, mask, 'valid')';
    end
end
end