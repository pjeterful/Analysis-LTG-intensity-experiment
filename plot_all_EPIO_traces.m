figure(1)
for sweep=1:10;
    subplot(10,1,sweep);
    plot(analysis_ctrl_shaffer{1, 2}(sweep).time_EPIO, analysis_ctrl_shaffer{1, 2}(sweep).trace_EPIO, 'k');
    axis([ 0 1000 -100 100]);
end 
    figure(2)
for sweep=1:10;
    subplot(10,1,sweep);
    plot(analysis_LTG_shaffer{1, 2}(sweep).time_EPIO, analysis_LTG_shaffer{1, 2}(sweep).trace_EPIO, 'r');
    axis([ 0 1000 -100 100]); 
end
