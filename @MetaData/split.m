function mdarray = split( md )
%SPLIT an array of similar metadata objects IN THE TIME DOMAIN


%% get the dimension to split by
switch get(md,'DimensionOrder')
    case 'XYZTC'
        dimordr=[2 3 1];
    case 'XYZCT'
        dimordr=[2 1 3];
    case 'XYTZC'
        dimordr=[3 2 1];
    case 'XYTCZ'
        dimordr=[3 1 2];
    case 'XYCTZ'
        dimordr=[1 3 2];
    case 'XYCZT'
        dimordr=[1 2 3];
    otherwise
        error('Unsupported dimension order : %s',get(md,'DimensionOrder'))
end

dim=strfind(get(md,'dimensionorder'),'T')-2;
sz=get(md,'dimensionsize');
sz=sz(dimordr);
N=sz(dim);

%% get the critical fields:
[stagex,...
 stagey,...
 stagez,...
 planetime,...
 exposuretime,...
 binning,...
 qdata]=get(md,'stagex','stagey','stagez','planetime',...
               'exposuretime','binning','qdata');
           
stagex=reshape(permute(stagex,dimordr),sz);
stagey=reshape(permute(stagey,dimordr),sz);
stagez=reshape(permute(stagez,dimordr),sz);
planetime=reshape(permute(planetime,dimordr),sz);
exposuretime=reshape(permute(exposuretime,dimordr),sz);
binning=reshape(permute(binning,dimordr),sz);

mdarray=[];

%% create the array
for i=1:N
    q=qdata;
    for j=1:length(q)
        if ~isempty(q(j).Value)
            q(j).Value=q(j).Value(i);
        end
    end
    mdarray=[mdarray; set(md,'DimensionOrder','XYCZT',...
                             'DimensionSize',[sz(1:2) 1],...
                             'stagex',stagex(:,:,i),...
                             'stagey',stagey(:,:,i),...
                             'stagez',stagez(:,:,i),...
                             'planetime',planetime(:,:,i),...
                             'exposuretime',exposuretime(:,:,i),...
                             'binning',binning(:,:,i),...
                             'qdata',q)];
end

%%



