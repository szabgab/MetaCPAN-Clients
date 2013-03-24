#!/usr/bin/env perl
use v5.14;
use strict;
use warnings;
use HTTP::Tiny;
use JSON;
use Path::Tiny;
 
my $list = shift
  or die "Usage: $0 <file>\n";
 
my $token = "EfABjkq5qU0lXXXb_Be9TdwqB2I";
 
my $ua = HTTP::Tiny->new;
 
for my $d ( reverse path($list)->lines( { chomp => 1 } ) ) {
    my ($dist, $author, $release) = split ' ', $d;
    my $post = to_json( { distribution => $dist, author => $author, release => $release } );
    my $res = $ua->post(
        "https://api.metacpan.org/user/favorite?access_token=$token",
        { content => $post, headers => {'content-type' => 'application/json' }},
    );
    if ( $res->{success} ) {
        say "Favorited $dist";
    }
    else {
        warn "Could not favorite $dist ($res->{status} $res->{reason})\n";
    }
}

