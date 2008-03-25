function md=addQdata(md,varargin)
% addQdata : returns a subsets of a Qdata Values (or labels) based on their type
%    add a specific qdata Type / value pair to the Qdata struct. This is
%    achived using set/get and basiclaly meant to save the programmer user
%    some effort...


%% default values
% if the qdata to enter is for a specific timepoint that TimePointIdx
% should be the index (indexes) for those timepoint (s). Otherwise it is
% zero

TimePointIdx=0;
QdataType='';
QdataValue=[];
QdataLabel='';
QdataDescription='';


%% parse inputs
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'type'
            s.QdataType=varargin{i+1};
        case 'value'
            s.Value=varargin{i+1};
        case 'description'
            s.QdataDescription=varargin{i+1};
        case 'label'
            s.Label=varargin{i+1};
        case 'timepointidx'
            TimePointIdx=varargin{i+1};
        otherwise
    end
end

%% deal with the possibility of md being an array
if numel(md)>1
    for i=1:length(md)
        md(i)=addQdata(md(i),'type',s.QdataType,...
                             'value',s.QdataValue,...
                             'description',s.QdataDescription,...
                             'label',s.QdataLabel,...
                             'timepointidx',TimePointIdx);
    end
    return
end

%% add to the main qdata if its not a time point Qdata
if ~TimePointIdx
    q=get(md,'qdata');
    qesxt=unique({q(:).QdataType});
    if isempty(q) || isempty(qesxt{1})
        q=s;
    else
        q=[q(:); s];
    end
    md=set(md,'qdata',q);
    return
end

%% deal with the possibility of timed qdata

%TODO: add TimePointIdx capablities to addQdata
error('Currently TimePointIdx isn''t supported');


