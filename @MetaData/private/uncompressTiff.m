function success = uncompressTiff( filename )
%UNCOMPRESSTIFF uses command line tools (hence private) 
%to uncompress the tiff file into a tmp.tiff file. 
% its ugly but it works...

if isempty(findstr(filename,'.tiff'))
    filename = [filename,'.tiff'];
end

success=true;
cmd=sprintf('tiffcp -c none %s tmp.tiff',filename);
ok = system(cmd);

if ~ok, success=false; end