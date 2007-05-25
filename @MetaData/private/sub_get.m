function s=sub_get(xml,node,atr)
% private function to make life easier


%% input validation
error(nargchk(2,3,nargin))

% If node is a char, turn it to a uid
if ischar(node)
    node=find(xml,node);
    if isempty(node)
        s=[];
        return
    end
end

if isreal(node) && min(node) >= 1 && max(node) <= length(xml)
    uid=node;
else
    error(['node is not valid, uid: ' num2str(uid)])
end

if length(uid)>1
    for i=1:length(uid)
        if exist('atr','var'),
            s{i}=sub_get(xml,uid(i),atr); 
        else
            s{i}=sub_get(xml,uid(i)); 
        end
    end
    return
end
% 
% % allow the option to get the entire struct
% if nargin==2
%     s=get(xml,uid);
%     return
% end

% check to see if its a calue or attribute requested
if exist('atr','var') && strcmp(atr,'value')
    uid=children(xml,uid);
end

% get the node struct from the xmltree portion of the object
node=get(xml,uid);

%% return attributes or value depends on node type

switch node.type
    case 'element'
        s=[];
        AllAtr=node.attributes;
        fld={};
        for i=1:length(AllAtr)
            %strip any "bad" char fXMLTreerom key
            fld{i} = regexprep(AllAtr{i}.key, ':', '_');
            %add to struct
            s.(fld{i})=AllAtr{i}.val;
        end
        if exist('atr','var'),
            %check to see that the attribute exist
            if ismember(atr,fld), s=s.(atr);
            elseif strcmp(atr,'type'), s=node.type;
            elseif strcmp(atr,'name'),s=node.name;
            else, s=[]; warning(['attribute ' atr ' does not exist'])
            end
        end
    case 'chardata'
        s=node.value;
    case 'comment'
        s=node.value;
    otherwise
        warning('no support for cdata or pi xml node types')
        s=[];
end
