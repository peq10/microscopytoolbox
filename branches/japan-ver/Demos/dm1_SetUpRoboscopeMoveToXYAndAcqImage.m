%%  Basic "command line" usage
% This demos show how to init the Roboscope and perform basic operation
% directly with the rS object. These operation could be performed from the
% command line. This basic functionality doesn't use the more advanced Task
% based scheduling but by itself is very useful (you can loop and do
% whatever you want :)

%% Initilize the Scope
% the scope configuration file that will be passed to MicroManager. In this
% example we are using the Demo init file Roboscope_demo.cfg. 

clear all
close all 
ScopeConfigFileName='Demos/Roboscope_demo.cfg';

% call the constractor of the Scope 
global rS; % name of the scope (rS=roboScope)
rS=Scope(ScopeConfigFileName);

% Custom Roboscope configuration
set(rS,'rootfolder',[pwd filesep 'Demos' filesep 'Junk'],...
       'refreshschedule',10);

disp('Scope initialized');

%% Query the x,y position
[x,y]=get(rS,'x','y');

%% Move the stage 144 um in diagonal
set(rS,'x',x+100,'y',y+100);

%% Acquire an image in single channel
img=acqImg(rS,'FITC',100);
imshow(img,[])

%% Close gracefully
unload(rS)
