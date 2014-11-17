package ContentGenerator;
use strict;
use warnings;
use Moo;
use Mojo::UserAgent;
use URI;
use utf8;
use DDP;
use feature qw|say|;

has shows => ( is => 'rw', default => sub { [ ] } );
has lines => ( is => 'rw', default => sub { 1000 } );
has filename => ( is => 'rw', default => sub { 'file' } );

sub get_tvshow {
    my $self = shift;
    my $url = 'http://epguides.com/menu/current.shtml';
    my $ua = Mojo::UserAgent->new;
    $ua->transactor->name('Mozilla/5.0');
    my $res = $ua->get( $url )->res;
    $res->dom->find('.tdmenu a')->each( sub {
        my $show = $_->text;
        push @{ $self->shows }, $show;
    });
}

sub generate_file {
    my $self = shift;
    open FH, ">", $self->filename;
    say qq|Generating a file with $self->lines lines. Each line contains between 5 and 15 shows.|;    
    for ( 1 .. $self->lines ) {
        my $wanted_shows = int rand(10)+5; #minimum 5 shows, max 5+10
        my @selected_shows = ();
        my @selected = ();
        while ( scalar @selected_shows  < $wanted_shows ) {
            my $index = int rand scalar @{ $self->shows };
            if ( ! grep /$index/, @selected ) {
                push @selected, $index;
                push @selected_shows, $self->shows->[ $index ];
#warn p @selected_shows;
            }
        }
#warn p @selected_shows;
        my $line = join(" ", @selected_shows )."\n";
        print FH $line;
    }
    close FH;
}

1;
