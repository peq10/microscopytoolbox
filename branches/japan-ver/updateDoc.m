function prop=updateDoc
% updateDoc - parses all the m-files and creates the html documentaion in
% the doc folder. 
%
% the function reads all the source code and create the documentation from existings
% comments. To create good documentation mostly follow the matlab
% commenting rules for functions. Only exception is the object properties
% that are extracted from the class get method. Write the properties
% documentation as a long line in the get method. 

%% add m2html to the path if necessary
if ~exist('m2html.m','file')
    addpath([pwd filesep 'ThirdParty' filesep 'utilities' filesep 'm2html']);
end

%% create the html docs
% m2html('mFiles','.',...
%        'recursive','on',...
%        'htmlDir','doc',...
%        'todo','on',...
%        'source','off',...
%        'graph','on',...
%        'index','menu',...
%        'template','frame',...
%        'global','on',...
%        'ignoreddir', {'.svn' 'cvs','ThirdParty','oldCode','private'});

%% Create the properties documentation for each class

prop=getClassProperties('Scope');

end % updateDoc
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%  sub-functions 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function prop=getClassProperties(cls)
% private function that extracts the properties from the set/get methods 
%

% extract properties from files:
getProps=getPropsFromFile(['@' cls filesep 'get.m']);
setProps=getPropsFromFile(['@' cls filesep 'set.m']);

% make sure there are no properties in set that are missing from get
[bla, ia, ib] = intersect(getProps(:,1), setProps(:,1));

if ~isempty(setdiff(setProps(:,1),getProps(:,1)))
    error('''set'' has properties that ''get'' don''t - fix it in the source code!');
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

    function prop=getPropsFromFile(filename)
        [bla,L]=grep('case',filename); %#ok<SETNU,NASGU>
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
            prop{i,1}=regexprep(f,{'case','''',' ',},'');
            prop{i,2}=l;
        end
    end %nested subfunction getPropsFromFile

end %getClassProperties

