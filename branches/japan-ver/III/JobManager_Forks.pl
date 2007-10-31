#!/usr/bin/perl -w
#
# This import managers will move the files from the acquisition folder
# into their final location and while doing so will update the DB and create 
# collection files as needed. 

use strict;
use Switch;
use Parallel::Jobs;

use III;

my $job; # a III::Job objecy
my %CurrnetJobs={}; # an hash of currently runing jobs, pids are used as keys
my ($pid,$event,$data); # information I'm geting about running jobs

# Connect to the database
III->connectToDB();

while (1) {

while ($job->III::Jobs->new()) {

    # create input file
	$job->createInputFile();
		
	# start another job and use its pid as a key to store the job hash
	$CurrentJobs->{Parallel::Jobs::start_job(%$nextJob->{"system(%$nextJob->{'executable'}"},$tmpfilename)} =  $job;

}
	
# check to see if any job finished, if so, update the DB
while (! undef ($pid,$event,$data)=Parallel::Jobs::watch_jobs()) {
	switch ($event) {
		case 'EXIT' {
		    $CurrentJobs->{$pid}->parseOutputFile();
		    $CurrentJobs->{$pid}->updateDB('Success');
		    $run_num--; 
		    }
		case 'STDERR' {
		    $CurrentJobs->{$pid}->updateDB('Error');
		    }
	}
}	

III->Sleep;

}


III->disconnectFromDB();



	


