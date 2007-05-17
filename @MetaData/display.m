function display(md)
%DISPLAY the MetaData

if length(md)==1
    save(md.xml)
else
    str=[inputname(1) ' is an array with ' num2str(length(md)) ' MetaData objects'];
    disp(str);
end