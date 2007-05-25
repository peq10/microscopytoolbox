function xml = sub_set(xml,uid,varargin)
% SET values/attributes to node 'node' 
% xml = set(xml,node,value) - to change value of leaf node
% xml = set(xml,node,keys,vals) - to change attributes of element node
%                                keys,vals are same length cell arrays
%
% node   - wither a uid (node number) or a path to node ('/OME/Projects')
% 

%% return attributes or value depends on node type
error(nargchk(3,4,nargin))

if ischar(uid), uid=find(xml,uid); end

if ~isreal(uid) || min(uid) < 1 || max(uid) > length(xml)
    error(['node is not valid, uid out of range: ' num2str(uid)])
end

node=get(xml,uid);

switch nargin
    case 3 %set the value of child
        uid=children(xml,uid);
        xml=set(xml,uid,'value',varargin{1});
    case 4 % set some attribute
        % do some checks, need to have 4 input arguments and the last two
        % must be cells, is they are not, wraps a cell around them.
        if ~iscell(varargin{1}), varargin{1}={varargin{1}}; end
        if ~iscell(varargin{2}), varargin{2}={varargin{2}}; end
        keys=varargin{1}; 
        vals=varargin{2};  
        if numel(keys)~=numel(vals), error('must have the same number of keys and values'); end
        
        % get the attribute structure 
        atr=sub_get(xml,uid);
        if isempty(atr)
            exist_keys={};
        else
            exist_keys=fieldnames(atr);
        end
        
        % add new keys (convert num -> str while at it...)
        [new_keys,ind]=setdiff(keys,exist_keys); %#ok
        for i=1:length(ind)
            if isa(vals{ind(i)},'numeric'), vals{ind(i)}=num2str(vals{ind(i)}); end
            xml=attributes(xml,'add',uid,keys{ind(i)},vals{ind(i)});
        end
            
        % update existing keys (convert num -> str while at it...)
        [bla,ordr,ind]=intersect(exist_keys,keys);  %#ok
        for i=1:length(ind)
            if isa(vals{ind(i)},'numeric'), vals{ind(i)}=num2str(vals{ind(i)}); end
            xml=attributes(xml,'set',uid,ordr(i),keys{ind(i)},vals{ind(i)});
        end
end



