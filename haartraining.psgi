use strict;
use warnings;
use Plack::Request;
use Plack::App::URLMap;
use Path::Class qw/file dir/;
use Plack::Builder;

my $dir      = dir('./data/images');
my $positive = file('./data/positive.dat');
my $negative = file('./data/negative.dat');

my $images;
my $images_done;

check($positive);
check($negative);

sub check {
    my $file = shift;
    for my $line ( $file->slurp() ) {
        my ($image) = $line =~ /([a-z0-9]+\.jpg)\s/;
        push @$images_done, "$image";
    }
}

for my $file ( $dir->children ) {
    next if $file->is_dir;
    next unless $file->basename =~ /\.jpg$/;
    next if grep { $_ eq $file->basename } @$images_done;
    push @$images, $file->basename;
}

my $urlmap   = Plack::App::URLMap->new;
my $redirect = sub {
    my $image = shift @$images;
    my $url   = "/html/index.html?image=$image";
    return [ 302, [ 'Location' => $url ], [] ];
};
$urlmap->map( '/', $redirect );

my $post = sub {
    my $env   = shift;
    my $req   = Plack::Request->new($env);
    my $param = $req->param('param');
    my $image = $req->param('image');
    if ($param) {
        $param =~ s/,/ /g;
        my $fh = $positive->open('a');
        $fh->print("images/$image $param\n");
        $fh->close;
    }
    else {
        my $fh = $negative->open('a');
        $fh->print("images/$image\n");
        $fh->close;
    }
    return [ 200, [], [''] ];
};
$urlmap->map( '/post', $post );

my $app = $urlmap->to_app;

builder {
    enable "Plack::Middleware::Static",
      path => qw{^/html/},
      root => './';
    enable "Plack::Middleware::Static",
      path => qw{^/images/},
      root => './data/';
    $app;
};
