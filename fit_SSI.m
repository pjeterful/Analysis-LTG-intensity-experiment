% This function calculates the the angles of the fitted increase of the
% stimulus spike intervals (SSI) compared to the x-axis, for control and 
% LTG conditions. inputs are analysis structsfor control and LTG
% conditions. Outputs are angle structs for control and LTG condition, with
% the laser intensities in the 1th collumn, the average increase per stimulus pulse
% in the 2th collumn, the angle of this increase in the 3th collumn, and
% the SSI's of the first and last stimulus pulse in the 4th and 5th collumn
%, respectively. Last eddit PAS (20-11-2016)
function [angle_ctrl, angle_LTG]=fit_SSI(analysis_ctrl, analysis_LTG)
nr_cells=size(analysis_ctrl,2);
% For each cell
for cell =1:nr_cells;
    % start a new count for every cell
    count=0;
    for sweep=1:size(analysis_ctrl{1, cell}(1).laser_intensity  , 1) ;
        % Determine the stimsize
        stimsize=size(analysis_ctrl{1, 2}(1).succes_rate,1);
        % Create a vector, x , of 1 to the size of the stimulus train with
        % incremental steps of 1
        x=[1:stimsize ];
        % Calculate the mean SSI per stimulus pulse.
        mn_SSI_ctrl{1, cell}{sweep,1}=mean(analysis_ctrl{1, cell}(sweep).SSI,2)'; 
        mn_SSI_LTG{1, cell}{sweep,1}=mean(analysis_LTG{1, cell}(sweep).SSI,2)'; 
        
        % If your inclusion criterium is that a certain percentage of the
        % stimulus pulses needs to evoke a spike, use the line below and
        % replace o.5 with whatever part you prefere. Otherwise, use
        % halfstime=2, because a fit needs at least to data points.
%       halfstim=ceil(stimsize*0.5);
%       halfstim=2;
%       if isempty(find(isnan(mn_SSI_LTG{1, cell}{sweep,1}(1,1:halfstim))))==1 && ...
%       isempty(find(isnan(mn_SSI_ctrl{1, cell}{sweep,1}(1,1:halfstim))))==1;
%           nanplace=[];
%           nanplace_LTG=find(isnan(mn_SSI_LTG{1, cell}{sweep,1}),1);
%           nanplace_ctrl=find(isnan(mn_SSI_ctrl{1, cell}{sweep,1}),1);
%           nanplace=vertcat(nanplace_ctrl, nanplace_LTG);
%           place=min(nanplace)-1;
%               if isempty(place);
%                   place=stimsize;
%               end
            % create collumns of the mean SSI's of control and LTG
            % conditions
            y_ctrl=mn_SSI_ctrl{1, cell}{sweep,1}(1,:);
            y_LTG=mn_SSI_LTG{1, cell}{sweep,1}(1,:);
            % Use the find function to locate the indices of the stimulus pulses with 
            % no firing responses, which contain NaN's
            nan_place_ctrl=find(isnan(y_ctrl));
            nan_place_LTG=find(isnan(y_LTG));
            x_ctrl=x;
            x_LTG=x;
            
            % If nan_place_ctrl is not empty, so the SSI vector contains
            % NaN's, replace these indices in the x_ctrl vector with empty
            if isempty (nan_place_ctrl)==0
                % Count each time this precess is looped and suptract this 
                % from the current indice that replaces x_ctrl and y_control
                % with empty. Because each time a NaN is replaced with
                % [], the rest of the succesive indices decrease by one.
                count_ctrl=0;       
                % Replace all NaN in the y_ctrl and c_ctrl by [].
                for nan_i_ctrl=nan_place_ctrl;
                    i_ctrl=nan_i_ctrl-count_ctrl;
                    y_ctrl(i_ctrl)=[];
                    x_ctrl(i_ctrl)=[];
                    count_ctrl=count_ctrl+1;
                end
            end
            
            % Do the same for LTG condition
            if isempty (nan_place_LTG)==0;
                count_LTG=0;         
                for nan_i_LTG=nan_place_LTG;
                    i_LTG=nan_i_LTG-count_LTG;
                    y_LTG(i_LTG)=[];
                    x_LTG(i_LTG)=[];
                    count_LTG=count_LTG+1;
                end
            end
            % Both y_ctrl and y_LTG need to contain at least 3 values,
            % otherwise vecors containing only two would have a perfect
            % fit.
            if size(y_ctrl,2) > 2 && size(y_LTG,2) > 2;    
                % Fit the datapoints from the current intensity (sweep) in
                % a linear regression model 'poly1' for both control and
                % LTG conditions.
                [f_ctrl,gof_ctrl]=fit(x_ctrl',y_ctrl','poly1');
                [f_LTG, gof_LTG]=fit(x_LTG',y_LTG','poly1'); 
                % Only include fits that are considered 'good', having a
                % degree of freedom adjusted R squarred > 0.8.
            if gof_ctrl.adjrsquare>0.8 && gof_LTG.adjrsquare>0.8;
                % add one to the count for every good fit, the count
                % determines the indices for each good fitted trace of
                % SSI's
                count=count+1;
                % Determine how many ms the fitted SSI increases with each 
                % consecutive  stimulus pulse (a_ctrl, a_LTG), from this 
                % value the angle can be calculated.
                a_ctrl=f_ctrl(2)-f_ctrl(1);
                a_LTG=f_LTG(2)-f_ctrl(1);
                
                % Put everything in a struct.
                % The laser intensity
                angle_ctrl{1,cell}(count,1)=analysis_ctrl{1, cell}(1).laser_intensity(sweep,1);
                % The angle, calculated by the inverse tanges of a_ctrl
                % devided by the the x increase (1).
                angle_ctrl{1,cell}(count,2)=atand(a_ctrl);
                % The increase
                angle_ctrl{1,cell}(count,3)=a_ctrl;
                % The mean first SSI 
                angle_ctrl{1,cell}(count,4)=mn_SSI_ctrl{1, cell}{sweep,1}(1,1);
                % The mean last SSI
                angle_ctrl{1,cell}(count,5)=mn_SSI_ctrl{1, cell}{sweep,1}(1,size(mn_SSI_ctrl{1, cell}{sweep,1},2));
                
                %The same for LTG
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

