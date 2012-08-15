# ------------------------------------------------------------------------------
# $Id$
# ------------------------------------------------------------------------------
# Seccubus perl module. This is where most of the real logic is
# ------------------------------------------------------------------------------

package SeccubusDB;

=head1 NAME $RCSfile: SeccubusDB.pm,v $

This Pod documentation generated from the module SeccubusDB gives a list of all 
functions within the module.

=cut

use Exporter;
use DBI;

#use SeccubusConfig;

@ISA = ('Exporter');

@EXPORT = qw ( 
		open_database
		sql
	);

use strict;
use Carp;

sub open_database();
sub sql(@);

my (
	$dbh,
   );

###############################################################################
# Database helper functions
###############################################################################

=head1 Database helper functions

=head2 open_database

This function opens the database specified in config.xml and assigns the
dbh to the $dbh variable unless the database is allready open

=over 2

=item Parameters

=over 4

=item none

=back

=item Returns

None, but sets global variable $dbh

=item Checks

Global variable $dbh to see it the database is allready open.

=back

=cut

sub open_database() {
	unless ( $dbh ) {	# Skip database open when database is allready 
				# open
		my $config = SeccubusV2::get_config();
		my $dsn = "DBI:" . $config->{database}->{engine} 
			. ":database=" . $config->{database}->{database} 
			. ";host=" . $config->{database}->{host} 
			. ";port=" . $config->{database}->{port};
		$dbh = DBI->connect($dsn, $config->{database}->{user}, $config->{database}->{password});
	}
	return $dbh;
}

=head2 sql

This is a wrapper function to execute SQL. This function add an abstrction to 
the perl DBI calls so that support for multiple databases can be added more
easily later

=over 2

=item Parameters (named parameters via hash)

=over 4

=item return - determimes what value is returned by the funtion:

ref - returns the result of fetchall_arrayref (default)

id - return the inserted id

handle - return the reference to the statement handler

array - returns the result of fetchrow_array

rows - number of rows effected by last update statement

=item query - the SQL query (mandatory)

=item values - Arrayref to the values that need to be bound after the prepare statement

=back

=item Returns

The return value is determined by the return parameter

=item Checks

If statement prepares and executes well

=back

=cut

sub sql(@) {
	my %arg = @_;
	$arg{return} = "ref" unless $arg{return};

	confess "No query parameter specified" unless exists $arg{query};
	$dbh = open_database();
	confess("Unable to open database") unless $dbh;
	my $sth = $dbh->prepare($arg{query}) or
		confess "Problem with preparing sql statement $arg{query}\n" . $dbh->errstr; 
	if ( exists $arg{values} ) {
		my $count = 1;
		foreach my $param ( @{$arg{values}} ) {
			$sth->bind_param( $count++, $param) or
				confess "Unable to bind prameter $count ($param) to query $arg{query}\n" . $sth->errstr;
		}
	}
	$sth->execute() or
		confess "Problem with execution of sql statement $arg{query}\n" . $sth->errstr;
	if ( $arg{return} eq "id" ) {		# We need to return the inserted
						# ID
		return $sth->{mysql_insertid};  # This is MySQL specific
	} elsif ($arg{return} eq "rows") {	# Return the number of rows changed by the last command
		return $sth->rows();	
	} elsif ( $arg{return} eq "handle" ) {
		return $sth;
	} elsif ( $arg{return} eq "array" ) {
		return $sth->fetchrow_array();
	} else {
		return $sth->fetchall_arrayref();
	}
}

# Close the PM file.
return 1;