function md = merge( mdarray )
%MERGE md = merge( mdarray )merges a set of MetaData objects into one - ON THE TIME DOMAIN. 
% Its important which is the last one in the array since this is the one
% that most of the properties are going to be set by (e.g. display etc.)

%% if mdarry is not an array return itseld
if numel(mdarray)<=1
    md=mdarray;
    return
end

%% The first element in mdarray is allowed to be multi-timed point 
% so split it first before merging
if numel(get(mdarray(1),'planetime'))>1
    mdarray=[split(mdarray(1)); mdarray(2:end)];
end

%% get the metadata out of the mdarray (OO programing in matlab is not perfect...)
if ~strcmp(class(mdarray),'MetaData')
    mdarray=get(mdarray,'metadata');
    mdarray=[mdarray{:}];
end

%% First check that Collection data and filename and the 

mdstruct=struct(mdarray);
for i=1:length(mdstruct),
    str{i}=struct2xml(mdstruct(i).CollectionData);
end

cnt=ones(1,3);
for i=2:length(mdstruct)
    cnt(1)=cnt(1)+double(strcmp(str{1},str{i}));
    cnt(2)=cnt(2)+double(strcmp(mdstruct(1).Image.ImageFileName,mdstruct(i).Image.ImageFileName));
    cnt(3)=cnt(3)+double(isempty(setxor({mdstruct(1).Image.Qdata(:).QdataType},...
                                        {mdstruct(i).Image.Qdata(:).QdataType})));
end

if cnt(1)~=length(mdstruct), 
    error('Cannot merge metadata object that differ in their collection data'); 
end

if cnt(2)~=length(mdstruct), 
    error('Cannot merge metadata object that have different file names'); 
end

if cnt(3)~=length(mdstruct), 
    error('Cannot merge metadata object that have different qdata field types'); 
end


%% calculate the new Plane Data (stagex,stagey, etc.)
sz=get(mdarray,'dimensionsize');
sz=reshape([sz{:}]',3,length(mdarray))';

switch get(mdarray(1),'dimensionorder')
    case {'XYCZT','XYZCT'}
        sz=[sz(1,1) sz(1,2) sum(sz(:,3))];
    case {'XYCTZ','XYZTC'}
        sz=[sz(1,1) sum(sz(:,2)) sz(1,3)];
    case {'XYTCZ','XYTZC'}
        sz=[sum(sz(:,1)) sz(1,2) sz(1,3)];
end

stagex=nan(sz);
stagey=nan(sz);
stagez=nan(sz);
planetime=nan(sz);
exposuretime=nan(sz);
binning=nan(sz);
cnt=1;
for i=1:sz(1)
    for j=1:sz(2)
        for k=1:sz(3)
            [stagex(i,j,k),...
            stagey(i,j,k),...
            stagez(i,j,k),...
            planetime(i,j,k),...
            exposuretime(i,j,k),...
            binning(i,j,k)]=get(mdarray(cnt),'stagex','stagey','stagez','planetime',...
                                             'exposuretime','binning');
            cnt=cnt+1;
        end
    end
end


%% create the qdata - do a few cell .struct etc transformation 
qnum=length(get(mdarray(1),'qdata'));
qcell=get(mdarray,'qdata');
qarr=reshape([qcell{:}]',qnum,length(mdarray))';
for i=1:qnum
    Value{i}=arr2str([qarr(:,i).Value]);
end
QdataType={qcell{1}.QdataType};
QdataDescription={qcell{1}.QdataDescription};
qdata=struct('QdataType',QdataType,'Value',Value,'QdataDescription',QdataDescription);

%% create the md based on the last md in the array
md=mdarray(end);

md=set(md,'creationdate',datestr(now),...
          'dimensionsize',sz,...
          'stagex',stagex,...
          'stagey',stagey,...
          'stagez',stagez,...
          'planetime',planetime,...
          'exposuretime',exposuretime,...
          'binning',binning,...
          'qdata',qdata);
            