function ordr=heuristicFrogLeaps(schdle_data,ordr)
% perform scheduling in jumps between timed tasks. 

x=schdle_data.x;
y=schdle_data.y;
t=schdle_data.t;
id=schdle_data.id;
xcurrent=schdle_data.xCurrent;
ycurrent=schdle_data.yCurrent;
tcurrent=schdle_data.tCurrent;
tasks_duration=schdle_data.duration;

if ~exist('ordr','var')
    ordr=[];
end
ix_non_timed=find(isnan(t));

%% Test for all timed / all non timed cases
if isempty(ix_non_timed) % this mean they are all timed
    [tsrt,ix]=sort(t);
    ordr=id(ix);
    return;
end

if length(ix_non_timed)==length(x) % this mean they are all non-timed, pass to acotsp and return
    ordr=greedy(schdle_data);
    return
end

% if we are here, it means that there are both timed and non-timed
% operations.

while ~isempty(id)
    ix_non_timed=find(isnan(t));
    %% Find out the time for the next timed task
    tt=t;
    tt(ix_non_timed)=Inf;
    [ttarget,ixtarget]=min(tt);
    if ttarget==Inf % meaning there is no timed tasks left
        ix_last=find(schdle_data.id==ordr(end));
        schdle_data.xCurrent=schdle_data.x(ix_last);
        schdle_data.yCurrent=schdle_data.y(ix_last);
        schdle_data.tCurrent=schdle_data.t(ix_last);
        [bla,ix]=setdiff(schdle_data.id,ordr);
        schdle_data.x=schdle_data.x(ix);
        schdle_data.y=schdle_data.y(ix);
        schdle_data.t=schdle_data.t(ix);
        schdle_data.id=schdle_data.id(ix);
        schdle_data.duration=schdle_data.duration(ix);
        ordr=[ordr; acotsp(schdle_data)]; 
        return
    end
    dt=ttarget-tcurrent;
    idtarget=id(ixtarget);
    xtarget=x(ixtarget);
    ytarget=y(ixtarget);


    %% find IDs for next jump
    avgdur=mean(tasks_duration(ix_non_timed));
    k=max(floor(dt/avgdur),0);

    ordr=[ordr; choosePath(xcurrent,ycurrent,xtarget,ytarget,x(ix_non_timed),y(ix_non_timed),id(ix_non_timed),k); idtarget];

    %% remove used tasks from schdle_data and call fcn again
    [bla,ix]=setdiff(id,ordr);

    xcurrent=xtarget;
    ycurrent=ytarget;
    tcurrent=ttarget;
    x=x(ix);
    y=y(ix);
    t=t(ix);
    id=id(ix);
end

end % of main function

% subfunction
function ordr=choosePath(xcurrent,ycurrent,xtarget,ytarget,X,Y,id,k)

if k==0
    ordr=[];
    return
end

% calculate weights
w=dist2line(xcurrent,ycurrent,xtarget,ytarget,X,Y);
w=w./sum(w);

% sample 1000 possible routes
route=cell(100,1);
for i=1:1000
    
    route{i}=randsamplewithoutreplacementweighted(numel(X),k,w);
    cst(i)=sum(sqrt(diff([xcurrent X(route{i})' xtarget]).^2+...
                    diff([ycurrent Y(route{i})' ytarget]).^2));
end

[m,mi]=min(cst);
ix=route{mi};
ordr=id(ix);

end

% rand from sample without replacement in a weighted manner
function v=randsamplewithoutreplacementweighted(n,k,w)

if k>=n, 
    v=randperm(n); 
    return
end

v=zeros(1,k);
for i=1:k
    v(i)=randsample(n,1,true,w);
    w(v(i))=0;
    w=w./sum(w);
end

end % of rand function

% calculate the euclidean distance to a line as defined by two points
function d=dist2line(x1,y1,x2,y2,X,Y)

if x1==x2 && y1==y2
    d=distance([x1; y1],[X(:)'; Y(:)']);
    return
end

A=(y1-y2)/(x1-x2);
B=1;
C=(y1-y1)/(x2-x1)+y1;

d=abs((A*X(:)+B*Y(:)+C)/sqrt(A^2+B^2));

end
