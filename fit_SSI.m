function [angle_ctrl, angle_LTG]=fit_SSI(analysis_ctrl, analysis_LTG)
nr_cells=size(analysis_ctrl,2);
for cell =1:nr_cells;
    count=0;
    for sweep=1:size(analysis_ctrl{1, cell}(1).laser_intensity  , 1) ;
        stimsize=size(analysis_ctrl{1, 2}(1).succes_rate,1);
        x=[1:stimsize ];
        mn_SSI_ctrl{1, cell}{sweep,1}=mean(analysis_ctrl{1, cell}(sweep).SSI,2)'; 
        mn_SSI_LTG{1, cell}{sweep,1}=mean(analysis_LTG{1, cell}(sweep).SSI,2)'; 
        
        %If your inclusion criterium is that a certain percentage of the
        %stimulus pulses needs to evoke a spike, use the line below and
        %replace o.5 with whatever part you prefere. Otherwise, use
        %halfstime=2, because a fit needs at least to data points.
%       halfstim=ceil(stimsize*0.5);
 %       halfstim=2;
  %      if isempty(find(isnan(mn_SSI_LTG{1, cell}{sweep,1}(1,1:halfstim))))==1 && ...
  %         isempty(find(isnan(mn_SSI_ctrl{1, cell}{sweep,1}(1,1:halfstim))))==1;
%            nanplace=[];
 %           nanplace_LTG=find(isnan(mn_SSI_LTG{1, cell}{sweep,1}),1);
 %           nanplace_ctrl=find(isnan(mn_SSI_ctrl{1, cell}{sweep,1}),1);
 %           nanplace=vertcat(nanplace_ctrl, nanplace_LTG);
 %           place=min(nanplace)-1;
 %           if isempty(place);
 %               place=stimsize;
 %           end
 
            y_ctrl=mn_SSI_ctrl{1, cell}{sweep,1}(1,:);
            y_LTG=mn_SSI_LTG{1, cell}{sweep,1}(1,:);
            nan_place_ctrl=find(isnan(y_ctrl));
            nan_place_LTG=find(isnan(y_LTG));
            x_ctrl=x;
            x_LTG=x;
            
            if isempty (nan_place_ctrl)==0
            count_ctrl=0;         
            for nan_i_ctrl=nan_place_ctrl;
            i_ctrl=nan_i_ctrl-count_ctrl;
            y_ctrl(i_ctrl)=[];
            x_ctrl(i_ctrl)=[];
            count_ctrl=count_ctrl+1;
            end
            end
            
            if isempty (nan_place_LTG)==0;
            count_LTG=0;         
            for nan_i_LTG=nan_place_LTG;
            i_LTG=nan_i_LTG-count_LTG;
            y_LTG(i_LTG)=[];
            x_LTG(i_LTG)=[];
            count_LTG=count_LTG+1;
            end
            end
            
            if size(y_ctrl,2)>2 && size(y_LTG,2)>2            
            [f_ctrl,gof_ctrl]=fit(x_ctrl',y_ctrl','poly1');
            [f_LTG, gof_LTG]=fit(x_LTG',y_LTG','poly1'); 
            if gof_ctrl.adjrsquare>0.8 && gof_LTG.adjrsquare>0.8;
            count=count+1;
            a_ctrl=f_ctrl(2)-f_ctrl(1);
            a_LTG=f_LTG(2)-f_ctrl(1);
            
            angle_ctrl{1,cell}(count,1)=analysis_ctrl{1, cell}(1).laser_intensity(sweep,1);
            angle_ctrl{1,cell}(count,2)=atand(a_ctrl);
            angle_ctrl{1,cell}(count,3)=a_ctrl;
            angle_ctrl{1,cell}(count,4)=mn_SSI_ctrl{1, cell}{sweep,1}(1,1);
            angle_ctrl{1,cell}(count,5)=mn_SSI_ctrl{1, cell}{sweep,1}(1,size(mn_SSI_ctrl{1, cell}{sweep,1},2));
            
            angle_LTG{1,cell}(count,1)=analysis_LTG{1, cell}(1).laser_intensity(sweep,1);
            angle_LTG{1,cell}(count,2)=atand(a_LTG);
            angle_LTG{1,cell}(count,3)=a_LTG;
            angle_LTG{1,cell}(count,4)=mn_SSI_LTG{1, cell}{sweep,1}(1,1);
            angle_LTG{1,cell}(count,5)=mn_SSI_LTG{1, cell}{sweep,1}(1,size(mn_SSI_LTG{1, cell}{sweep,1},2));
            end
            end   
    end
    end
end

