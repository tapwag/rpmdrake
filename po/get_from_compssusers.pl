#!/usr/bin/perl

use MDK::Common;

our @miss = (qw(Server Workstation), 'Graphical Environment');
our @exceptions = qw(Development Configuration Mail);

my $po = $ARGV[0];
my $drakxfile = "../../../gi/perl-install/install/share/po/$po";
my $libdrakxfile = "../../../gi/perl-install/share/po/$po";

-e $drakxfile or exit 0;
-e $libdrakxfile or exit 0;

my ($enc_rpmdrake) = cat_($po) =~ /Content-Type: .*; charset=(.*)\\n/i;
my ($enc_drakx)    = cat_($drakxfile) =~ /Content-Type: .*; charset=(.*)\\n/;
uc($enc_rpmdrake) ne uc($enc_drakx) and die "Encodings differ for $po! rpmdrake's encoding: $enc_rpmdrake; drakx's encoding: $enc_drakx";
print q(# autogenerated by get_from_compssusers.pl
#
msgid ""
msgstr ""
"Project-Id-Version: rpmdrake\n"
"Report-Msgid-Bugs-To: \n"
"POT-Creation-Date: 2006-11-30 14:17+0100\n"
"PO-Revision-Date: 2006-11-26 00:50+0100\n"
"Last-Translator: nobody <nobody@nowhere.no>\n"
"Language-Team: unknown\n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"

);

our $current;
our $entry;
foreach my $line (cat_($drakxfile, $libdrakxfile)) {
#foreach my $line (cat_($drakxfile)) {
    $line =~ m|^\Q#: share/compssUsers.pl:| || $line =~ m|^msgid "([^"]+)"| && member($1, @miss) and do {
	$current = 'inside';
        $entry = "# DO NOT BOTHER TO MODIFY HERE, BUT IN DRAKX PO\n";
        $line =~ m|^#:| or $entry .= "#: share/compssUsers.pl:999\n";
    };
    $current eq 'inside' and $entry .= $line;
    $line =~ m|^msgid "([^"]+)"| && member($1, @exceptions) and $current = 'outside';
    $line =~ m|^$| && $current eq 'inside' and do {
	$current = 'outside';
        print $entry;
    };
}
