#!/usr/bin/perl
use strict;
use warnings;

my $status_file='/usr/local/etl/scripts/etl_status/etl_status.txt';

open(my $fh, '<:encoding(UTF-8)', $status_file)
  or die "Could not open file '$status_file' $!";

while (my $row = <$fh>) {
  chomp $row;

  if ($row =~ m/IVR_DIMENSIONS|CALL_FACT|CALL_PAGE_FACT|CALL_TASK_SITE_FACT|CALL_VARIABLE_SITE_FACT/) {
        my @key = split(/-->/, $row);
        my $job_name = $key[0];
        $job_name =~ s/^\s+|\s+$//g;
        my $system_name = $key[1];
        $system_name =~ s/^\s+|\s+$//g;
        my @time_stamp = split(/:/, $row);
        my @time = split(/ /, $time_stamp[2]);
        my $hour = $time[4];
        my $current_hour = `date +%-H`;
        my $time_diff = $current_hour - $hour;
        if ( $time_diff > 2 ) {
                `echo "IVR ETL Jobs runs $time_diff hours late for $job_name on $system_name!\n" | mail -s "PROD ETL Delay" PremierEditionOps\@genesys.com,premier-email-alert\@genesyscloud.pagerduty.com,GenesysCXA\@genesys.com`;
                exit;
        }
  }
  elsif ($row =~ m/RMS_BILLING_VCC_AGENT_5|RMS_BILLING_IVR|RMS_BILLING_VCC_AGENT_1/) {
        my @key = split(/-->/, $row);
        my $job_name = $key[0];
        $job_name =~ s/^\s+|\s+$//g;
        my $system_name = $key[1];
        $system_name =~ s/^\s+|\s+$//g;
        my @time_stamp = split(/:/, $row);
        my @time = split(/ /, $time_stamp[2]);
        my $hour = $time[4];
        my $current_hour = `date +%-H`;
        my $time_diff = $current_hour - $hour;
        if ( $time_diff > 24 ) {
                `ehco "RMS ETL Jobs runs $time_diff hours late for $job_name on $system_name!\n" | mail -s  "PROD ETL Delay" PremierEditionOps\@genesys.com,premier-email-alert\@genesyscloud.pagerduty.com,GenesysCXA\@genesys.com`;
                exit;
        }
  }
  elsif ($row =~ m/VCC_DIMENSIONS|IF_AND_IRF|MEDIATION_SEGMENT_FACT|IXN_RESOURCE_STATE_FACT|SM_RES_SESSION_FACT|SM_RES_STATE_FACT|SM_RES_STATE_REASON_FACT|RESOURCE_SKILL_FACT|PROCESS_1/) {
        my @key = split(/-->/, $row);
        my $job_name = $key[0];
        $job_name =~ s/^\s+|\s+$//g;
#        print "$job_name\n";
        my $system_name = $key[1];
        $system_name =~ s/^\s+|\s+$//g;
#        print "$system_name\n";
        my @time_stamp = split(/:/, $row);
        my @time = split(/ /, $time_stamp[2]);
        my $hour = $time[4];
#       print "$hour\n";
        my $current_hour = '';
        if ($job_name eq 'PROCESS_1') {
                $current_hour = `date +%-H -u`;
        }
        else {
                $current_hour = `date +%-H`;
        }
        my $time_diff = $current_hour - $hour;
#       print "$time_diff\n";
        if (( $time_diff > 2) && ($system_name ne 'GENESYS-VOM-03') && ($system_name ne 'chi-genesys-vom')) {
                `echo "VCC ETL Jobs runs $time_diff hours late for $job_name on $system_name!\n" | mail -s  "PROD ETL Delay" PremierEditionOps\@genesys.com,premier-email-alert\@genesyscloud.pagerduty.com,GenesysCXA\@genesys.com`;
                exit;
        }
  }
}
exit;