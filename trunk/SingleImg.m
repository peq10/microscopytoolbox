%% Single image via a Task
Channels={'White','FITC','DAPI','Cy3'};
Exposure=[1 1000 1000 1000];
Binning=[2 2 2 2];
BaseFileName='Img';
id=1;

%%
set(rS,'rootFolder',pwd);
for i=1:length(Channels)
    chnls(i)=struct('Number',i,'ChannelName',Channels{i}, 'Content','Test');
end
Tsk=Task([],'acq_simple');
Tsk=set(Tsk,'channels',chnls,...
            'exposuretime',Exposure,...
            'binning',Binning,...
            'planetime',NaN,...
            'stagex',get(rS,'x'),...
            'stagez',get(rS,'z'),...
            'stagey',get(rS,'y'),...
            'id',id,...
            'filename',[BaseFileName '_' num2str(id)]);

%% Add & Run
set(rS,'schedulingmethod','asadded')
removeTasks(rS,'all');
addTasks(rS,Tsk);

%% do all Tasks
run(rS)