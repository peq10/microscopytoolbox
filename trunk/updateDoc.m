function updateDoc(varargin)
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
% Additional input arguments (in pairs of property/value) are: 
%
% 'withDemos'   -   {true} / false
%                   Create a HTML page for each demo based on whats in doc/Demos  
% 'evalDemos'   -   true / {false}
%                   run the demos in publish mode?
% 'createmovies  -   true / {false}
%                    create movie from every figure, only work in
%                    evalDemos=true
% 'breakcellsindemos' - true / {false} 
%                       determine if in addition to the single html page 
%                       another single page / cell should be created as
%                       well. 
%
% If withDemos == all demos in the Demos folder will be evaluates and a
% list of existing demos will be added to the documentation. 

%% add m2html to the path if necessary
if ~exist('m2html.m','file')
    addpath([pwd filesep 'ThirdParty' filesep 'utilities' filesep 'm2html']);
    addpath([pwd filesep 'ThirdParty' filesep 'utilities']);
end

%% define all the default behaviors
s.withDemos=true;
s.evalDemos=false;
s.breakCellsInDemos=false;
s.createMoviesForDemos=false;

for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'withdemos'
            s.withDemos=logical(varargin{i+1});
        case 'breakcellsindemos'
            s.breakCellsInDemos=logical(varargin{i+1});
        case 'createmovies'
            s.createMoviesForDemos=logical(varargin{i+1});
        case 'evaldemos'
            s.evalDemos=logical(varargin{i+1});
        otherwise
            warning('Not a legit updateDoc option!'); 
    end
end         

if s.createMoviesForDemos
    setpref('roboscope','moviefolder','Demos/movies');
end

%% create the demos HTML files / movies (if needed eval the demos and)
if s.withDemos
    addpath Demos
    opt.outputDir=[pwd filesep 'doc' filesep 'Demos'];
    opt.evalCode=s.evalDemos;
    dm=dir(['Demos' filesep 'dm*.m']);
    for i=1:length(dm)
        if s.createMoviesForDemos && s.evalDemos
            !rm Demos/movies/*
        end
        % run the demo
        publish(['Demos' filesep dm(i).name],opt);
        if s.createMoviesForDemos && s.evalDemos
            dr=dir('Demos/movies/*.tiff');
            for j=1:length(dr)
                createMovie(dr(j).name,sprintf('doc/Demos/dm_%i_%i.avi',i,j));
            end
            !cp Demos/movies/*.avi doc/Demos/
        end
    end
end

% unset the preference to false for future calls
setpref('roboscope','moviefolder','');

% convert into multi-page html docs
% use grep to find all position of <h2> break the page into several cells
% 
if s.breakCellsInDemos && s.withDemos
    dr=dir('doc/Demos/dm*.html');
    for i=1:length(dr)
        breakFileToParts(fullfile('doc/Demos',dr(i).name));
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
       'demos',s.withDemos);
   
%% redo all TaskFcns with publish
                  
opt.outputDir=[pwd filesep 'doc' filesep 'TaskFcns'];
opt.evalCode=false;
tskfiles=dir(['TaskFcns' filesep '*.m']);
for i=1:length(tskfiles)
    disp(['replacing ' tskfiles(i).name]);
    publish(['TaskFcns' filesep tskfiles(i).name],opt);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Sub functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% create movie from multiplane tiff subfunction
function createMovie(tifffilename,avifilename)
f=imfinfo(tifffilename);
for i=1:length(f);
    M(i)=im2frame(imread(tifffilename,i));
end
movie2avi(M,avifilename)


%% create multiple files from a single html file
function breakFileToParts(filename)
%% read the whole file, each line is a cell
fid=fopen(filename);
cnt=1;
while 1
    tline = fgetl(fid);
    if ~ischar(tline),
        break,
    else
        C{cnt}=tline;
        cnt=cnt+1;
    end
end
fclose(fid);

%% fix the </pre> tags and move them to previous line
fnd=regexp(C,'^</pre><h2>', 'match', 'lineanchors');
for i=1:length(fnd)
    if ~isempty(fnd{i})
        C{i-1}=[C{i-1} '</pre>'];
    end
end
C=regexprep(C,'^</pre><h2>','<h2>');

%% create the first and last section fo each page
[bla,P]=grep('-s','<h1>',filename);
tail={'</div></body></html>'};
head=C(1:P.line-1);

%% find the indexes for middle sections
[FL,P]=grep('-s','<h2>',filename);
for i=1:length(P.line)
    if i==1
        Page{1}=[C(1:P.line(2)-1) tail];
    elseif i==length(P.line)
        Page{i}=[head C(P.line(end):end) tail];
    else
        Page{i}=[head C(P.line(i):P.line(i+1)-1)];
    end
end


%% create several new files
for i=1:length(Page)
    [pth,mdl,ext]=fileparts(filename);
    fid=fopen(fullfile(pth,'parts',[mdl '_' num2str(i) ext]),'w');
    for j=1:length(Page{i}),
        fprintf(fid,'%s\n',Page{i}{j});
    end
    fclose(fid);
end


