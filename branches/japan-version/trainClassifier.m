nhidden=3;
nout=1;
alpha = 0.2;	% Weight decay
ncycles = 60;	% Number of training cycles. 
% Set up MLP network
net = mlp(4, nhidden, nout, 'logistic', alpha);
options = zeros(1,18);
options(1) = 1;                 % Print out error values
options(14) = ncycles;
[net] = netopt(net, options, data, trgt', 'quasinew');
netcls = mlpfwd(net, data);