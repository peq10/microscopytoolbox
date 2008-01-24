
package III;

use strict;
use XML::Simple qw(:strict);
use DBI;
use Data::Dumper::Simple;
use Data::Compare;
use List::Compare;
use IO::LockedFile;
use Switch;

#use IO::Uncompress::Bunzip2;
#use Graph::Easy;

############## Package "Constants" ################
our $VERSION=0.01; 
our $configFileName='config.txt';

############## Package "Globals" #################
# The handle to the DB and the hash for all queries
my $db; 
our %Queries; 

# a hashref with all the configuration data.
our $Config=parseConfigFile($configFileName);

# the XLS that can parse (In/Out) the collection metadata XML and the default empty CD file
our $CollXML=XML::Simple->new(
            ForceArray => ['Qdata','SubColl','DomColl','SubImg'],
            KeyAttr => {},
            NoAttr => 1,
            NoSort => 0,
            SuppressEmpty => '', # is NULL assigns '', this should match the behaviour of DBI
                                 # I think I got it right, but if not, just change isEmpty method                               
            RootName => 'CollData' );
            
our $Empty_CD="CollData.xml";
            
# the XLS that can parse (In/Out) the image metadata XML 
our $ImgXML=XML::Simple->new(
            ForceArray => ['Qdata','ChannelInfo'],
            KeyAttr => {},
            NoAttr => 1,
            NoSort => 0,
            NoIndent => 1,
            SuppressEmpty => '', # see comment in XML
            RootName => 'ImgData');


our $Empty_MD="ImgData.xml";

############ General Functionality ################

sub connectToDB { 
# connectToDB - connects to the Database by name, return db handle
#
# inputs:
#    @_=($DBname)
# outputs: 
#    ($db) a DBI database handle
#
$db=DBI->connect("dbi:Pg:dbname=getDBname()" ,"", "",{AutoCommit => 0,RaiseError => 0}) or
        die "Can't connect to getDBname(): $DBI::errstr";
# prepare the statement handles hash
%Queries=(
    CollNameType => $db->prepare('SELECT filename,name,type FROM collections WHERE filename= ?'),
    SubColl => $db->prepare('SELECT sub FROM coll_2 WHERE dom= ?'),
    DomColl => $db->prepare('SELECT dom FROM coll_2 WHERE sub= ?'),
    ImgList => $db->prepare('SELECT img FROM img_x_coll WHERE coll= ?'),
    CollQdataType => $db->prepare('SELECT * from coll_qdata_types where name = ?'),
    CollQdata => $db->prepare('SELECT type,value,label,description '.
                              'FROM coll_qdata INNER JOIN coll_qdata_types '.
                              'ON coll_qdata.type = coll_qdata_types.name WHERE coll = ?'),
    Insert2Coll_2 => $db->prepare('INSERT INTO coll_2 (dom,sub) VALUES (?,?)'),
    Insert2ImgXColl => $db->prepare('INSERT INTO img_x_coll (img,coll) VALUES (?,?)'),
    InsertCollQdata => $db->prepare('INSERT INTO coll_qdata (type,coll,value,label) VALUES (?,?,?,?)'),
    InsertImgQdata => $db->prepare('INSERT INTO img_qdata (type,img,value,label) VALUES (?,?,?,?)'),
    InsertCollFileNameType => $db->prepare('INSERT into collections (filename,name,type) VALUES (?,?,?)'),
    InsertCollQdataType => $db->prepare('INSERT into coll_qdata_types (name,description) VALUES (?,?)'),
    SelectAllViewNames => $db->prepare('SELECT view_name,id,executable from job_types'),
    InsertNewJob => $db->prepare('INSERT into jobs (filename,job_type_id) VALUES (?,?)'),
    UpdateJobStatus => $db->prepare('UPDATE jobs set status= ? WHERE id = ')
    ) or die "Could not prepare queries";
}

sub disconnectFromDB { 
# disconnectFromDB - a nice cleanup 

#remove all premade queries
foreach my $qry (keys %Queries) {
    $Queries{$qry}->finish;
    }
# disconnect
$db->disconnect() or die "Couldn't diconnect from DB";
}

sub isConnectedToDB {
    return 1 if (defined $db and $db->{Active});
    return 0;
    }
sub commit {
    my $ok=isConnectedToDB;
    $db->commit if $ok;
}

