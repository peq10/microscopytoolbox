function plotRoute3D(rS)
%PLOTPLANNEDSCHEDULE Summary of this function goes here
%   Detailed explanation goes here

tb=getTasks(rS,'status','executed');
[X,Y,T]=get(tb,'stagex','stagey','planetime');
if iscell(X)
    xyt=sortrows([[X{:}]' [Y{:}]' ([T{:}]'-mean([T{:}]))*24*3600],3);
else
    xyt=[X Y 0];
end

clf
plot3(xyt(:,1),xyt(:,2),xyt(:,3),'.-'); 
grid on
axis([min(xyt(:,1))-10 max(xyt(:,1))+10 ...
      min(xyt(:,2))-10 max(xyt(:,2))+10 ...
      min(xyt(:,3))-10 max(xyt(:,3))+10]);