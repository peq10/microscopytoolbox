function mdarray = split( md )
%SPLIT an array of similar metadata objects IN THE TIME DOMAIN


%% get the critical fields:
[planetime,qdata]=get(md,'planetime','qdata');
sz=get(md,'dimensionsize');          
mdarray=[];

%% create the array
for i=1:length(planetime)
    q=qdata;
    for j=1:length(q)
        if ~isempty(q(j).Value)
            q(j).Value=q(j).Value(i);
        end
    end
    mdarray=[mdarray; set(md,'DimensionSize',[sz(1:2) 1],...
                             'planetime',planetime(i),...
                             'qdata',q)];
end