sub parseConfigFile {
# parseConfigFile - gets a file name of a config file and return a ref to hash
#
# inputs:
#    @_=($configfilename)
# outputs: 
#    ($Config) a ref for hash
#
# Hash keys are: 
#   DataRootFolder - where to put images in (root folder)
#   DBname       - database name
#   verbose      - determine level of output (currently has only 1 and 0 levels)
#   
# Basically it just parses the file lines that must be XXX=YYY such that XXX is the Key and YYY is the value
#
    open(FIN,$_[0]) or die "Couldn't open filename $_[0]\n";
    my ($line,@prts,$Config);
    while ($line=<FIN>) {
        chomp($line);
        @prts=split(/=/,$line);
        $Config->{$prts[0]}=$prts[1];
    }
    close(FIN);
    return $Config;
}

sub getDBname { return $Config->{DBname}; }
sub getDataRootFolder { return $Config->{DataRootFolder}; }
sub getVerbose { return $Config->{verbose};}
sub compress {}
sub deompress {}
sub isCompressed { return 0; } # for now, nothing is compressed....

############ Class that defines the behavior of Qdata data type ##########
package III::Qdata;
use III;
use strict;

sub new {
# Creates a new Qdata object, it can recieve two alternative forms
# first is a hashref with the fields type,value and label
# the other is a scalar (string) that has the type:value: and label
# note that value should be a Postgres numeric[] value. e.g. '{23}'
# if it is not one, it would be assigned as one.
    
    my ($class,$data) = @_;
    my %data;
    # do input check and trasfrom it all to a %data hash
    if (! ref($data)) {
        @data{qw(type value label description)}=split /_/,$data; 
      
    } elsif (ref($data) eq 'HASH'){
        (join('',sort(keys(%$data))) ne 'descriptionlabeltypevalue') and
            die "If III::Qdata->new is called with hashref, it must have fields: type, label, value, description";
        %data=%$data;
    } else {
        die('Error - must suppli III::Qdata->new with a hashref or a scalar');
    }
    
    # is value / label / description are empty, replate with 'NULL'
    (! defined $data{value} ) and $data{value}='NULL';
    (! defined $data{description} ) and $data{description}='NULL';
    (! defined $data{label} ) and $data{label}='NULL';
    ($data{value}!~/\D/) and $data{value}="\{$data{value}\}";
    my $self = \%data;
    bless $self, $class;
    return $self;
}
sub set {
    my $self=shift;
    my $data=shift;
    foreach my $type (keys %$data) {
        if (($type eq 'value') and ($data->{$type}!~/\D/)) {$data->{$type}="'{$data->{$type}}'";}
        $self->{$type}=$data->{$type};
    }
    # if its a single number wrap it with '{}'
    
    return $self;
}

sub get {
#get a single scalar and return the value for its type
my $self=shift;

if (@_==1) {
    my $type=shift;
    return ($self->{$type});  
} else {
    my %data;
    while (my $key=shift) {
        $data{$key}=$self->get($key);
    }
    return \%data;
}


}
sub stringify {
    my $self = shift;
    my @values;
    push @values,$self->get('type');
    push @values,$self->get('value');
    push @values,$self->get('label');
    push @values,$self->get('description');
    my $str=join('_',@values);
    return $str;
}

sub clone {
    my $self =shift;
    my $clone=III::Qdata->new($self->stringify);
}

############ Collecion Data (CD) class ###############

package III::CD; 
use III;
use strict;

