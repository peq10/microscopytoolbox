#!/usr/bin/perl -w
#
# This job managers will query the database to identify new jobs 
# it would then launch them as necessary and updates the DB when
# jobs are finished. 

use strict;
use III::JobQueue::Fork; # this should be ANY type of job queue implementation

my $Q=III::JobQueue::Fork->new(MaxJobNum => 5); # a III::JobQueue object

my $timetosleep=300; 

# Connect to the database
III->connectToDB();
while (1) {

# Create new jobs to submit in Q
$Q->CreateNewJobs();
$Q->SubmitAllJobs();
$Q->UpdateJobsStatus();
    
sleep $timetosleep;

}


III->disconnectFromDB();



	


