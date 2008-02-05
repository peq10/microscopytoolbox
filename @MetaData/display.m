function display( md )
% display : dumps an xml representation of the MetaData md data structure
%       if an array, just reports the array size. 
%       display depands on the avaliability of the command line xmlpretty
%       tool, it't not there it spits an ugly uneadable xml.

if length(md)>1
    disp(sprintf('a MetaData array with %i elements',length(md)));
    return
end

str=get(md,'xml');

%% pretty it up (depends on xmlpretty - so its in a try-catch )
try
    fid=fopen('ugly.xml','w');
    fprintf(fid,get(md,'xml'));
    fclose(fid);
    !xmlpretty --PrettyWhiteNewline --PrettyWhiteIndent  ugly.xml 
    disp('     ');
catch
    disp('cannot use xmlpretty - showing ugly version')
    str=regexprep(str,'<Image>','\n<Image>');
    str=regexprep(str,'<DisplayOptions','\n<DisplayOptions');
    disp(str)
end