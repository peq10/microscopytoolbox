function failures = test_arr2str2arr
%TEST_ARR2STR2ARR test case for str2arr and arr2atr functions
%  return number of faliures (0 if nun)

failures=0; 
arr=cell(8,1);
% List of cases
arr{1}=rand; 
arr{2}=rand(1,3); 
arr{3}=rand(3,1);
arr{4}=rand(3);
arr{5}=rand(3,1,3);
arr{6}=rand(1,3,3);
arr{7}=rand(1,1,3);
arr{8}=rand(3,3,3);

%% test all cases
for i=1:length(arr)
        arr2=str2arr(arr2str(arr{i}));
        if ~isequal(size(arr{i}),size(arr2))
            failures=failures+1;
        else
            cmp=(arr{i}-arr2).^2;
            if sum(cmp(:))/numel(cmp) > 1e-6
                failures=failures+1;
            end
        end
end

%% report test results
if failures 
    fprintf('Failed is %g tests, please check\n',failures);
end

