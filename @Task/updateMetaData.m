function Tsk = updateMetaData(Tsk,varargin)
% updateMetaData  : updates multiple Scope state related metadata fields
%   First, it quries rS and updates many Tsk metadata attributes based on the
%   results of the get(rS,...) queries. 
%   Second, it will use any additional input (attribute / value) pairs 
%   to change attributes from the defaults single site single plange setup.
%   
%   example: 
%             Tsk = updateMetaData(Tsk);
%             Tsk = updateMetaData(Tsk,'stagez',Z,'binning',Bin)
%
%   Note: 
%   This works only on single timepoint Tasks (which, if you used split 
%   should be the state anyway when you want to update...). 
%

tpn=get(Tsk,'timepointnum');
if tpn~=1
    warning('Cannot update MetaData attributes of a timelapse task, use SPLIT first, update and CONCAT');
    return
end


%% set up defualts based on current state
global rS;

Tsk=set(Tsk,'acqtime',now,... % time the image was taken
            'stagex',get(rS,'x'),... % real position (xyz)
            'stagey',get(rS,'y'),...
            'stagez',get(rS,'z'),...
            'imgheight',get(rS,'height'),... % image properties
            'imgwidth',get(rS,'width'),...
            'bitdepth',get(rS,'bitdepth'));
        
%% revise / update attributes based on user input

if mod(length(varargin),2)
    error('updateMetaData user input must be in PAIRS');
end

        
for i=1:2:length(varargin)
    Tsk=set(Tsk,varargin{i},varargin{i+1});
end

%% Perform some "trigger" updates, 
% There are a few attributes that are related, e.g. dimensionsize etc in
% this section we update these attributes based on what we know of Tsk. 

%get some attributes related to dimensionsize
[ordr,sz,z,chnls]=get(Tsk,'dimensionorder','dimensionsize','stagez','channels');
Tind=strfind(ordr,'T')-2;
Zind=strfind(ordr,'Z')-2;
Cind=strfind(ordr,'C')-2;

if iscell(z)
    zn=zeros(numel(z),1);
    for i=1:size(zn,1)
        zn(i)=size(z{i},1);
    end
else
    zn=size(z,1);
end

sz(Tind)=1;
sz(Zind)=max(zn);
sz(Cind)=length(chnls);


%% set Tsk with those "trigger" values
Tsk=set(Tsk,'dimensionsize',sz);
