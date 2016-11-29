function[t50,y50_ctrl,y50_LTG]=calculate_t50(analysis_ctrl, analysis_LTG)
for cell=1:6
    f_norm=fit([0:10:100]', analysis_ctrl{1,cell}(1:11,2),'poly2');
    f=fit([0:10:100]', analysis_ctrl{1,cell}(1:11,1),'poly2');
    x=0:0.01:100;
    ding=f_norm(x);
    [v,indc]=min(abs(ding-0.5*max(analysis_ctrl{1,cell}(1:11,2))));
    t50(cell)=x(indc);
    fLTG=fit([0:10:100]', analysis_LTG{1,cell}(1:11,1),'poly2');
    y50_LTG(cell)=fLTG(t50(cell));
    y50_ctrl(cell)=f(t50(cell));
end

