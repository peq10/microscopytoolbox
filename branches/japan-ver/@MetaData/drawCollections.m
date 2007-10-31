function drawCollections(md,h)
%DRAWCOLLECTIONS draw a nice graph of metadata collections including their 
%   Detailed explanation goes here

if ~exist('h','var')
    h=figure;
end

switch get(h,'type')
    case 'figure'
        figure(h);
        ha=gca;
    case 'axes'
        ha=h;
    otherwise
        error('If you specify h it must be a figure / axes handle!')
end

axes(ha)

Coll=get(md,'collections');
node_label={Coll.CollName};
adj=zeros(length(node_label));

Rel=get(md,'Relations');
for i=1:length(Rel);
    adj(Rel(i).dom,Rel(i).sub)=1;
end

draw_graph(adj,node_label);

