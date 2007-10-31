function order = external_file(x,y,t,id,x_current,y_current,tasks_duration,t_current)
% External_File - provide an external file with task id order

uigetfile('*.csv','Please choose the task order file')