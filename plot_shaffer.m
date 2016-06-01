function gp=plot_shaffer(analysis, which_cells, which_IF_traces, which_EPIO_traces, which_IF_repeat)

for cell=[which_cells];
    repeat=which_IF_repeat;
    figure(cell);
    nr_sw=size(which_IF_traces,2);
    sweep_IF=which_IF_traces;
    sweep_EPIO=which_EPIO_traces;
    subplot(nr_sw*2,1,1);
    hold on
    plot(analysis{1,cell}(sweep_IF).time_IF, analysis{1,cell}(sweep_IF).trace_IF(:,repeat),'r')
    subplot(nr_sw*2,1,2);
    plot(analysis{1,cell}(sweep_EPIO).time_EPIO, analysis{1,cell}(sweep_EPIO).trace_EPIO,'b')
end