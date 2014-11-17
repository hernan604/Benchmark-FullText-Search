package ApacheLucy::Searcher;
use Moo;
use strict;
use warnings;
use Lucy::Search::IndexSearcher;
use Lucy::Search::QueryParser;
use Lucy::Search::TermQuery;
use Lucy::Search::ANDQuery;

has path_to_index => ( is => 'rw', default => sub { './t/lucy_index' } );

sub search {
    my $self        = shift;
    my $q           = shift; #ie apple OR banana
    my $offset      = 0;
    my $page_size   = 10;

    my $searcher = Lucy::Search::IndexSearcher->new(
        index => $self->path_to_index,
    );
    my $qparser  = Lucy::Search::QueryParser->new(
        schema => $searcher->get_schema,
    );
    my $query = $qparser->parse($q);

    my $start = time;
    my $hits = $searcher->hits(
        query      => $query,
        offset     => $offset,
        num_wanted => $page_size,
    );
    my $end   = time;
    print 'Took: ', ( $end - $start ) , "\n";


#   my $result = {
#       total => 
#   };

#   warn qq|HIT COUNT: |.$hits->total_hits;

#   while ( my $hit = $hits->next ) {
#       my $score = sprintf( "%0.3f", $hit->get_score );
#       print qq|
#           score   : $score
#           title   : $hit->{ title }
#           |,"\n";
#   }
    $hits;
}

1;