sub new {  
# new - new(filename,source) create a new CollData object
# filename is a full file name and source is (FROM_DB or FROM_FS)
#    
#    new(filename,FROM_FS)
#
# The default values are as follows: filename = CollData.xml
#                                    source   = FROM_FS
# 
    # define the object - get its class
    my $class = shift;

    # set default input argument
    my ($filename,$source,$cd,%data);
    if (scalar(@_) == 0 )   { $filename=$III::Empty_CD; $source='FROM_FS';}
    elsif (scalar(@_) == 1 ){ $filename=shift; $source='FROM_FS';}
    elsif (scalar(@_) == 2 ){ $filename=shift; $source=shift;}
    else {print "error III::CD::new can only get 0/1/2 input arguments"}

    # uncompress is needed
    #($source eq 'FROM_FS') && III::isCompressed($filename) && III::unCompress($filename);
    
    # based on $fromDBflag, create a new CD data structure. 
    if ($source eq 'FROM_DB') {
        # start by making an empty CD object
        $cd=III::CD->new();
    
        # First deal with regular scalar values
        $Queries{CollNameType}->execute($filename);
        my @CollNameType = $Queries{CollNameType}->fetchrow_array;
        $data{FileName}=$CollNameType[0];
        $data{CollName}=$CollNameType[1]; 
        $data{CollType}=$CollNameType[2];
            
        # Now do qdata
        $Queries{CollQdata}->execute($filename);
        my $QdataRows = $Queries{CollQdata}->fetchall_arrayref({});
        my @Qdata;
        foreach my $row (@$QdataRows) {push(@Qdata,III::Qdata->new($row));}
        $data{Qdata}=\@Qdata;
    
        # Get the Images 
        $Queries{ImgList}->execute($filename);
        my $Img = $Queries{ImgList}->fetchall_arrayref;
        $data{SubImg}=$Img;
   
        # Get the sub relations
        $Queries{SubColl}->execute($filename);
        my $subs = $Queries{SubColl}->fetchall_arrayref;
        my @deref_subs=map $_->[0],@$subs;
        $data{SubColl}=\@deref_subs;
        
        # Get the dom relations
        $Queries{DomColl}->execute($filename);
        my $doms = $Queries{DomColl}->fetchall_arrayref;
        my @deref_doms = map $_->[0],@$doms;
        $data{DomColl}=\@deref_doms;
        
        # now update the values in %data and return the $cd
        $cd->set(\%data);
        return $cd;
      
    }
    elsif ($source eq 'FROM_FS') {
        if ((-e $filename) and (-s $filename)) { # file exist and has non zero length
            $cd=$CollXML->XMLin($filename);
        }
        else { #fall back on default 
            $cd=$CollXML->XMLin($III::Empty_CD);
            # if filename is not tje default, update it
            # this is important when creating a new object from scratch
            $cd->{FileName}=$filename if ($filename ne $III::Empty_CD);
        }
        # create an object
        bless $cd, $class;
        # if $cd has Qdata need to bless them as well
        #if (!$cd->isEmpty('Qdata')) {
            my $Qdata_ref=$cd->get('Qdata');
            foreach my $qref (@$Qdata_ref) {
                bless $qref,'III::Qdata';
            }
        #}
        
        return $cd;
    }
    else {die "You tried to create a CD object with a wrong flag - source can be either FROM_FS or FROM_DB";}
      
}

sub get {
# GET - getting collection properties
# if more then one argument, e.g. several keys, than output is a hashref
# else, e.g. input in single scalar, I return the actual value. 
# Return arguments are: scalar (if nargin=1 && nargout =1)/ arrayref (if nargin>1 && nargout=1)/ hashref (nargin>1)
# 
#   CollName => Scalar - the name 
#   FileName => Scalar - the filename 
#   CollType => Scalar - the type
#   Qdata    =>  a refarray for qdata objects 
#   SubImg  => an refarray of image names
#   DomColl => a refarray of dom (to self) collection names
#   SubColl => a refarray of sub (to self) collection names
#   QdataTypes => a refarray of qdata key (concatination of Qdata

# here we deal with all sinlge elements
   my $self=shift;
   if (@_==1) {
        if ($_[0] eq 'QdataTypes') {
            my $qdata=$self->{'Qdata'};
            my @qdatatypes;
            foreach my $q (@$qdata) {push(@qdatatypes,"$q->get('type')")}
            return \@qdatatypes;
        }
      else {
        return $self->{$_[0]};
      }
   }
   
# here I deal with the entire array by calling the first part
   my $curr_data;
   foreach my $key (@_) {
        $curr_data->{$key}=$self->get($key);
        }
   return $curr_data;
}


sub set { 
# SET - setting collection properties
# 
# argument should be passed as a hash. currenlty supprts: 
# 
#   CollName => Scalar - the name 
#   FileName => Scalar - the filename 
#   CollType => Scalar - the type
#   qdata    => A refarray for of qdata objects
#   SubImg  => a refarray of image names
#   SubColl => a refarray of collection names
#   DomColl => a refaray of collection names
    my $self=shift; 
    my $hashref = shift;
    my @empty;
    push @empty,'';
    foreach my $key (keys %$hashref) {
          switch ($key) {
            case ('CollName') {$self->{CollName}=$hashref->{$key}}
            case ('FileName') {$self->{FileName}=$hashref->{$key}}
            case ('CollType') {$self->{CollType}=$hashref->{$key}}
            case ('SubImg') {$self->{$key}=  ! exists $hashref->{$key}->[0] ? \@empty : $hashref->{$key}}
            case ('SubColl') {$self->{$key}=  ! exists $hashref->{$key}->[0] ? \@empty : $hashref->{$key}}
            case ('DomColl') {$self->{$key}=  ! exists $hashref->{$key}->[0] ? \@empty : $hashref->{$key}}
            case ('Qdata') {$self->{$key}=  ! exists $hashref->{$key}->[0] ? \@empty : $hashref->{$key}}
        }
    }
}

