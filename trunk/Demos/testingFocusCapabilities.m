function [F,Zr,Fr]=testingFocusCapabilities

global rS;
figure(1)
clf
%% Single speed test
Z=-10:0.1:10;

%% speed Vs accuracy 
N=30;
% S=2.^(3:5);
% S=fliplr(S);
S=[5:10];

for i=1:length(S)
    set(rS,'focusspeed',S(i))
    [F(:,i),Zr(:,i),Fr(:,i)]=curveAndTest;
    subplot(2,3,i)
    plotyy(Z,F(:,i),Z,histc(Zr(:,i),Z),'plot','bar')
    title(num2str(S(i)))
end


% nested function
function [f,zr,fr]=curveAndTest
    set(rS,'z',0)
    f=getFocusCurve(Z)';

    % then repeat focus N times
    zr=nan(N,1);
    fr=nan(N,1);

    for j=1:N
        set(rS,'z',0);
        autofocus(rS);
        fr(j)=get(rS,'focusscore');
        zr(j)=get(rS,'z');
    end

end % of nested function

end

    