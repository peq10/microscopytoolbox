function F=getFocusCurve(dZ)
% GETFOCUSCURVE F=getFocusCurve(dZ)
% gets a vector of relative Z values (dZ) and returns the focus
% score at each location along the vecotr. 


global rS;

Zcur=get(rS,'z');
Z=Zcur+dZ;

for i=1:length(Z)
    set(rS,'z',Z(i));
    waitFor(rS,'stage');
    F(i)=get(rS,'focusscore');
    fprintf('%g,%g...',Z(i),F(i))
end
fprintf('\n');
set(rS,'z',Zcur);