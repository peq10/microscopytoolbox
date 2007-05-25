function [xml,val_found] = sub_keep(xml,pth_to_node,key,val)
%SUB_KEEP for entries that can have multiple possibilities, keep only one. 
%
% Usage: 
% node -  a char description of a node
% key   -  the attribute to distinguish by
% val    -  the value to keep. 

if ~exist('val','var') % to delete all nodes, supply empty/no val
    val=[]; 
end

uid=find(xml,pth_to_node);
if ~isempty(uid)
    vals=sub_get(xml,uid,key);
else
    vals=[];
end

% check to see that we're left with an non enpty set
if sum(~ismember(vals,val))<1 && isempty(val)
    val_found=0;
else
    val_found=1;
end

xml=delete(xml,uid(~ismember(vals,val)));
