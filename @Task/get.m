function varargout = get( Tsk,varargin )
%GET Summary of this function goes here
%   Detailed explanation goes here

global rS;

if isempty(Tsk)
    varargout=cell(size(varargin));
    return
end

%% check to see if Tsk is an array, if so run foreach element seperatly.
% this chunk is a big ugly, could flip the loop and avoid the second loop,
% but who cares...
if length(Tsk)>1
    varargout={};
    s=cell(length(Tsk),length(varargin));
    for i=1:length(Tsk)
        for j=1:length(varargin)
            s{i,j}=get(Tsk(i),varargin{j});
        end
    end
    for j=1:length(varargin)
        varargout=[varargout {s(:,j)}]; %#ok<AGROW>
    end
    return
end

%% load the list of MetaDataAttributes from file
persistent MetaDataAttributes;
if isempty(MetaDataAttributes)
    MetaDataAttributes=textread(['@Task' filesep 'MetaDataAttributes'], '%s');
end
%% get whatever is asked for a single Tsk ...
varargout=cell(length(varargin),1);

for i=1:length(varargin)
    switch lower(varargin{i})
        case 'metadata'
            varargout{i}=Tsk.MetaData;
        case 'latebehavior'
            varargout{i}=Tsk.LateBehavior;
        case 'id'
            varargout{i}=Tsk.id;
        case 'fcn'
            varargout{i}=Tsk.fcn;
        case 'timedependent'
            varargout{i}=Tsk.timedep;
        case 'duration'
            ExpTime=get(Tsk(1),'Exposuretime');
            % duration has three components (all converted to days units): 
            % 1. Exposure time + 100 ms per channel for overhead 
            Tsk.acqTime=(sum(ExpTime)+length(ExpTime)*200)* length(get(Tsk,'stagez'))/1000/3600/24;
            % 2. Focus time is based on stage 0.6 mm/sec max velocity
            Tsk.focusTime=0.1/3600/24; %in days units!!!
            % 3. 1 seconds overehad for movement (on average)
            varargout{i}=Tsk.acqTime+Tsk.focusTime+1/3600/24;
        case 'userdata'
            varargout{i}=Tsk.UserData;
        case 'executed'
            varargout{i}=Tsk.executed;
        case 'zshift'
            varargout{i}=Tsk.Zshift;
        case MetaDataAttributes %deligates the attributes to the MetaData class
            varargout{i}=get(Tsk.MetaData,varargin{i});
        otherwise
            error('Throopi:Property:get:Task',['property: ' varargin{i} ' does not exist in Task class']);
    end
end
            