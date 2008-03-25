function display( Tsk )
% display : prints to screen some info about the task 
% This info is the task id, its function and the metadata xml 
n=numel(Tsk);
if n>1
    fprintf('An array with %g Tasks\n',n);
elseif n==0
    disp('Its an empty task!!!');
else
    fprintf('id: %g\n',get(Tsk,'id'));
    fprintf('fcn: %s\n',get(Tsk,'fcnstr'));
    fprintf('MetaData: %s\n',get(Tsk,'xml'));
end
