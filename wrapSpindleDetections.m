%% init
% clear
close all;
clc
t0=now;

%% get image filenames
pth='../ImageAnalysis/data/';
dr=dir([pth '*.tif']);

cells=[];

for i=1:length(dr)
    img=imread([pth dr(i).name]);
    [bla,bla,sml]=funcDetectSpindle(img,1);
    cells=[cells; sml(:)];ratio=[cells.ratio]';
    drawnow;
%     rslt=getframe;
%     imwrite(rslt.cdata,sprintf('tst/tst_%g.tiff',i));
    disp(sprintf('%g - %s',i,datestr(now-t0,13)));
end

%% save
ratio=[cells.ratio]';
scr=[cells.ScrSpindle]';
slength=[cells.spindlelength]';
gscr=[cells.ScrGrd]';
data=[ratio scr slength  gscr];
data=data-repmat([  0.5997    4.7916    7.2029    0.0170],size(data,1),1);
data=data./repmat([  0.1828    2.7130    0.6289    0.0063],size(data,1),1);

% 
% %%
% save TrainingSet