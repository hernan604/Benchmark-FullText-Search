use Test::More;
use ContentGenerator;
use DDP;

use Tie::File;
use Fcntl 'O_RDONLY';

use ApacheLucy::Indexer;
use ApacheLucy::Searcher;

use ElasticSearch::Indexer;
use ElasticSearch::Searcher;

use Benchmark qw|:all :hireswallclock|;

#create some content
my $filename = 'file';
my $lines_wanted = 10000;
my $content_generator = ContentGenerator->new( lines => $lines_wanted, filename => $filename );
$content_generator->get_tvshow;
$content_generator->generate_file;

my $items_found = {};

#read renerated content
my $filename = 'file';
tie my @lines, 'Tie::File', $filename, mode => O_RDONLY or die 'Could not open filename';


my $result_index =  cmpthese(1, {
    'Lucy Indexer'          => lucy_indexer,
    'ElasticSearch Indexer' => es_indexer,
});
$result_index;

sleep 1;

my $result_search = cmpthese(100, {
    'Lucy Searcher'          => lucy_searcher,
    'ElasticSearch Searcher' => es_searcher,
});
$result_search;


#lucy indexer
sub lucy_indexer {
    my $lucy_indexer = ApacheLucy::Indexer->new;
    $lucy_indexer->start_fresh;
    $lucy_indexer->index( \@lines );
}


#lucy searcher
sub lucy_searcher {
    my $lucy_searcher = ApacheLucy::Searcher->new;
    $items_found->{ lucy } = $lucy_searcher->search('orange OR project');
}


#es indexer
sub es_indexer {
    my $es_indexer = ElasticSearch::Indexer->new;
    $es_indexer->start_fresh;
    $es_indexer->index( \@lines );
}


#es searcher
sub es_searcher {
    my $es_searcher = ElasticSearch::Searcher->new;
    $items_found->{ es } = $es_searcher->search({
        "query" => {
            "match" => {
                "title" => {
                    "query"     => "orange project",
                    "operator"  => "or"
                }
            }
        }
    });
}

ok( $items_found->{es}->{hits}->{total} == $items_found->{lucy}->total_hits , 'found same amount of items' );

done_testing;
