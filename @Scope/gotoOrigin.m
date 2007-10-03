function gotoOrigin(rS)
%GOTOORIGIN moves the xy stage to its origin and set it to be [0 0]

dx=1000; 
dy=1000;
fprintf('Moving stage to origin');
[x0,y0]=get(rS,'x','y');
while 1
    fprintf('.');
    x0=x0-dx;
    y0=y0-dy;
    set(rS,'xy',[x0 y0]);
    [x,y]=get(rS,'x','y');
    if abs(x-x0) > dx && abs(y-y0) > dy
        set(rS,'xy',[x0 y0]);
        waitFor(rS,'stage');
        rS.mmc.setOriginXY(rS.XYstageName);
        fprintf('done\n');
        return
    end
end