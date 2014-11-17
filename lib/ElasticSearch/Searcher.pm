package ElasticSearch::Searcher;
use Moo;
use Mojo::UserAgent;
use feature qw|say|;
use Time::HiRes qw|time|;

has es_app => (
    is => "rw",
    default => sub { "myapp" }
);
has es_index => (
    is => "rw",
    default => sub { "teste" }
);

has ua => (
    is => "rw",
    default => sub {
        my $self = shift;
        my $ua = Mojo::UserAgent->new;
        $ua->transactor->name('Mozilla/5.0');
        $ua;
    }
);

sub search {
    my $self = shift;
    my $query = shift;
    return $self->ua->post( "http://localhost:9200/myapp/_search", json => $query )
        ->res
        ->json
        ;

# POST http://localhost:9200/myapp/_search

#   {
#   "query":{"match":{
#   "titulo" : {
#     "query" : "fone trabalho",
#     "operator" : "and"
#   }

#   }}
#}


#       {
#           "match" : {
#               "message" : {
#                   "query" : "this is a test",
#                   "operator" : "and"
#               }
#           }
#       }
#       {
#           index => 'myapp',
#           type  => 'product',
#           query => {
#               "bool" => {
#                   "must" => [
#                       { "text" =>  { "name" => "asus" } },
#                       { "range" => { "price_low" => { "gte" => 1800.15 } } },
#                       { "range" => { "price_high" => { "lte" => 2500.61 } } }
#                   ]
#               }
#           }
#       }
}

#   my $searcher = Searcher->new;
#   my $start = time;
#   $searcher->search( 
#   {
#       "query" => {
#           "match" => {
#               "titulo" => {
#                   "query"     => "macbook apple",
#                   "operator"  => "and"
#               }
#           }
#       }
#   } 
#   );
#   my $end   = time;
#   print 'Took: ', ( $end - $start ) , "\n";

1;
