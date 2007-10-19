#!/usr/bin/perl -w
#

use strict; 
use warnings;
use Test::More tests => 28;
use Data::Dumper::Simple;
use List::Compare;
use III;

# 1 - Create a new CollData
my $cd1=III::CD->new;
isa_ok($cd1,'III::CD');

# 2 - check isEmpty
my $empty=$cd1->isEmpty;
my $emptynum=0;
$emptynum += $_ foreach values(%$empty);
is($emptynum,4,"all four fields are empty in new object");

# 3 - Set a filename and see that we can get it
# This tests both the FileName property and the ability to get a scalar
$cd1->set({FileName => 'Test1'});
is($cd1->get('FileName'),'Test1',"Set&Get FileName property");

# 4 - Set both CollType and CollName in one go
$cd1->set({CollName => 'tst1', CollType => 'Plate'});
my $data=$cd1->get(qw(CollName CollType));
$_=Dumper(%$data);
s/\s//g;
is($_,"\%\$data=('CollName'=>'tst1','CollType'=>'Plate');",
   "Get/Set for CollType and CollName return values as hashref");

# 5 - add a SubImg where none exist
my @img=qw(img1.tif img2.tif img3.tif);
$cd1->add({SubImg=>\@img});
my $img2=$cd1->get('SubImg');
ok('img1.tif:img2.tif:img3.tif' eq join(':',sort(@$img2)),"Add/Get to SubImg with empty SubImg field");

# 6 - Add again new images
@img=qw(img4.tif img5.tif);
$cd1->add({SubImg=>\@img});
$img2=$cd1->get('SubImg');
ok('img1.tif:img2.tif:img3.tif:img4.tif:img5.tif' eq join(':',sort(@$img2)),"Add/Get to SubImg where its not empty");

# 7 - Add a SubImg where some already exist - should not add anything
$cd1->add({SubImg=>\@img});
$img2=$cd1->get('SubImg');
is('img1.tif:img2.tif:img3.tif:img4.tif:img5.tif',join(':',sort(@$img2)),"Add vlaues that are already there to SubImg");

# 8 - Add both SubColl and DomColl at once
my @sc=qw(coll1.xml coll2.xml);
my @dc=qw(dcoll1.xml dcoll2.xml);
$cd1->add({DomColl=>\@dc,SubColl=>\@sc});
my $got=$cd1->get(qw(SubImg SubColl DomColl));
my %expected=( 'SubImg' => ['img1.tif','img2.tif','img3.tif','img4.tif','img5.tif'],
           'DomColl' => ['dcoll1.xml','dcoll2.xml'],
           'SubColl' => ['coll1.xml','coll2.xml']);
is_deeply(\%expected,$got,"Add to CD multiple fields and Get a CD with multiple argin - checking entire return structure ");

# 9 - Create Qdata 
my $q=III::Qdata->new({type=>'pixnum','value'=>7,label=>undef,description=>undef});
isa_ok($q,'III::Qdata');

# 10 - stringify
is($q->stringify,"pixnum_{7}_NULL_NULL","Stringify") or diag("\$q->stringify has the values\n $q->stringify");

# 11 - Add Qdata and see if retun is Qdata type
my @Qs;
push @Qs,$q;
$cd1->add({Qdata=>\@Qs});
my $Qs2=$cd1->get('Qdata');
my $q3=$Qs2->[0];
isa_ok($q3,'III::Qdata');

# 12 - and its the same as its clone.
my $q2=$q3->clone;
is_deeply($q,$q2,"Add and get return the same");

# 13 - set label and check that after strigify not the same
$q2->set({label=>'stam'});
isnt($q->stringify,$q2->stringify,"set label make Qdata different");

# 14 and the label is indeed stam
my $rtn=$q2->get('label','value');
is("$rtn->{label}"."$rtn->{value}","stam{7}","Qdata set");

# 15 add $Q again and also add $q2 the modified clone
push @Qs, $q2;
$cd1->add({Qdata=>\@Qs});
my $newQs = $cd1->get('Qdata');
is(scalar(@$newQs),2,"Addition of same and different Qdata objects");

# 16 - and the Qdata are different
isnt($newQs->[0]->{label},$newQs->[1]->{label},"Qdata are different");

# 17 - Write to File where none exist
# first delete Test1
unlink 'Test1';
$cd1->merge2file;
my $filename=$cd1->get('FileName');
my $cd2=III::CD->new($filename);
is_deeply($cd1,$cd2,"Write to file for first time and read from file");


# 18 - turn into xmls (kind of link cloning...)
my $xml1=$III::CollXML->XMLout($cd1);
my $xml2=$III::CollXML->XMLout($cd2);
is($xml1,$xml2,"XML forms are the same");

# 19 - now do another change to $cd1
my @moreimg=qw(img5.tif img6.tif);
$cd1->add({SubImg=>\@moreimg});
my $diff=$cd1->diff($cd2);
is(join(':',sort(@{$diff->{SubImg}})),'img6.tif',"Diff after addition of SubImg");

# 20 - the only difference should have been in the images
is(join(':',keys(%$diff)),'SubImg',"Only difference is in the field that chagned");

# 21 - merge addition to file and compare with previous version
#      difference should be the img6 additions
open T1,'<Test1';
my @T1=<T1>;
close T1;
$cd1->merge2file;
open T2,'<Test1';
my @T2=<T2>;
close T2;
my $comp = List::Compare->new('-u','-a',\@T2,\@T1);
my @diff=$comp->get_Lonly;
like(join(':',@diff),qr/img6/,"merge of new SubImg into existing file");

# 22 - remove all the images from $cd and see that merge doesn't remove them
$cd1->set({SubImg=>undef});
$cd1->merge2file;
my $cd3=III::CD->new('Test1');
my $imgref=$cd3->get('SubImg');
is(join(':',@$imgref),'img1.tif:img2.tif:img3.tif:img4.tif:img5.tif:img6.tif',"merge less does nothing");

# 23 - set filename and save as differenet file
unlink 'Test2';
$cd1->set({FileName=>'Test2'});
$cd1->merge2file;
open T1,'<Test1';
@T1=<T1>;
close T1;
$cd1->merge2file;
open T2,'<Test2';
@T2=<T2>;
close T2;
$comp = List::Compare->new('-u','-a',\@T1,\@T2);
@diff=$comp->get_Lonly;
like(join(':',@diff),qr/img6/,"merge of new SubImg into existing file");

# 24 - create a DB from sql file without errors
open(INITDB,"dropdb i4a; createdb i4a; psql i4a < create_all_tables.sql 2>&1 |");
my @log=<INITDB>;
close(INITDB);
unlike( join('',@log), qr/ERROR/, "Database creation from scratch");

# 25 check connection to DB when not connected 
is(III->isConnectedToDB,0,"III::isConnectedToDB");

# 26 connect to DB and see that status change
III->connectToDB;
is(III->isConnectedToDB,1,"III::connectToDB is succesful");

# 27 create an object from FS and sync it to DB and have the DB version same as file
unlink(qw(coll2.xml coll1.xml dcoll1.xml dcoll2.xml));
my $cd5=III::CD->new('Test2');
$cd5->sync;
my $cd4=III::CD->new($cd5->get('FileName'),'FROM_DB');
is_deeply($cd4,$cd5,"sync and retrival from DB return same object");

# 28 dissconnect
III->disconnectFromDB;
ok(!III->isConnectedToDB,"Disconnect");


