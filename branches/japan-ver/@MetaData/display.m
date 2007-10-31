function display( md )
%DISPLAY Summary of this function goes here
%   Detailed explanation goes here

if length(md)>1
    disp(sprintf('a MetaData array with %i elements',length(md)));
    return
end

str=get(md,'xml');

%% pretty it up (very limited for now...)
%TODO improve command line output of MetaData xml
str=regexprep(str,'<Image>','\n<Image>');
str=regexprep(str,'<DisplayOptions','\n<DisplayOptions');
disp(str)