function faliures = test_getset
%TEST_GETSET test case for MetaData set and get methods
%  return number of faliures (0 if nun)

% move to a directory that you can work in
% create a default MetaData

faliures=0;

%% Test addition of collection with wrong order of fields. 
% pth=pwd;
% cd(pth(1:strfind(pth,'@')-1))
md=MetaData; 

% test collections
Coll(1).CollName='MSA001';
Coll(2).CollName='A1';
Coll(1).CollType='Plate';
Coll(2).CollType='Well';
md=set(md,'Collections',Coll);

Coll2=get(md,'collections');
if ~isequal(Coll,Coll2), faliures=faliures+1; end

%% must fail in the following situations

% wrong number of input arguments
try 
    set(md);
    set(md,'Collections');
    faliures=faliures+1;
catch
end

md2=[md; md]; 
try
    set(md2,'Collections',Coll);
    faliures=faliures+1;
catch
end
    

    