function md = concat( mdarray )
% concat : combines an array of metadata objects into a single one. 
%
% The concatanation will happen via these rules: 
%
% 1. The following fileds must be the same otherwise it will throw an error:
%    Filename, DimensionOrder, (any more?)
% 2. Collection is a merge of all collection attributes from the array. 
% 3. TimePoint will be concatenated
% 4. Array order will be sorted by AcqTime for the TimePoint. 
% 5. Each element in mdarray is first splited if necessary
% 6. Few Attributes will get by default the value of the last (by AcqTime)
%    MetaData: Everything to do with display, 
% 

% TODO: What should happen to Qdata on a merges? right now its getting the last one, I don't really like it

%% get the metadata out of the mdarray WHY WHAT IS THIS GOOD FOR? When I
%TODO find out where matlab polymorphism sucked and comments here....

% this is because OO programing in matlab is not perfect
% it doesn't do polymorphism properly
if ~strcmp(class(mdarray),'MetaData')
    mdarray=get(mdarray,'metadata');
    mdarray=[mdarray{:}];
end

%% be lazy, if there is nothing to do, return
if numel(mdarray)<=1
    md=mdarray;
    return
end

%% split the elements of mdarray if needed
newmdarray=[];
for i=1:numel(mdarray)
    newmdarray=[newmdarray split(mdarray(i))];
end

%% now check to see if  Filename / DimensionOrder are the same
[filenames,dimorder]=get(newmdarray,'filename','dimensionorder');
if numel(unique(filenames))~=1
    error('All MetaData elements to concatenate must have the same filename');
end
if numel(unique(dimorder))~=1
    error('All MetaData elements to concatenate must have the same dimension order');
end

%% Sort them by time
acqTime=get(newmdarray,'acqtime');
acqTime=[acqTime{:}];
[bla,ind]=sort(acqTime);
newmdarray=newmdarray(ind);

%% Create the concatenated one. 
md=mdarray(end); 
md.TimePoint=[newmdarray(:).TimePoint];


%% create a union list of collections and set it as the collection
collections=get(newmdarray,'collections');
collections=[collections{:}];
collections=unique(collections);

% set the last one collection attributes 
md=set(md,'collections',collections);
