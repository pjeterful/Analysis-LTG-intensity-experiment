function [R,P,b]=correlate_SSI(analysis_ctrl)

nr_cells=size(analysis_ctrl,2);
comb_SSI_ctrl_int=[];
comb_SSI_ctrl_SSI=[];
for cell=1:nr_cells;
    for repeat=1:size(analysis_ctrl{1, cell}(2).spike_peaks,2);
        int=analysis_ctrl{1,cell}(1).NORM_FS_SSI(:,1);      
comb_SSI_ctrl_int=vertcat(comb_SSI_ctrl_int,int);
SSI=analysis_ctrl{1,cell}(1).NORM_FS_SSI(:,repeat+1);
comb_SSI_ctrl_SSI=vertcat(comb_SSI_ctrl_SSI,SSI);
    end
end
for ding=1:size(comb_SSI_ctrl_int,1);
    if isnan(comb_SSI_ctrl_SSI(ding));
        continue
    else
        C(ding)=ding;
    end
end
[r,c]=find(C>0);
comb_SSI_ctrl=horzcat(comb_SSI_ctrl_int,comb_SSI_ctrl_SSI);
comb_SSI_ctrl=comb_SSI_ctrl([c],:);
[R,P]=corrcoef(comb_SSI_ctrl(:,1),comb_SSI_ctrl(:,2));
b=regress(comb_SSI_ctrl(:,2),comb_SSI_ctrl(:,1));
end