sub add { 
# adds SubColl / DomColl / SubImg / Qdata to a Coll object
# Input is a hashref with key as to what to update and refarray to values.
    my ($self,$diff) = @_;
    my $comp;
    foreach my $type (keys %$diff) {
        if ($self->isEmpty($type)) {
            if ($type eq 'Qdata') {
                # stringify Qdata, union with itself and and create new based on it,
                my @newQsStrs = map $_->stringify, @{$diff->{$type}};
                $comp = List::Compare->new('-a',\@newQsStrs,\@newQsStrs);
                my @newQs = map III::Qdata->new($_), @newQsStrs;
                $self->{'Qdata'} = \@newQs; 
            } else {
                # union with itself to get a unique list
                $comp = List::Compare->new('-a',$diff->{$type}, $diff->{$type});
                $self->{$type}=$comp->get_union_ref;  
            }
            
        }
        else {
            if ($type eq 'Qdata'){
                # trasform both Qdata arr_ref into string arrays
                my @selfQsStrs = map $_->stringify, @{$self->{$type}};
                my @otherQsStrs = map $_->stringify, @{$diff->{$type}};
                # perform comparison (get union)
                $comp = List::Compare->new('-a',\@selfQsStrs, \@otherQsStrs);
                @selfQsStrs = $comp->get_union;
                # transform back to Qdatas
                my @selfQs = map III::Qdata->new($_), @selfQsStrs;
                $self->{'Qdata'} = \@selfQs;
            } else {
                $comp = List::Compare->new('-a',$self->{$type}, $diff->{$type});
                $self->{$type} = $comp->get_union_ref;
            }
        }    
    }
}


sub diff {
# diff - given an additopnal CD object returns a hashref for arrays of all differences
#        in the followsing keys: SubColl, DomColl, SubImg, Qdata
#        return only keys that have a difference in them!
my ($self,$other)=@_;
my ($diff,$comp);

# Checking sub Coll
if (!$self->isEmpty('SubColl')) {
    $comp = List::Compare->new('-a',$self->get('SubColl'), $other->get('SubColl'));
    if (@{$comp->get_Lonly_ref}) { $diff->{SubColl}=$comp->get_Lonly_ref;}    
}

# Checking dom Coll
if (!$self->isEmpty('DomColl')) {
    $comp = List::Compare->new('-a',$self->get('DomColl'), $other->get('DomColl'));
    if (@{$comp->get_Lonly_ref}) { $diff->{DomColl}=$comp->get_Lonly_ref;}
}

# Checking sub imgs
if (!$self->isEmpty('SubImg')) {
    $comp = List::Compare->new('-a',$self->get('SubImg'), $other->get('SubImg'));
    if (@{$comp->get_Lonly_ref}) { $diff->{SubImg}=$comp->get_Lonly_ref;}
}

# Qdata
# transform the Qdata into string lists using stringify
# than perform compare and return the diff as new Qdata objects
if (! $self->isEmpty('Qdata')) {
    if ($other->isEmpty('Qdata')) {
        my @Qs = map $_->clone,@{$self->get('Qdata')};
        $diff->{'Qdata'}=\@Qs;
    } else {
        my @selfQsStrs = map $_->stringify, @{$self->get('Qdata')};
        my @otherQsStrs = map $_->stringify, @{$other->get('Qdata')};
        $comp = List::Compare->new('-a',\@selfQsStrs, \@otherQsStrs);
        my @diffQstrs=$comp->get_Lonly;
        if (@diffQstrs) {
            my @diffQs = map III::Qdata->new($_), @diffQstrs;
            $diff->{'Qdata'}=\@diffQs;
        }
    }
    
}
return $diff;
}


