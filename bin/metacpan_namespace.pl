#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

use Data::Dumper   qw(Dumper);
use Getopt::Long   qw(GetOptions);
use MetaCPAN::API;
my $mcpan = MetaCPAN::API->new;

my %opt = (size => 2);
GetOptions(\%opt, 'module=s', 'distro=s', 'size=i') or usage();
usage() if not ($opt{module} xor $opt{distro});

sub usage {
    die <<"END_USAGE";
Usage: $0 --module Module::Name [--size LIMIT]
    or $0 --distro Distro-Name [--size LIMIT]

    LIMIT defaults to 2
END_USAGE
}


# List all the distributions under a name-space (with a given prefix)
if ($opt{distro}) {
    my $r = $mcpan->post(
        'release',
        {
            query  => { match_all => {} },
            filter => { "and" => [
                    { prefix => { distribution => $opt{distro} } },
                    { term   => { status => 'latest' } },
            ]},
            fields => [ 'distribution', 'date' ],
            size => $opt{size},
        },
    );
    #print Dumper $r;
    print Dumper [map {$_->{fields}} @{ $r->{hits}{hits} }];
}

# List all the modules under a name::space (with a given prefix)
if ($opt{module}) {
    my $r = $mcpan->post(
        'module',
        {
            query  => { match_all => {} },
            filter => { "and" => [
                    { prefix => { 'module.name' => $opt{module} } },
                    #{ prefix => { distribution => 'Perl-Critic' } },
                    { term   => { status => 'latest' } },
            ]},
            fields => [ 'distribution', 'date', 'module.name' ],
            size => $opt{size},
        },
    );
    #print Dumper $r;
    print Dumper [map {$_->{fields}} @{ $r->{hits}{hits} }];
}


