package ElasticSearch::Indexer;
use File::Slurp qw|read_file|;
use feature qw|say|;
use Mojo::UserAgent;
use Moo;
use Try::Tiny;
use Mojo::IOLoop;

#   has attrs => (
#       is => "rw",
#       default => sub {
#   #       "lat_highest"=> {
#   #         "type"=> "double"
#   #       },
#   #       "sub_prefeitura"=> {
#   #         "type"=> "string"
#   #       },
#   #       is_deleted => {
#   #           mapping => {
#   #               "type"=> "integer",
#   #           },
#   #       },
#   #       'site' => {
#   #           req => 1,
#   #           mapping => { #mapping is the fields settings for elastic search
#   #              type => 'string',
#   #               "index" => 'not_analyzed',
#   #           },
#   #       },
#   #       'quartos' => {
#   #           req => 1,
#   #           mapping => {
#   #               "type" => "integer",# Can be float, double, integer, long, short, byte
#   #               "null_value" => 0
#   #           },
#   #       },
#   #       descricao => {
#   #           mapping => {
#   #              type => 'string',
#   #              "index" => 'analyzed',
#   #           },
#   #       },
#   #       "location" => {
#   #           mapping => {
#   #               "type" => "geo_point",
#   #           },
#   #       },
#   #       updated => {
#   #           "postDate" => {
#   #               "type" => "date",
#   #               "format" => "YYYY-MM-dd HH:mm:ss"
#   #           }
#   #       },
#           titulo => {
#               mapping => {
#                  type => 'string',
#                  "index" => 'analyzed',
#               },
#           },
#       }
#   );

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

sub delete_app {
    my ( $self ) = @_;
    say "Index delete... lets start fresh";
    try {
        $self->ua->delete( 'http://localhost:9200/' . $self->es_app => { DNT => 1 } )
            ;
    } catch {
        warn "$_";
    }
}

sub create_app {
    my ( $self, $index_name ) = @_;

#   my $mapping = {};
#   my $attrs = $self->attrs;
#   foreach my $attr ( keys %$attrs ) {
#       warn $attr;
#       $mapping->{ $attr } = $attrs->{ $attr }->{ mapping }
#           if exists $attrs->{ $attr }->{ mapping };
#   }

    $self->ua->put('http://localhost:9200/' . $self->es_app, {} , json => {
        "settings"=> {
            "analysis"=> {
                "analyzer"=> {
                    "index_analyzer"=> {
                        "tokenizer"=> "standard",
                        "filter"=> ["standard", "my_delimiter", "lowercase", "stop", "asciifolding", "porter_stem"]
                    },
                    "search_analyzer"=> {
                        "tokenizer"=> "standard",
                        "filter"=> ["standard", "lowercase", "stop", "asciifolding", "porter_stem"]
                    }
                },
                "filter"=> {
                    "my_delimiter"=> {
                        "type"=> "word_delimiter",
                        "generate_word_parts"=> 1,
                        "catenate_words"=> 1,
                        "catenate_numbers"=> 1,
                        "catenate_all"=> 1,
                        "split_on_case_change"=> 1,
                        "preserve_original"=> 1,
                        "split_on_numerics"=> 1,
                        "stem_english_possessive"=> 1
                    }
                }
            }
        }
    } );

    $self->ua->put('http://localhost:9200/'.$self->es_app.'/'.$self->es_index.'/_mapping',
        {},
        json => {
            $self->es_index => {
                "properties" => {
                    title => {
                        type => 'string',
                        index => 'analyzed',
                        index_analyzer => 'index_analyzer',
                        search_analyzer => 'search_analyzer',
                    },
                },
            }
        }
    );
}

sub index {
    my $self  = shift;
    my $lines = shift;
#   my @lines = read_file "/home/hernan/p/lucy_moraga/try.lisp";
    say "Indexing start";
    my $count = 0;
    my $total = scalar @$lines;
    foreach my $line (@$lines) {
#       chop $line;
        $count++;
#       warn "$count/$total";
#       say $line;

        my $res = $self->ua->put(
            'http://localhost:9200/' . $self->es_app . '/' . $self->es_index.'/'.$count,
            json => {
                title => $line
            }
        )->res;
#       $res->content->get_body_chunk;
    }
}

sub start_fresh {
    my $self = shift;
    $self->delete_app;
    $self->create_app;
    $self;
}

1;
