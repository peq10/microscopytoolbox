function tm = calcMoveTime(rS,xy,xy_org)
% calcMoveTime :  calculate the time needed for stage movement. 
% it returns the time it would take to move to position xy from xy_org
%
%    xy - an [x,y] point
%    xy_org - original position (defualts to get(rS,'xy'))
%    tm - time (in sec) in seconds it will take to move
%
%TODO: write this function... 

if ~exist('xy_org','var')
    xy_org=get(rS,'xy');
end

tm=1;
