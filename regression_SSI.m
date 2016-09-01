%Performs linear regression on analysis struct
function [R,P,b,f]=regression_SSI(analysis_ctrl)

nr_cells=size(analysis_ctrl,2);
comb_SSI_ctrl_int=[];
comb_SSI_ctrl_SSI=[];
for cell=1:nr_cells;
NORM_SSI=analysis_ctrl{1, cell}(1).NORM_FS_SSI;
[r,c]=find(isnan(NORM_SSI)) ;
NORM_SSI(r,:)=[];
for repeat=1:size(analysis_ctrl{1, cell}(2).spike_peaks,2);
    int=NORM_SSI(:,1);      
    comb_SSI_ctrl_int=vertcat(comb_SSI_ctrl_int,int);
    SSI=NORM_SSI(:,repeat+1);
    comb_SSI_ctrl_SSI=vertcat(comb_SSI_ctrl_SSI,SSI);
    end
end
comb_SSI_ctrl=horzcat(comb_SSI_ctrl_int,comb_SSI_ctrl_SSI);
[rr,cc]=find(comb_SSI_ctrl==0);
comb_SSI_ctrl(rr,:)=[];
[R,P]=corrcoef(comb_SSI_ctrl(:,1),comb_SSI_ctrl(:,2));
b=regress(comb_SSI_ctrl(:,2),comb_SSI_ctrl(:,1));
f=fit(comb_SSI_ctrl(:,1), comb_SSI_ctrl(:,2),'exp2');
plot(f,'r',comb_SSI_ctrl(:,1),comb_SSI_ctrl(:,2), 'ro')
axis([0 90 0 15]);
end

