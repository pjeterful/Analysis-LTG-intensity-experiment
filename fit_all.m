function [a_ctrl, a_LTG, h, p]=fit_all(analysis_ctrl, analysis_LTG)

for cell=1:size(analysis_ctrl,2);
    
x_ctrl=analysis_ctrl{1, cell}(1).laser_intensity';
y_ctrl=analysis_ctrl{1, cell}(1).mean_succes_rate';
x_LTG=analysis_LTG{1, cell}(1).laser_intensity';
y_LTG=analysis_LTG{1, cell}(1).mean_succes_rate';
[~, xThreshold_ctrl, ~] = gaussian_fit(x_ctrl,y_ctrl);
[~, xThreshold_LTG, ~] = gaussian_fit(x_LTG,y_LTG);
a_ctrl(cell)=xThreshold_ctrl;
a_LTG(cell)=xThreshold_LTG;
[h,p]=ttest(a_ctrl,a_LTG)
end
end