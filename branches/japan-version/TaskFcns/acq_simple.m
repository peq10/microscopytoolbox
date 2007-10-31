function acq_simple(Tsk) 
%SIMPLEACQ callback function to be used by by AcqSeq objects
%   
% Outline: 
% 1. get the current number in the sequence
% 2. goto the right xyz position, 
% 3. autofocus
% 4. expose & snap an image
% 5. save to disk

global rS;

%% get the crnt acq details 
[X,Y,Z,Exposure,Channels,Binning]=get(Tsk,'stageX',...
                                          'stageY',...
                                          'stageZ',...
                                          'exposuretime',...
                                          'ChannelNames',...
                                          'Binning');
%% goto XYZ
set(rS,'xy',[X Y],'z',Z);
figure(1)
plot(X,Y,'or');
%% autofocus
autofocus(rS);
z=get(rS,'z');
z=z+get(Tsk,'zshift');
set(rS,'z',z);

%% update Tsk object so the value I write to disk are actual not theoretical
FcsScr.QdataType='FocusScore';
FcsScr.Value=get(rS,'focusscore');
FcsScr.QdataDescription='';

Tsk=set(Tsk,'planetime',now,...
            'stagex',get(rS,'x'),...
            'stagey',get(rS,'y'),...
            'stagez',get(rS,'z'),...
            'qdata',FcsScr);

        
replaceTasks(rS,Tsk);

%% snap images
img=acqImg(rS,Channels,Exposure);

%% set Task to executed and update rS
replaceTasks(rS,set(Tsk,'executed',true));

%% Write image to disk
writeTiff(Tsk,img,get(rS,'rootfolder')); 

%% show image
% showImg(Tsk,img(:,:,1),2)
