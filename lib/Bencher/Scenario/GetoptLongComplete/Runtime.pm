package Bencher::Scenario::GetoptLongComplete::Runtime;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use File::Slurper qw(write_text);
use File::Temp qw(tempdir);

my $tempdir;

our $scenario = {
    summary => 'Benchmark runtime of simple Getopt::Long::Complete-based '.
        'CLI script',
    modules => {
    },
    participants => [
    ],
    before_list_participants => sub {
        my %args = @_;

        my $sc = $args{scenario};
        my $pp = $sc->{participants};

        return if $tempdir;
        my $keep = $ENV{DEBUG_KEEP_TEMPDIR} ? 1:0;
        $tempdir = tempdir(CLEANUP => !$keep);

        my @script_content;
        push @script_content, "#!$^X\n";
        push @script_content, <<'_';
use 5.010;
use strict;
use warnings;
use Getopt::Long::Complete;

GetOptions(
    'help|h'    => sub { },
    'version|v' => sub { },
    'value=s'   => sub { },
    'file=s'    => sub { },
);
_
        write_text("$tempdir/cli1", join("", @script_content));
        chmod 0755, "$tempdir/cli1";

        push @$pp, {
            type => 'command',
            name => "default",
            cmdline => ["$tempdir/cli1"],
        };

        my $i = 0; for (@$pp) { $_->{seq} = $i++ }
    },
    #datasets => [
    #],
};

1;
# ABSTRACT:
