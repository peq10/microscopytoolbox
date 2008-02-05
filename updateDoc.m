function updateDoc(withDemos)
% updateDoc - parses all the m-files and creates the html documentaion 
% in the doc folder. 
%
% the function reads all the source code and create the documentation from existings
% comments. To create good documentation mostly follow the matlab
% commenting rules for functions. Only exception is the object properties
% that are extracted from the class get/set method. Write the properties
% description as a long line in the get method and any comments about input
% values in the set properties.
%
% Task functions are evaluated using publish rather then m2html to show
% source code and use the cell array to document in more details these
% functions. 
%
% If withDemos == all demos in the Demos folder will be evaluates and a
% list of existing demos will be added to the documentation. 

%% add m2html to the path if necessary
if ~exist('m2html.m','file')
    addpath([pwd filesep 'ThirdParty' filesep 'utilities' filesep 'm2html']);
    addpath([pwd filesep 'ThirdParty' filesep 'utilities']);
end

%% check if need to create Demos

if ~exist('withDemos','var')
    withDemos=false;
end
if ischar(withDemos)
    withDemos=true;
end


% if needed create the demos HTML files
if withDemos
    opt.outputDir=[pwd filesep 'doc' filesep 'Demos'];
    dm=dir(['Demos' filesep 'dm*.m']);
    for i=1:length(dm)
        publish(['Demos' filesep dm(i).name],opt)
    end
end
%% create the html docs

m2html('mFiles','.',...
       'recursive','on',...
       'htmlDir','doc',...
       'todo','on',...
       'source','off',...
       'graph','on',...
       'index','menu',...
       'template','frame',...
       'global','on',...
       'ignoreddir', {'.svn','cvs','ThirdParty','oldCode',...
                      'private','ImageAnalysis','html',...
                      'Users','Demos'},...
       'demos',withDemos);
   
%% redo all TaskFcns with publish
                  
opt.outputDir=[pwd filesep 'doc' filesep 'TaskFcns'];
opt.evalCode=false;
tskfiles=dir(['TaskFcns' filesep '*.m']);
for i=1:length(tskfiles)
    disp(['replacing ' tskfiles(i).name]);
    publish(['TaskFcns' filesep tskfiles(i).name],opt);
end