sub sync {
# sync - updates the DB based on current object (which is from the FS) and updates other files in the filesystem if needed. 
# It creates an object from the DB, finds what's missing using diff and adds it to the DB, Sub/Dom relation missing from the DB
# are also updated in the Dom/Sub file if necessary

  my $coll_fs=shift; # calling $self $fs to show where its coming from 
  my $filename=$coll_fs->get('FileName');
  my $coll_db=III::CD->new($filename,'FROM_DB');
  
  # Testing if two CD are the same - return
  if (Data::Compare::Compare($coll_fs,$coll_db)) {return 1;}
  
  # Testing if doesn't exist at all in db, than insert essential (FileName, Name, Type)
  if ( ! defined ($coll_db->get('FileName'))) {
    my $filenametype = $coll_fs->get(qw(FileName CollName CollType));
    # if CollName or CollType are not defined (e.g. HASH ref since thats what XML::Simple leaves that with....)
    $filenametype->{CollName}=undef if $filenametype->{CollName} eq '';
    $filenametype->{CollType}='Unknown' if $filenametype->{CollType} eq '';
    $Queries{InsertCollFileNameType}->execute($filenametype->{FileName},$filenametype->{CollName},$filenametype->{CollType});
  }
  
  # If we are here than there is some difference in arrays: (Sub/Dom, Img, Qdata) 
  # Find out the differenes
  my $diff = $coll_fs->diff($coll_db);
  my ($coll2update,$img2update);
  
  if (my $SubColl=$diff->{SubColl}) {
    foreach my $new_SubColl (@$SubColl) {
        # build new_SubColl from FS
        # if not in filesystem, this will create the default (empty) CD; 
        $coll2update=III::CD->new($new_SubColl);
        $coll2update->add({'DomColl'=>[$filename]});
        $coll2update->merge2file;
        # check if exist in DB - if not, and I need it for my insert..., sync it.
        $Queries{CollNameType}->execute($new_SubColl);
        if (!$Queries{CollNameType}->fetchrow_array) {
            $coll2update->sync;
        } else {
            $Queries{Insert2Coll_2}->execute($filename,$new_SubColl);
        }
    }
  }
  
  # Checking dom Coll
  if (my $DomColl= $diff->{DomColl}) {
    foreach my $new_DomColl (@$DomColl) {
        $coll2update=III::CD->new($new_DomColl);
        $coll2update->add({'SubColl'=>[$filename]});
        $coll2update->merge2file;
        # check if exist in DB - if not, and I need it for my insert..., sync it.
        $Queries{CollNameType}->execute($new_DomColl);
        if (!$Queries{CollNameType}->fetchrow_array) {
            $coll2update->sync;
        } else {
            $Queries{Insert2Coll_2}->execute($new_DomColl,$filename);
        }
    }
  }
 
  # Checking sub imgs
  # Unlike in the coll (sub/dom) hereI'm not creating any new image
  # client programmer must make sure they exist before syncing a collection.
  #if (my $SubImg = $diff->{SubImg})  {
  #  foreach my $new_SubImg (@$SubImg) { 
  #      $Queries{Insert2ImgXColl}->execute($new_SubImg,$filename);
  #      $img2update=III::MD->new($new_SubImg);
  #      $img2update->add({'InCollection'=>[$filename]});
  #      $img2update->merge2file;
  #  }
  #}
  
  # Checking qdata
  if (my $Qdata = $diff -> {Qdata}) {
    foreach my $q (@$Qdata) {
        # check if coll_qdata_type is defined, if not add it.
        $Queries{CollQdataType}->execute($q->{type});
        if (!$Queries{CollQdataType}->fetchrow_array) {
            $Queries{InsertCollQdataType}->execute($q->{type},$q->{description});
        }
        $Queries{InsertCollQdata}->execute($q->get('type'),$filename,$q->get('value'),$q->get('label'));        
    }
  }
  III->commit;
}

sub merge2file {
# merge2file add anything that is new in $self to the $filename
# but new things in $filename are kept. All operation are done while blocking
# the file so it doesn't hurt anything and allows multiple clients. 

    my $self = shift;
    my $filename = $self->get('FileName');
    
    #TODO: move the lock to here before the read...

    # I create a new object from file, if identical - return;
    my $file_ver = III::CD->new($filename);
    if (Data::Compare::Compare($file_ver,$self)) {
        return 1;
    }
    
    # create a filehandle with flock 
    my $fh = new IO::LockedFile(">$filename") or die "Couldn't open locked file for R/W";
    
    # update CollType and CollName
    $file_ver->set($self->get(qw(CollType CollName)));
    # take the diff - everything the $self has that $file_ver doesn't. 
    my $diff = $self->diff($file_ver);
    # and add the diff into $file_ver
    $file_ver->add($diff);
    # and write to file. 
    $CollXML->XMLout($file_ver,OutputFile => $fh);
    $fh->close;
    
    return 1; 
   
}

