#!/usr/bin/perl
use warnings;
use strict;
use feature qw|say|;
use File::Slurp;
use Data::Printer;

my $sym_dir = shift;
$sym_dir.="/";

my @dirty_dirs = grep(!/^\/(usr|bin|sbin|\.git)/, split(/:/, `echo \$PATH`));
my @executables;

# Fetch a list of all executables from the various path entries
foreach my $dir (@dirty_dirs)
{
	chomp($dir);
	
	# grab only files (not -d) that are executable (-x)
	# append directory and push to master list
	push(
		@executables, 
		map {
			(-x $dir."/".$_ and not(-d $dir."/".$_ )) ? $dir."/".$_ : () 
		} read_dir($dir)
	);
}

# Set up the directory
mkdir $sym_dir;

foreach my $executable (@executables)
{
	$executable =~ m/\/([^\/]+)$/;
	my $filename = $1;
	p($filename);
	symlink $executable, $sym_dir.$filename;
}

say "Symlink folder created at: $sym_dir";
say "Edit .bashrc too:";
say "export PATH=\"\$PATH:/sbin/:/usr/sbin/:$sym_dir\"";
say "export SYMDIR=\"$sym_dir\"";
