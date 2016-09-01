function SSI=plot_SSI(analysis_ctrl,analysis_LTG, which_cells)
nr_cells=size(analysis_ctrl,2);
for cell=[which_cells];
    hold on
    plot(analysis_ctrl{1,cell}(1).NORM_FS_SSI(:,1),analysis_ctrl{1,cell}(1).NORM_FS_SSI(:,2:4), 'ok')
    plot(analysis_LTG{1,cell}(1).NORM_FS_SSI(:,1),analysis_LTG{1,cell}(1).NORM_FS_SSI(:,2:4), 'or')
   xlabel('Normalized stimulus intensity (%)');
   ylabel('SSI (ms)');
end