sub isEmpty {
# This sub checks to see if fields are empty.
# If called with no input arguments, returns a hash with keys for fields and 0/1 if they are empty or not.
# If called with a scalar input argument returns the 1/0 for this field
#
my $self = shift;
my ($empty,$key);
if (@_ > 0 ) {
    $empty=0;
    $key = shift;
    if ($key eq 'Qdata') {
        #Qdata is empty is type key does exist,
        #exist and undefined, exist defined
        # and empty and exist and is a hashref (as generated by XML::Simple)
        $empty=1 if (($self->{'Qdata'}->[0] eq '') ||
                     (!exists $self->{Qdata}[0]->{type}) ||
                     (! defined $self->{Qdata}[0]->{type}) ||
                     ($self->{Qdata}[0]->{type} eq '') ||
                     (ref($self->{Qdata}[0]->{type}) eq 'HASH'));
    } else {
        $empty=1 if (!defined $self->{$key}->[0]) || ( $self->{$key}->[0] eq '');  
    }
} else {
    foreach $key (qw(SubColl DomColl SubImg Qdata)) {
        $empty->{$key}=$self->isEmpty($key);
    }
}

return $empty;
}

1; 
 
############## Image  Data (MD) class #################

package III::MD;
use Image::Info qw(image_info);
use III;
# new - a MD constractor read a tiff image and returns the XML form ints description tag
#
# inputs:
#    @_=($imagefilename,$fromDBflag)
#    
# outputs: 
#    $md the metadata for the image and for the collections
#
#
sub new {  
    my $self  = shift;
    my $filename;
        my $info = image_info($filename);
        if (my $error = $info->{error}) {
            die "Can't parse image info: $error\n";
        }
        my $xls=XML::Simple->new(ForceArray => ['Qdata','ChannelInfo','Relation','Collection' ],KeyAttr => {});
        my $xml=$xls->XMLin($info->{ImageDescription});
   
}

sub get {}
sub set {}
sub add {}
sub diff {}
sub sync {}
sub merge2file {}

    

##################### Job  class ######################

package III::JobQueue;
use III;
# The job queue is a "Virtual Class" in the sense that it must be inhereted to be useful
# There are few basic functionality methods out of which 2 methdos are useful and could
# be used in the child classes as well (the constructor (new) and the CreateNewJobs)
# the other two methods MUST be overloaded in any subclass to have a meaning, e.g.
# submitting and getting the running job status 

# JobQueue DATA STRUCTURE:
#
# MaxJobNum => the maximum number of jobs to run at the same time
# Queue => a arrayref to an array of hashrefs of currently running jobs

sub new {};
sub CreateNewJobs{
# Methods does the following:
# 1. Find out how many job openning (empty slots) there are N. If 0 return. 
# 2. Get a list of view from the DB
# 3. From the view build a list of job hashrefs (upto N) each having the fields: executable, inputfilename, job_id, job_type_id
#    Implicitly run createInputFile for each new job.

};


sub SubmitAllJobs{}; 
sub GetRunningJobsStatus{};

# "Private" methods
sub updateJobStatusInDB {};
sub createInputFile {}; # a "private" methods that will be only used in CreateNewJobs
                        # for every new job that needs to be created.


# OLD STUFF FROM THE ERA OF A JOB OBJECT                        
## 1. get the names of all views from the job_types table
#my $class=shift;
#
#$Queries{SelectAllViewNames}->execute();
#my $listOfViews = $Queries{CollNameType}->fetchall_arrayref;
#
#my ($filename,$job_type_id,$executable);
#$filename='';
#$_=$filename;
#my $row;
## loop around all view names
#foreach $row in (@$listOvViews) {
#    $filename=$db->do('SELECT filename from $row[0] LIMIT 1') or die $db->errstr;
#    $_=$filename;
#    if ~m// { break;}
#}
#
## check to see that a filename was found
## if so create a job entry with $row[1],$row
#
#my $jobTypeId=$row[1];
#my $executable=$row[2];
#
#$Queries{InsertNewJob}->execute($filename,$jobTypeId);
#
## finish the OO stuff (blessing the reference etc. )
#%job=(job_type_id => $jobTypeId,
#      executable => $executable,
#      filename => $filename);









