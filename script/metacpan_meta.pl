#!/usr/bin/perl
use strict;
use warnings;
use 5.010;

use Data::Dumper;
use MetaCPAN::API;
my $mcpan = MetaCPAN::API->new;

my ($size, $pauseid) = @ARGV;
die "Usage: $0 N [PAUSEID]  (N = number of most recent distributions)\n" if not $size;

my $q = 'status:latest';
if ($pauseid) {
    $q .= " AND author:$pauseid";
}

my $r = $mcpan->fetch( 'release/_search',
    q => $q,
    sort => 'date:desc',
    fields => 'distribution,date,license,author,resources.repository',
    size => $size,
);

my %licenses;
my @missing_license;
my @missing_repo;
my %repos;
my $found = 0;
my $hits = scalar @{ $r->{hits}{hits} };
foreach my $d (@{ $r->{hits}{hits} }) {
    my $license = $d->{fields}{license};
    my $distro  = $d->{fields}{distribution};
    my $author  = $d->{fields}{author};
    my $repo    = $d->{fields}{'resources.repository'};

    if ($license and $license ne 'unknown') {
        $found++;
        $licenses{$license}++;
    } else {
        push @missing_license, [$distro, $author];
    }

    if ($repo and $repo->{url}) {
        if ($repo->{url} =~ m{http://code.google.com/}) {
            $repos{google}++;
        } elsif ($repo->{url} =~ m{git://github.com/}) {
            $repos{github_git}++;
        } elsif ($repo->{url} =~ m{http://github.com/}) {
            $repos{github_http}++;
        } elsif ($repo->{url} =~ m{https://github.com/}) {
            $repos{github_https}++;
        } elsif ($repo->{url} =~ m{https://bitbucket.org/}) {
            $repos{bitbucket}++;
        } elsif ($repo->{url} =~ m{git://git.gnome.org/}) {
            $repos{git_gnome}++;
        } elsif ($repo->{url} =~ m{https://svn.perl.org/}) {
            $repos{svn_perl_org}++;
        } elsif ($repo->{url} =~ m{git://}) {
            $repos{other_git}++;
        } elsif ($repo->{url} =~ m{\.git$}) {
            $repos{other_git}++;
        } elsif ($repo->{url} =~ m{https?://svn\.}) {
            $repos{other_svn}++;
        } else {
            $repos{other}++;
            say "Other repo: $repo->{url}";
        }
    } else {
        push @missing_repo, [$distro, $author];
    }
}
@missing_license = sort {$a->[0] cmp $b->[0]} @missing_license;
@missing_repo    = sort {$a->[0] cmp $b->[0]} @missing_repo;
say "Total asked for: $size";
say "Total received : $hits";
say "License found: $found, missing " . scalar(@missing_license);
say "Repos missing: " . scalar(@missing_repo);
say "-" x 40;
print Dumper \%repos;
print Dumper \%licenses;
print 'missing_licenses: ' . Dumper \@missing_license;
print 'missing_repo: ' . Dumper \@missing_repo;


