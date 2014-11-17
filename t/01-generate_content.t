use Test::More;
use strict;
use warnings;
use ContentGenerator;
use DDP;
my $filename = 'file';
my $lines_wanted = 10000;
my $content_generator = ContentGenerator->new( lines => $lines_wanted, filename => $filename );
$content_generator->get_tvshow;
$content_generator->generate_file;

use Tie::File;
tie my @lines, 'Tie::File', $filename or die "could not open $filename";

ok( scalar @lines == $lines_wanted, 'file generated correctly');

done_testing;
