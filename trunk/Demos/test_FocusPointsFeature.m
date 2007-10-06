%% 
% check if we are in the Tests folder
if ~isempty(regexpi(pwd,'Tests')), cd .., end

% and that rS exist
keep rS

%% a script that test the FocusPoint feature in Roboscope

r=2;
c=2;
WellCenter=[get(rS,'x') get(rS,'y')];
DistanceBetweenImages=100;
Pos=createAcqPattern('grid',WellCenter,r,c,DistanceBetweenImages,zeros(r*c,1));

% do 4 autofocuses
for i=1:4, 
    set(rS,'x',Pos(i).X,'y',Pos(i).Y)
    autofocus(rS);
end

%%
plotFocalPlaneGrid(rS);
guessFocalPlane(rS,mean([Pos(:).X]),mean([Pos(:).Y]))