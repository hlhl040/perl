#!/usr/bin/perl
use strict;
use warnings;

#my $ps_file = '/Users/lehuang/Downloads/AZ_Callrecording_Audit/ps.txt';
#my $cxa_file = '/Users/lehuang/Downloads/AZ_Callrecording_Audit/Call_Reports.txt';
#my $sm_file = '/Users/lehuang/Downloads/AZ_Callrecording_Audit/mssql-result.txt';
my $ps_file = '/home/MSTRFTP/AZ_Callrecording_Audit/ps.txt';
my $cxa_file = '/home/MSTRFTP/AZ_Callrecording_Audit/Call_Reports.txt';
my $sm_file = '/home/MSTRFTP/AZ_Callrecording_Audit/mssql-result.txt';
my $ps_index = 0;
my $cxa_index = 0;
my $sm_index = 0;
my @ps_array = ();
my @cxa_array = ();
my @sm_array = ();

open(my $ps_fh, '<:encoding(UTF-8)', $ps_file)
  or die "Could not open file '$ps_file' $!";

open(my $cxa_fh, '<:encoding(UTF-16)', $cxa_file)
  or die "Could not open file '$cxa_file' $!";

open(my $sm_fh, '<:encoding(UTF-8)', $sm_file)
  or die "Could not open file '$sm_file' $!";


while (my $row = <$ps_fh>) {
  chomp $row;
  my @tmp_array = split(/,/, $row);
  my $tmp_callguid = $tmp_array[7];
  $ps_array[$ps_index] = $tmp_callguid;

  $ps_index++;
}

while (my $row = <$cxa_fh>) {
  chomp $row;
  if ($row =~/^(\d).*/i) {
    my @tmp_array = split(/,/, $row);
    my $tmp_callguid = $tmp_array[1];
    $cxa_array[$cxa_index] = $tmp_callguid;
    $cxa_index++;
  } 
}

while (my $row = <$sm_fh>) {
  chomp $row;
  $row =~ s/\s+//g;
  if ($row =~/^(\d).*/i) {
    $sm_array[$sm_index] = $row;
    $sm_index++;
  }
}

&Insert_sort(\@sm_array);
&Insert_sort(\@cxa_array);
&Insert_sort(\@ps_array);

#print "@sm_array";
print "Missing Calls in PS...\n";
for (my $i=0, my $j=0;$i<@cxa_array && $j<@ps_array;) {
  if ($cxa_array[$i] < $ps_array[$j]) {
#    print "$cxa_array[$i]\n";
    &Findcall_cxa($cxa_array[$i]);
    $i++;  
  }
  elsif ($cxa_array[$i] > $ps_array[$j]) {
    $j++;
  }
  else {
    $i++;
    $j++;
  }
}
print "Missing Calls in SM...\n";
for (my $i=0, my $j=0;$i<@ps_array && $j<@sm_array;) {
  my $tmp = -1;
  if ($i>0) {
    $tmp = $ps_array[$i-1]; 
  }
  if ($ps_array[$i] < $sm_array[$j]) {
#    print "$ps_array[$i]\n";
    if($ps_array[$i]!=$tmp) {
      &Findcall_ps($ps_array[$i]);
    }   
    $i++;  
  }
  elsif ($ps_array[$i] > $sm_array[$j]) {
    $j++;
  }
  else {
    $i++;
    $j++;
  }
}

sub Insert_sort {
  my $data = shift;
    for my $index ( 1 .. scalar @$data - 1 ){
       my $i = $index - 1 ;
       my $value = $data->[$index];
       while ( $i >= 0 ){
          if ( $value < $data->[$i] ){
             $data->[$i+1] = $data->[$i];
          }
          else{
            last;
          }
          $i--;
       }
       $data->[$i+1] = $value;
    }

}

sub Findcall_cxa {
  my $callguid = shift;
#  print "$callguid\n";
  seek $cxa_fh,0,0;
  while (my $row = <$cxa_fh>) {
    chomp $row;
#    print "$row\n";
    if ($row =~/$callguid/i) {
      print "$row\n";
      return;
    } 
  }
}

sub Findcall_ps {
  my $callguid = shift;
#  print "$callguid\n";
  seek $ps_fh,0,0;
  while (my $row = <$ps_fh>) {
    chomp $row;
#    print "$row\n";
    if ($row =~/$callguid/i) {
      print "$row\n";
      return;
    } 
  }
}