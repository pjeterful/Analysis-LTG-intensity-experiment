function[FS_MIN_INT,FS_MAX_INT ]=calculate_MINMAX_FS_SSI(analysis_ctrl)
nr_cells=size(analysis_ctrl,2);
FS_MIN_INT=[];
FS_MAX_INT=[];
for cell=1:nr_cells;
    MIN=analysis_ctrl{1, cell}(1).NORM_FS_SSI(1,2:4)' ;
    FS_MIN_INT=vertcat(FS_MIN_INT,MIN);
    MAX=analysis_ctrl{1, cell}(1).NORM_FS_SSI(size(analysis_ctrl{1, cell}(1).NORM_FS_SSI,1),2:4)';
    FS_MAX_INT=vertcat(FS_MAX_INT,MAX);
    
end
