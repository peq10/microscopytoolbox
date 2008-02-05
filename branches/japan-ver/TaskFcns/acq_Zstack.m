function Tsk=acq_Zstack(Tsk) 
% snaps a Z-stack at a site

global rS; % give access to the Scope functionality 

%% get the current acq details 
[Z,X,Y,Exposure,Channels]=get(Tsk,'stageZ',...
                                'stageX',...
                                'stageY',...
                                'exposuretime',...
                                'Channels');

%% goto XYZ
set(rS,'xy',[X Y]);
disp(['at x,y : ' num2str(get(rS,'x')) ',' num2str(get(rS,'x'))]);

%% snap stack
curZ=get(rS,'z');
realZ=zeros(size(Z));
for i=1:length(Z)
    set(rS,'z',curZ+Z(i));
    img(:,:,:,i)=acqImg(rS,Channels,Exposure);
    realZ(i)=get(rS,'z');
end

%% find out what dimension order the user wanted and reshape
ordr=get(Tsk,'dimensionorder');
Zind=strfind(ordr,'Z');
Cind=strfind(ordr,'C');
Tind=strfind(ordr,'T');
img=permute(img,[1 2 Cind Zind Tind]);

%% check if spawning is needed
if get(Tsk,'spawn_flag')
    spawned=spawn(Tsk);
    Tsk=set(Tsk,'spawn_happened',spawned);
end

%% update Task metadata 
% everything goes to default beside Z which is the realZ that was taken on
% the stack. 
Tsk=updateMetaData(Tsk,'stagez',realZ);

%% Write to disk
if get(Tsk,'writeImageToFile')
    writeTiff(Tsk,img,get(rS,'rootfolder'));
end

%% plot 
if get(Tsk,'plotDuringTask')
    plotAll(rS);
end



