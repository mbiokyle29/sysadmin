#!/usr/bin/perl
# add sym link to sym dir
# avoiding path ickyness
use warnings;
use strict;
use feature qw|say|;
use File::Slurp;
use Data::Printer;
use Env;

my $executable = shift;
$executable =~ m/\/([^\/]+)$/;
my $filename = $1 or die "Did you give full path to the executable?";

die "SYMDIR env variable not set!" unless($SYMDIR);
say "Setting $executable to $SYMDIR $filename";
symlink $executable, $SYMDIR.$filename; 
