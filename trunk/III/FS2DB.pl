#!/usr/bin/perl -w
#
# The updateDBfromFS daemon will check to find new files (using linux find) parses them
# and addes / update the data to the DB. 


use strict;
use III;

my ($coll,$md,$NewFiles);

# Connect to the database
III->connectToDB();

while (1) {

# get list of new files
$NewFiles=III->ListNewFiles();

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

III->Sleep;

}
    
III->disconnectFromDB();
	

