#!/usr/bin/perl
use warnings;
use strict;
use feature qw|say switch|;
use File::Slurp;
use FindBin;
use lib "$FindBin::Bin";
use DBI qw(:sql_types);
use DateTime;
use Mail::Sendmail;
use Entry;

# input 
my ($uname, $password) = @ARGV;
die unless($uname && $password);

# Time Junk
my $year = DateTime->now->year;
my %months = ( Jul => '07', Aug => '08', Sep => '09' );

# DBI junk
my $dbh = DBI->connect('dbi:mysql:system',$uname,$password);
my $log_file = "/var/log/auth.log";
my @logs = grep(/sshd/, read_file($log_file));

# Email junk
my $subject = "SSHD log Report - ".DateTime->now;
my $body = "The following new error logs were found: \n";
$body .= "-" x 60;
$body .= "\n";

my $new = 0;

my $type;
foreach my $log (@logs)
{
	# Grab Date chunk
	my @arr = (split(/\s/, $log))[0,1,2];
	my $date = join(" ", @arr);
	my $date_string = &parse_date($date);

	# Determine Type
	my $type = &get_type($log);
	next if($type eq "NA");

	# Grab Message
	my $message = &get_message($log);

	my $entry = Entry->new(
		message => $message,
		type => $type,
		date => $date_string
	);

	if(&is_new($entry, $dbh))
	{
		&write_line($entry, $dbh);
		$body .= "-- ".$entry->message;
		$new ++;
	}
}

# Send Report if we have new lines
if($new){ &send_report($subject, $body); }

# Check if line is already in the DB
sub is_new()
{
	my ($entry, $dbh) = @_;
	my $return;

	my $query = "SELECT COUNT(1) FROM log WHERE type=? AND date=? AND message=?";
	my $sth = $dbh->prepare($query);

	$sth->bind_param(1, $entry->type);
	$sth->bind_param(2, $entry->date, SQL_DATETIME);
	$sth->bind_param(3, $entry->message);
	
	$sth->execute();
	if($sth->fetch()->[0]) {
		$return = 0;
	} else {
		$return = 1;
	}
	return $return;
}

# Write a log line to the DB
sub write_line()
{
	my ($entry, $dbh) = @_;
	my $insert = "INSERT INTO log (type, date, message) values (?,?,?)";
	my $sth = $dbh->prepare($insert);

	$sth->bind_param(1, $entry->type);
	$sth->bind_param(2, $entry->date, SQL_DATETIME);
	$sth->bind_param(3, $entry->message);
	$sth->execute();
}

# 'YYYY-MM-DD HH:MM:SS'
#Jul 22 10:59:37
sub parse_date()
{
	my $line = shift;
	my ($month, $day, $time) = split(/\s/, $line);
	unless($month ~~ %months)
	{
		# Die here
		send_report("Unknown month value", "$month not found please fix me!");
		die;		
	}

	if($day < 10)
	{
		$day = sprintf("%01d", $day);
	}

	my $date_string = $year."-".$months{$month}."-".$day." ".$time;
	return $date_string;
}	

sub send_report()
{
	my ($subject, $message) = @_;
	say "Sending: $message";
	sendmail(
		From => 'alpha-helix@wisc.edu',
		To => 'mbio.kyle@gmail.com',
		Subject => $subject,
		Message => $message,
	) or die $Mail::Sendmail::error;
}

sub get_type()
{
	my $log = shift;
	my $type;
	given($log)
	{
		when(/\:\sInvalid user/)
		{
			$type = "INVALID";
		}
		when(/\:\sUser/)
		{
			$type = "ALLOWED";
		}
		when(/\:\sFailed/)
		{
			$type = "PASSWORD";
		}
		default 
		{
			$type = "NA";
		}
	}
	return $type;
}

sub get_message()
{
	my $line = shift;

	# Regex the message
	$line =~ m/^.*sshd\[\d+\]:\s(.*)$/;
	my $message = $1."\n";

	return $message;
}