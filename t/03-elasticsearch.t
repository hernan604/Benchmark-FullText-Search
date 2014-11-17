use Test::More;
use Tie::File;
use Fcntl 'O_RDONLY';
use ElasticSearch::Indexer;
use ElasticSearch::Searcher;
my $filename = 'file';
tie my @lines, 'Tie::File', $filename, mode => O_RDONLY or die 'Could not open filename';
my $es_indexer = ElasticSearch::Indexer->new;
$es_indexer->start_fresh;
$es_indexer->index( \@lines );

my @expected_hits = grep { /orange|project/ig } @lines;

sleep 1; #elasticsearch needs some time to finish indexing

my $es_searcher = ElasticSearch::Searcher->new;
my $res = $es_searcher->search({
    "query" => {
        "match" => {
            "title" => {
                "query"     => "orange project",
                "operator"  => "or"
            }
        }
    }
});

ok( $res->{hits}->{total} == @expected_hits , 'search correct' );

done_testing;
