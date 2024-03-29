#!/usr/bin/perl -w
#
# The FS2DB daemon will check to find new files since last sleep time parses them
# and addes / update the data to the DB. 


use strict;
use III;
use File::Find;
use File::Find::Closures qw(:all);

# a few usefull variables
my ($coll,$md,$NewFiles);
my $timetosleep=300; # sleep set as 5 min. 
my $wenttosleepat=time;
# Connect to the database
III->connectToDB();

while (1) {

# get list of new / changed files
$NewFiles=ListNewFiles($wenttosleepat);

# Update DB with new / modified files byt creating an object for each file
# and syncing it with the DB. Note that syncing can also changes other file in
# the FS to make sure its all nice and consistent. 
foreach my $filename (@$NewFiles) {
    if ($filename =~ /.xml/) { # its a collection
        $coll=III::CD->new($filename,'FROM_FS');
        $coll->sync();
    }
    elsif ($filename =~ /.tif/){ # its an image
        $md=III::MD->new($filename,'FROM_FS');
        $md->sync();
    }
}
$wenttosleepat=time;
sleep $timetosleep;

}
    
III->disconnectFromDB();

sub ListNewFiles {
# Queries the FS for any file that have been created or changes
# since the time: @_[0] seconds. 
    my $time=shift;
    my( $wanted, $list_reporter ) = find_by_modified_after( $time );
    File::Find::find( $wanted, III );
    my @newfiles = $list_reporter->();
    return \@newfiles; 
}
	

