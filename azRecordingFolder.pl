#!/usr/bin/perl
use strict;
use warnings;

#my $base = "/Users/lehuang/Downloads/";
my $base = "/mnt/angel_call_recordings/0a140225-04-148cd488dc6-f5a34735-6d4/callrecordings/";

sub createFolderForMonth {
	my $path = $_[0];
	my $monthPath =  "";
	for (my $month=1;$month<13;$month++) {
		$monthPath = $path.$month."/";
		print "$monthPath\n";
		if (-e $monthPath) {
			print "$monthPath already exists!\n";
		}
		else {
			unless(mkdir(($monthPath, 0777))) {
        		die "Unable to create $monthPath\n";
    		}
		}
		createFolderForDay ($month, $monthPath);
	}
}

sub createFolderForDay {
	my ($month, $path) = @_;
	my $dayPath = "";
	if ($month == 2) {
		for (my $day=1;$day<30;$day++) {
			$dayPath = $path.$day."/";
			if (-e $dayPath) {
				print "$dayPath already exists!\n";
			}
			else {
				unless(mkdir(($dayPath, 0777))) {
        			die "Unable to create $dayPath\n";
    			}
			}
			createFolderForHour ($dayPath);
		}
	}
	elsif ($month == 11) {
		for (my $day=1;$day<31;$day++) {
			$dayPath = $path.$day."/";
			if (-e $dayPath) {
				print "$dayPath already exists!\n";
			}
			else {
				unless(mkdir(($dayPath, 0777))) {
        			die "Unable to create $dayPath\n";
    			}
			}
			createFolderForHour ($dayPath);
		}
	}
	elsif ($month =~ /[1|3|5|7|8|10|12]/) {
		for (my $day=1;$day<32;$day++) {
			$dayPath = $path.$day."/";
			print "$dayPath\n";
			if (-e $dayPath) {
				print "$dayPath already exists!\n";
			}
			else {
				unless(mkdir(($dayPath, 0777))) {
        			die "Unable to create $dayPath\n";
    			}
			}
			createFolderForHour ($dayPath);
		}
	}
	elsif ($month =~ /[4|6|9]/) {
		for (my $day=1;$day<31;$day++) {
			$dayPath = $path.$day."/";
			if (-e $dayPath) {
				print "$dayPath already exists!\n";
			}
			else {
				unless(mkdir(($dayPath, 0777))) {
        			die "Unable to create $dayPath\n";
    			}
			}
			createFolderForHour ($dayPath);
		}
	}
	else {
		print "that can't happen!\n";
		exit;
	}
}

sub createFolderForHour {
	my $path = $_[0];
	my $hourPath = "";
	for (my $hour=0;$hour<24;$hour++) {
		$hourPath = $path.$hour;
		print "$hourPath\n";
		if (-e $hourPath) {
			print "$hourPath already exists!\n";
		}
		else {
			unless(mkdir(($hourPath, 0777))) {
        		die "Unable to create $hourPath\n";
    		}
		}
	}
}

sub main () {
	if ((@ARGV == 1) and ($ARGV[0] =~ /\d{4}/)) {
		my $yearPath = $base.$ARGV[0]."/";
		if (-e $yearPath) {
			print "$yearPath already exists!\n";
		}
		else {
			unless(mkdir(($yearPath, 0777))) {
        		die "Unable to create $yearPath\n";
    		}
		}
		createFolderForMonth ($yearPath);	
    }
    elsif ((@ARGV == 2) and ($ARGV[0] =~ /\d{4}/) and ($ARGV[1] =~ /\d{1,2}/)) {
    	my $dayPath = $base.$ARGV[0]."/".$ARGV[1]."/";
    	print "$dayPath\n";
		if (-e $dayPath) {
			print "$dayPath already exists!\n";
		}
		else {
			unless(mkdir(($dayPath, 0777))) {
        		die "Unable to create $dayPath\n";
    		}
		}  	
		createFolderForDay ($ARGV[1], $dayPath);
    }
    elsif ((@ARGV == 3) and ($ARGV[0] =~ /\d{4}/) and ($ARGV[1] =~ /\d{1,2}/) and ($ARGV[2] =~ /\d{1,2}/)) {
    	my $hourPath = $base.$ARGV[0]."/".$ARGV[1]."/".$ARGV[2]."/";
    	print "$hourPath\n";
		if (-e $hourPath) {
			print "$hourPath already exists!\n";
		}
		else {
			unless(mkdir(($hourPath, 0777))) {
        		die "Unable to create $hourPath\n";
    		}
		}
		createFolderForHour ($hourPath);
    }
    else {
        print("USEAGE:\n");
        print("    ./azRecordingFolder.pl <year> [<month>] [<day>]\n");
        exit;
    } 
}

main ()