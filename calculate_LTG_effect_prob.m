function [ctrl_prob, ctrl_int, LTG_prob, diff_spike_prob]=calculate_LTG_effect_prob(analysis_ctrl, analysis_LTG, P)
nr_cells=size(analysis_ctrl,2);
ind=0;

if P=='all'
    for cell=1:nr_cells;
        diff_spike_prob{1,cell}(:,1)=analysis_ctrl{1, cell}(1).laser_intensity  ;
        diff_spike_prob{1,cell}(:,2)=analysis_ctrl{1, cell}(1).mean_nr_spikes-...
        analysis_LTG{1, cell}(1).mean_nr_spikes;
    
    end
  ctrl_prob=NaN;
  ctrl_int=NaN;
  LTG_prob=NaN;
end


if isnumeric(P)==1
for cell=1:nr_cells;
  [r,c]=find(analysis_ctrl{1, cell}(1).mean_nr_spikes>=P,1);
  if isempty(r)
      ind=ind+1;
      continue
  end
  ctrl_prob(cell-ind,1)=analysis_ctrl{1, cell}(1).mean_nr_spikes(r,1);
  ctrl_int(cell-ind,1)=analysis_ctrl{1, cell}(1).laser_intensity(r,1);
  LTG_prob(cell-ind,1)=analysis_LTG{1, cell}(1).mean_nr_spikes(r,1);
  diff_spike_prob(cell-ind,1)=ctrl_prob(cell-ind,1)-LTG_prob(cell-ind,1);
end
end
end