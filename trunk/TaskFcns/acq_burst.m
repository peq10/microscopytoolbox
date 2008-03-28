function Tsk=acq_burst(Tsk) 
% a very simple task that just starts a very rapid burst mode
% thats it...

global rS; % give access to the Scope functionality 

%% get the crnt acq details 
UserData=get(Tsk,'UserData');
imgNumInBurst=UserData.imgNumInBurst;

%% burst acquisition
Tsk=acqBurstMode(rS,imgNumInBurst,Tsk);

