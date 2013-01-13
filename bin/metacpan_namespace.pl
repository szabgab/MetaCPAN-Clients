#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

use Data::Dumper;
use MetaCPAN::API;
my $mcpan = MetaCPAN::API->new;

my ($type, $name, $size) = @ARGV;
$size ||= 2;
usage() if not $name;
usage() if $type ne 'module' and $type ne 'distro';


sub usage {
    die <<"END_USAGE";
Usage: $0 module Module::Name [LIMIT]
    or $0 distro Distro-Name [LIMIT]

    LIMIT defaults to 2
END_USAGE
}


# List all the distributions under a name-space (with a given prefix)
if ($type eq 'distro') {
    my $r = $mcpan->post(
        'release',
        {
            query  => { match_all => {} },
            filter => { "and" => [
                    { prefix => { distribution => $name } },
                    { term   => { status => 'latest' } },
            ]},
            fields => [ 'distribution', 'date' ],
            size => $size,
        },
    );
    #print Dumper $r;
    print Dumper [map {$_->{fields}} @{ $r->{hits}{hits} }];
}

if ($type eq 'module') {
    my $r = $mcpan->post(
        'module',
        {
            query  => { match_all => {} },
            filter => { "and" => [
                    { prefix => { 'module.name' => $name } },
                    #{ prefix => { distribution => 'Perl-Critic' } },
                    { term   => { status => 'latest' } },
            ]},
            fields => [ 'distribution', 'date', 'module.name' ],
            size => $size,
        },
    );
    #print Dumper $r;
    print Dumper [map {$_->{fields}} @{ $r->{hits}{hits} }];
}


