%Create a struct running_average_succes in existing analysis ctrl and LTG
%files containing a running average of the current succes rates. 
%Input is a ctrl and LTG struct and a mask frame for the running average.
%The standard frame setting is 5.
%Created 31-04-2016 PAS
function [analysis_ctrl, analysis_LTG]=create_running_succes(analysis_ctrl, analysis_LTG, frame)
% For the control file each cell and sweep seperate
for cell=1:size(analysis_ctrl,2);
    for sweep=1:size(analysis_ctrl{1,cell},2);  
        %Create an average of the three repeats an transform it into a
        %vector.
        av_det_peaks_ctrl=(analysis_ctrl{1, cell}(sweep).det_peaks{1, 1}(:,1)  +...
        analysis_ctrl{1, cell}(sweep).det_peaks{1, 2}(:,1) +...
        analysis_ctrl{1, cell}(sweep).det_peaks{1, 3}(:,1))/3;
        av_det_peaks_ctrl2=av_det_peaks_ctrl';   
        %To create an average all values comming from conv() need to be
        %devided by the size of the window.
        mask= ones (1,frame)/frame;
        analysis_ctrl{1,cell}(sweep).running_average_succes=conv(av_det_peaks_ctrl2, mask)';
        sctrl=size(analysis_ctrl{1,cell}(sweep).running_average_succes,1);
        %Cut of the acces values created by the moving average at the end
        analysis_ctrl{1,cell}(sweep).running_average_succes=...
        analysis_ctrl{1,cell}(sweep).running_average_succes(1:(sctrl-frame+1));
        %Because the running avregages are devided by the window, the values 
        %without a complete window should be multiplicated by the window*
        %the number values in the window at that point.
        for w=1:frame;
            analysis_ctrl{1,cell}(sweep).running_average_succes(w,1)=...
            analysis_ctrl{1,cell}(sweep).running_average_succes(w,1)/w*frame;
        end
    end
end

% Do the same for LTG files
for cell=1:size(analysis_LTG,2);
    for sweep=1:size(analysis_LTG{1,cell},2);
        av_det_peaks_LTG=(analysis_LTG{1, cell}(sweep).det_peaks{1, 1}(:,1)  +...
        analysis_LTG{1, cell}(sweep).det_peaks{1, 2}(:,1) +...
        analysis_LTG{1, cell}(sweep).det_peaks{1, 3}(:,1))/3;
        av_det_peaks_LTG2=av_det_peaks_LTG';          
        mask= ones (1,frame)/frame;
        analysis_LTG{1,cell}(sweep).running_average_succes=conv(av_det_peaks_LTG2, mask)';
        sLTG=size(analysis_LTG{1,cell}(sweep).running_average_succes,1);
        analysis_LTG{1,cell}(sweep).running_average_succes=...
        analysis_LTG{1,cell}(sweep).running_average_succes(1:(sLTG-frame+1));
        for w=1:frame;
            analysis_LTG{1,cell}(sweep).running_average_succes(w,1)=...
            analysis_LTG{1,cell}(sweep).running_average_succes(w,1)/w*frame;
        end
    end
end
end