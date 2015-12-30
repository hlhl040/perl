#!/usr/bin/perl
use strict;
use warnings;
use DBI;
use Data::Dumper;

sub getSegmentCountsFromPS {
    my $output = $_[0];
    open (OUT, '>', $output) or die ("Could not open PS output file.");

    my $dbName = "prod_cs_clients";
    my $dbHost = "ash-cs-mysql-05";
    my $dbPort = "3306";
    my $dbUser = "cs_remote_usr";
    my $dbPassword = "AhCae4xa";

    my $dsn = "DBI:mysql:database=$dbName;host=$dbHost;port=$dbPort";
    my $dbh = DBI->connect($dsn, $dbUser, $dbPassword);
    my $drh = DBI->install_driver("mysql");
    my @databases = DBI->data_sources("mysql");
    my $sth = "";
    my $totalMissingSegmentsCount = 0;

    my $select = "select CallGUID, count(*) as count from azic_callrecordings where CallDateTime between '2015-02-07 00:00:00' and '2015-12-11 00:00:00' and CallRecLink is not null and left(CallGUID,'1') != 'o' and Skill like 'IC_%' group by CallGUID order by CallGUID ASC;";
    $sth = $dbh->prepare ($select);
    $sth->execute ();
    my $result = $sth->fetchall_hashref('CallGUID');
#    print Dumper($result);
    my $key = "";
    my $value = "";
    my $subKey = "";
    my $subValue = "";
    while (($key, $value) = each %$result) {
        print OUT "$value->{CallGUID}".",";
        print OUT "$value->{count}"."\n";
    }
    $sth->finish;
    close (OUT);
}

sub checkSegmentCountsInSM {
    my $input = $_[0];
    my $dbh = DBI-> connect('dbi:ODBC:DSN=MSSQL;UID=utpazsql;PWD=c3@6*s4T6') or die "CONNECT ERROR! :: $DBI::err $DBI::errstr $DBI::state $!\n";
    if ($dbh) {
        my $sql = q/select c.fieldvalue as UCallGUID, COUNT(*) as number From callmetatbl as a Inner Join callMetaExTbl as c ON a.callId = c.callId where a.callTime between '1423285200' and '1449810000' and c.fieldName = 'callguid' group by c.fieldvalue order by c.fieldvalue ASC;/;
        my $sth = $dbh->prepare($sql);
        $sth->execute();
        my $result = $sth->fetchall_hashref('UCallGUID');
#        print Dumper($result);
        $sth->finish;
        my $totalMissingSegmentsCount = 0;
        my $count = 0;

        open (IN, $input) or die ("Could not open Middleware input file.");
        open (OUT, '>', 'results.txt') or die ("Could not open results file.");
        foreach my $line (<IN>)  {
            my ($guid, $segmentCount) = split (',', $line);
            chomp ($guid);
            chomp ($segmentCount);
            if (exists($result->{$guid})) {
                $count = $result->{$guid}->{number};
            }
            else {
                $count = 0;
            }
            if ($count == $segmentCount) {
            } elsif ($count > $segmentCount) {
               #print "For GUID: $guid CXA has count $segmentCount and PS has count: $count \n";
            } elsif ($count < $segmentCount) {
               $totalMissingSegmentsCount += ($segmentCount - $count);
#               print "ALERT!!! For GUID: $guid PS has count $segmentCount and Speechminer has count: $count --- Total is now $totalMissingSegmentsCount \n";
               print "$guid,";
               print OUT "ALERT!!! For GUID: $guid PS has count $segmentCount and Speechminer has count: $count --- Total is now $totalMissingSegmentsCount \n";
            }
        }
        close (IN);
        close (OUT);
    }
    $dbh->disconnect;
}

sub main () {
    # Constants
    my $SEGMENT_COUNTS = "PS_segments.csv";

    # Function Calls
    getSegmentCountsFromPS ($SEGMENT_COUNTS);
    checkSegmentCountsInSM ($SEGMENT_COUNTS);
}

main ()
