function v=randsamplewithoutreplacementweighted(n,k,w)

if k>=n, error('k must be smaller than n'), end
v=zeros(1,k);
for i=1:k
    v(i)=randsample(n,1,true,w);
    w(v(i))=0;
    w=w./sum(w);
end