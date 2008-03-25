function failNum=runUnitTests(md)
% runs a batch of simple "Unit Test" to verify basic funcionallity. 
% md must be a MetaData object but it doens't really matter whats in it. 
%
% Unit Tests are only meant to verify the stated functionality of each unit
% further testing of the complite system will be done via the demos. 

failNum=0;

%% Test the constructor: 
% tests: 1. creation of object from scratch, tiff and xml file
%        2. 

if test_constructor
   disp('Passed test_constructor')
else
    failNum=failNum+1;
    disp('FAILED test_constructor');
end

%% 

