function prop=getClassAttributes(cls)
% Extracts the attributes (aka properties) from the set/get methods 
%

% extract properties from files:
getProps=getPropsFromFile([cls filesep 'get.m']);
setProps=getPropsFromFile([cls filesep 'set.m']);

% make sure there are no properties in set that are missing from get
[bla, ia, ib] = intersect(getProps(:,1), setProps(:,1));

if ~isempty(setdiff(setProps(:,1),getProps(:,1)))
    warning('''set'' has properties that ''get'' don''t - fix it in the source code!'); %#ok<WNTAG>
    disp(setdiff(setProps(:,1),getProps(:,1)))
    input('press any key')
    prop=[];
    return
end

% create the struct array  - first for all the read/write ones 
for j=1:length(ia)
    prop(j).name=getProps{ia(j),1};
    prop(j).cmt=getProps{ia(j),2};
    prop(j).input=setProps{ib(j),2};
end
n=j;

ireadonly=setdiff(1:size(getProps,1),ia);
for j=1:length(ireadonly)
    prop(n+j).name=getProps{ireadonly(j),1};
    prop(n+j).cmt=getProps{ireadonly(j),2};
    prop(n+j).input='READONLY';
end

% sort if alphabetically
[bla,ind]=sort({prop.name});
prop=prop(ind);
    
function prop=getPropsFromFile(filename)

% check input
if ~exist(filename,'file')
    prop={'none','place holder'};
    return
end
% used to actually extract the prperties from a giver set/get file
[bla,L]=grep('-s','case',filename); %#ok<SETNU,NASGU>
for i=1:length(L.match)
    ln=regexprep(L.match{i},char(13),'');
    delIx=strfind(ln,'%');
    if ~isempty(delIx)
        f=ln(1:delIx-1);
        l=ln(delIx+1:end);
    else
        f=ln;
        l='';
    end
    f=regexprep(f,{'case','''',' ','{','}'},'');
    prop{i,1}=regexprep(f,',',' , ');
    prop{i,2}=l;
end