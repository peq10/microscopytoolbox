function order=acotsp(schdle_data)
% a scheduling function based on Ant Colony Optimization
% for solving Traveler Salesperson Problem
% It totaly ignores the times, just return the task in an optimal order
% based on their distnaces

%% parse inputs
x=schdle_data.x;
y=schdle_data.y;
id=schdle_data.id;
x_current=schdle_data.xCurrent;
y_current=schdle_data.yCurrent;

%%

if range(x)+range(y)==0
    order=id;
    return
end

%% create a .tsp file
fid=fopen('Tasks.tsp','w');
fprintf(fid,'NAME : Tasks\n');
fprintf(fid,'COMMENT : Imaging positions\n');
fprintf(fid,'TYPE : TSP\n');
fprintf(fid,'DIMENSION : %g\n',length(id));
fprintf(fid,'EDGE_WEIGHT_TYPE : EUC_2D\n');
fprintf(fid,'NODE_COORD_SECTION\n');
for i=1:length(x), fprintf(fid,'%g %g %g\n',i,x(i),y(i)); end
fprintf(fid,'EOF\n');
fclose(fid);

% run ACOTSP
cmd=sprintf('acotsp -i Tasks.tsp -r 1 -t 3 -g %i > acotsp.log',min(length(id),20));
if isunix
    cmd=['./' cmd];
end
msg=system(cmd); %#ok<NASGU>
if msg==0
    tr = dlmread('Tour.txt');
    tr=tr(1:length(x));
    tr=tr+1;
else
    warning('Scheduling failed!!!!! no idea why... ')
%     keyboard
    tr=1:length(x);
end

% rotate points on the circle such that the closest Task is first
[bla,cls_id]=min(sqrt((x(tr)-x_current).^2+(y(tr)-y_current).^2)); %#ok
tr_srt=tr([cls_id:length(id) 1:cls_id-1]);
id_srt=id(tr_srt);

% inter task distance - used for time calculation below.
dx=sqrt((x(2:length(id_srt))-x(1:length(id_srt)-1)).^2+(y(2:length(id_srt))-y(1:length(id_srt)-1)));

% build the schedule object - assigns times for tasks
order=id_srt;