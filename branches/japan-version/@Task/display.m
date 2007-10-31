function display( Tsk )
% DISPLAY method for Task class
n=numel(Tsk);
if n>1
    fprintf('An array with %g Tasks\n',n);
elseif n==0
    disp('Its an empty task!!!');
else
    fprintf('id: %g\n',get(Tsk,'id'));
    fprintf('fcn: %s\n',func2str(Tsk.fcn));
    fprintf('MetaData: %s\n',get(Tsk,'xml'));
end
