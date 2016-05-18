function [t50_ctrl, t50_LTG, h, p]=fit_succes(analysis_ctrl, analysis_LTG)

for cell=1:size(analysis_ctrl,2);
    
x_ctrl=analysis_ctrl{1, cell}(1).laser_intensity';
y_ctrl=analysis_ctrl{1, cell}(1).mean_succes_rate';
x_LTG=analysis_LTG{1, cell}(1).laser_intensity';
y_LTG=analysis_LTG{1, cell}(1).mean_succes_rate';
[~, xThreshold_ctrl, ~] = gaussian_fit(x_ctrl,y_ctrl);
[~, xThreshold_LTG, ~] = gaussian_fit(x_LTG,y_LTG);
t50_ctrl(cell)=xThreshold_ctrl;
t50_LTG(cell)=xThreshold_LTG;
end
[h,p]=ttest(t50_ctrl,t50_LTG);
end