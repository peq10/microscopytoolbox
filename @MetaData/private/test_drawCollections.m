function faliures = test_drawCollections
%TEST_DRAW_COLLECTIONS Summary of this function goes here
%   Detailed explanation goes here

%%
md=MetaData; 

% test collections
Coll(1).CollName='MSA001';
Coll(2).CollName='A1';
Coll(1).CollType='Plate';
Coll(2).CollType='Well';
Rel.sub=2; Rel.dom=1;
md=set(md,'Collections',Coll,'Relations',Rel);

drawCollections(md)

faliures=0;
