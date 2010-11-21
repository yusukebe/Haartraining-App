#!/usr/bin/perl
use strict;
use warnings;
use Coro;
use Coro::LWP;
use LWP::UserAgent;
use WebService::Simple;
use Path::Class qw/dir file/;
use Digest::MD5 qw/md5_hex/;
use utf8;

my $query = 'おっぱい';
my $per_page = 50;
my $dir = './images';
my $yahoo = WebService::Simple->new(
    base_url => 'http://search.yahooapis.jp/ImageSearchService/V1/imageSearch',
    param => {
        appid => $ENV{YAHOO_APPID},
        adult_ok => 1,
        results => $per_page,
        format => 'jpeg',
    }
);

my $ua = LWP::UserAgent->new;
$ua->show_progress(1);
$ua->timeout(10);

for ( my $page = 1; $page < 100; $page++ ){
    search( $query, $page );
}

sub search {
    my ( $query , $page ) = @_;
    my $start = ( $page - 1 ) * 10 + 1;
    my $res = $yahoo->get({ query => $query, start => $start });
    my $ref = $res->parse_response();
    my @coros;
    for my $r ( @{$ref->{Result}} ){
        push @coros, async {
            $ua->mirror( $r->{Url}, dir($dir)->file(md5_hex($r->{Url}) . '.jpg' ) );
        };
    }
    $_->join for @coros;
}
