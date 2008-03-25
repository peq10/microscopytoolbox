function Qdata=getQdata(md,QdataType,TimePointIdx)
% getQdata : returns a subsets of a Qdata Values (or labels) based on their type
%   

%TODO: implement getQdata

if ~exist('TimePointIdx','var')
    TimePointIdx=0;
end

Qdata=get(md,'qdata');
Qdata=Qdata(strcmp(QdataType,{Qdata.QdataType}));
