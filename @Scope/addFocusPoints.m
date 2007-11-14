function addFocusPoints( rSin,x,y,z,t )
%ADDFOCUSPOINTS add points to the rS.FocusPoints and delete old ones

global rS;
rS=rSin;

% if FocusPoint is empty, just add point
if isempty(rS.FocusPoints)
    rS.FocusPoints=[x y z t ones(size(x))];
    return
end

% Find the indexes of point I want to get rid of points 
% (e.g. are closer then rS.FocusPointProximity and 
%  were taken more than rS.FocuPointHistory seconds ago)
curr_xy=rS.FocusPoints(:,1:2)';
D=distance(curr_xy,[x; y]);
T=(t-rS.FocusPoints(:,4))*3600*24;
ix=find((D>rS.FocusPointProximity)+(T<rS.FocusPointHistory)); 
rS.FocusPoints(ix,5)=0; %#ok<FNDSB>

% add current point
rS.FocusPoints=[rS.FocusPoints; x y z t ones(size(x))];
