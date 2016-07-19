function[drift,h,p]=calculate_drift(analysis_ctrl,analysis_LTG)

for cell=1:size(analysis_ctrl,2);
     for sweep=1:size(analysis_ctrl{1,cell},2)
         for repeat=1:size(analysis_ctrl{1, cell}(sweep).spike_peaks,2);
             r_ctrl(repeat)=analysis_ctrl{1, cell}(sweep).spike_trace(1,repeat);
             r_LTG(repeat)=analysis_LTG{1, cell}(sweep).spike_trace(1,repeat);
         end
             drift{1,cell}(sweep).membrane_potential_ctrl=mean(mean(r_ctrl,1));
             drift{1,cell}(sweep).membrane_potential_LTG=mean(mean(r_LTG,1));
             mm_ctrl(sweep)=drift{1,cell}(sweep).membrane_potential_ctrl;
             mm_LTG(sweep)=drift{1,cell}(sweep).membrane_potential_LTG;
     end
     drift{1,cell}(1).mean_membrane_potential_ctrl=mean(mm_ctrl);
     drift{1,cell}(1).mean_membrane_potential_LTG=mean(mm_LTG);
     t_membrane_ctrl(cell)=drift{1,cell}(1).mean_membrane_potential_ctrl;
     t_membrane_LTG(cell)=drift{1,cell}(1).mean_membrane_potential_LTG;  
end
[h,p]=ttest(t_membrane_ctrl,t_membrane_LTG);
plot(t_membrane_ctrl, 'ko')
hold on
plot(t_membrane_LTG, 'ro')
xlabel('Cell');
ylabel('Vrest (mV)');
legend('control','LTG');
end