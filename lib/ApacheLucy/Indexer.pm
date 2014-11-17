package ApacheLucy::Indexer;
use Moo;
use strict;
use warnings;
use Lucy::Simple;
#use File::Spec::Functions qw( catfile );
use Lucy::Plan::Schema;
use Lucy::Plan::FullTextType;
use Lucy::Analysis::PolyAnalyzer;
use Lucy::Index::Indexer;
use Lucy::Plan::StringType;

has path_to_index => ( is => 'rw', default => sub { './t/lucy_index' } );
has file          => ( is => 'rw', default => sub { 'file' } );
has indexer       => ( is => 'rw' );

sub index {
    my $self = shift;
    my $lines = shift;
    foreach my $line (@{$lines}) {
#       warn $line;
#       chop $line;
        $self->indexer->add_doc({
            title => $line,
        });
    }
    $self->indexer->commit;
}

sub create_index {
    my $self = shift;
    # Create Schema.
    my $schema = Lucy::Plan::Schema->new;

    #   default polyanaliser
    #   my $polyanalyzer = Lucy::Analysis::PolyAnalyzer->new(
    #       language => 'en',
    #   );
    #   my $type = Lucy::Plan::FullTextType->new(
    #       analyzer => $polyanalyzer,
    #   );

    #case sensitive search
    #   my $tokenizer = Lucy::Analysis::RegexTokenizer->new;
    #   my $type = Lucy::Plan::FullTextType->new(
    #       analyzer => $tokenizer,
    #   );

    my $case_folder  = Lucy::Analysis::CaseFolder->new;
    my $tokenizer    = Lucy::Analysis::RegexTokenizer->new;
    my $stemmer      = Lucy::Analysis::SnowballStemmer->new( language => 'en' );
    my $stopfilter = Lucy::Analysis::SnowballStopFilter->new( 
        language => 'en',
    );
    my $polyanalyzer = Lucy::Analysis::PolyAnalyzer->new(
        analyzers => [ $case_folder, $tokenizer, $stopfilter, $stemmer ],
    );
    my $type = Lucy::Plan::FullTextType->new(
        analyzer => $polyanalyzer,
    );

    #$schema->spec_field( name => 'category',    type => Lucy::Plan::StringType->new( stored => 1 ) );
    $schema->spec_field( name => 'title',       type => $type );
    #$schema->spec_field( name => 'content',     type => $type );
    #$schema->spec_field( name => 'url',         type => Lucy::Plan::StringType->new( indexed => 0 ) );

    my $indexer = Lucy::Index::Indexer->new(
        index    => $self->path_to_index,
        schema   => $schema,
        create   => 1,
        truncate => 1,
    ); 
    $self->indexer( $indexer );
}

sub start_fresh {
    my $self = shift;
    system 'rm', '-rf', $self->path_to_index;
    $self->create_index;
}

1;
