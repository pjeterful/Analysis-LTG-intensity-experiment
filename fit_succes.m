%this fucntion creates gaussian fit of the input data x/y
function [t50_ctrl, t50_LTG, vec_x_ctrl, vec_y_ctrl, vec_x_LTG, vec_y_LTG, h, p,adjrsqr_ctrl,adjrsqr_LTG]=fit_succes(analysis_ctrl, analysis_LTG)

for cell=1:size(analysis_ctrl,2);
    
x_ctrl=analysis_ctrl{1, cell}(1).laser_intensity';
y_ctrl=analysis_ctrl{1, cell}(1).mean_succes_rate';
x_LTG=analysis_LTG{1, cell}(1).laser_intensity';
y_LTG=analysis_LTG{1, cell}(1).mean_succes_rate';
[~, xThreshold_ctrl, vecFitX_ctrl, vecFitY_ctrl, ~, gof_ctrl] = gaussian_fit(x_ctrl,y_ctrl);
[~, xThreshold_LTG, vecFitX_LTG, vecFitY_LTG, ~,gof_LTG] = gaussian_fit(x_LTG,y_LTG);
t50_ctrl(cell)=xThreshold_ctrl;
adjrsqr_ctrl(cell)=gof_ctrl.adjrsquare;
t50_LTG(cell)=xThreshold_LTG;
adjrsqr_LTG(cell)=gof_LTG.adjrsquare;
vec_x_ctrl{cell}=vecFitX_ctrl;
vec_y_ctrl{cell}=vecFitY_ctrl;
vec_x_LTG{cell}=vecFitX_LTG;
vec_y_LTG{cell}=vecFitY_LTG;
end
[h,p]=ttest(t50_ctrl,t50_LTG);
end