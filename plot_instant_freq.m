
for sweep=1:size(analysis_2,2);
   repeat=1;
x=analysis{1, sweep}.instant_freq{1, repeat}(:,2);
y=analysis{1, sweep}.instant_freq{1, repeat}(:,1);
e=(std(y)/sqrt(size(x,1))*ones(size(x)));
subplot((size(analysis_2,2)),1,sweep);
    hold on
errorbar(x,y,e)
    end
   hold off
