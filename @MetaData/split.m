function mdarray = split( md )
% split : breaks up a timelapse metadata into an array of single timepoints 
%    It is working directly on the struct data and not on using set/get so it will 
%    need to be update if there is an internal change in data
%    representation
%    

%% split the TimePont array struct into components 
% everything else remain the same 

n=get(md,'timepointnum'); 
for i=1:n
    mdarray(i)=md;
    mdarray(i).TimePoint=md.TimePoint(i); 
end
