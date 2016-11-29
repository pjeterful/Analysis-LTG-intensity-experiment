function[F_IPSC, F_IPSC_MAX, F_IPSC_ALL,nr_suc_IPSC, analysis ]=calculate_IPSC(analysis)
nr_cells=size(analysis,2);
for cell=1:nr_cells;
    for repeat=1:3;
        baseline_ctrl=analysis{1, cell}(11).spike_trace(analysis{1, cell}(2).laser_peaks(1,1)*10,repeat) ;
        ampl(repeat)=analysis{1, cell}(11).IPSC_peaks{1, repeat}(1,2)-baseline_ctrl;
        ampl(repeat)=-ampl(repeat);
    end
    F_IPSC_MAX(cell,1)=mean(ampl);
    for sweep=2:11
        for repeat=1:3;
            baseline_ctrl_F=analysis{1, cell}(11).spike_trace(analysis{1, cell}(2).laser_peaks(1,1)*10,repeat) ; 
            ding(repeat)=analysis{1, cell}(sweep).IPSC_peaks{1, repeat}(1,2)-baseline_ctrl_F;
            for I=1:25
        baseline_ctrl=analysis{1, cell}(11).spike_trace(analysis{1, cell}(2).laser_peaks(I,1)*10,repeat) ; 
        analysis{1,cell}(sweep).IPSC_amplitude(I,repeat)=...
            -(analysis{1, cell}(sweep).IPSC_peaks{1, repeat}(I,2)-baseline_ctrl);
            end
        end
        analysis{1,cell}(sweep).IPSC_amplitude(1:25,4)=mean(analysis{1,cell}(sweep).IPSC_amplitude,2);
        [r,c]=find(analysis{1,cell}(sweep).IPSC_amplitude(1:25,4)<25,1);
        if isempty(r)
          nr_suc_IPSC(sweep, cell)=25;
        else
        nr_suc_IPSC(sweep, cell)=r-1;
        end
        F_IPSC{1,cell}(sweep-1,1)=-mean(ding);
        F_IPSC_ALL{1,cell}(sweep,1:3)=-ding;
        
    end
end
end
    
    
        