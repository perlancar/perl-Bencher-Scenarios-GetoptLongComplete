package Bencher::Scenario::GetoptLongComplete::Completion;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Bencher::ScenarioUtil::Completion qw(make_completion_participant);
use File::Slurper qw(write_text);
use File::Temp qw(tempdir);

my $tempdir;

our $scenario = {
    summary => 'Benchmark completion response time of '.
        'Getopt::Long::Complete-based CLI script',
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
use Getopt::Long::Complete qw(GetOptionsWithCompletion);

GetOptionsWithCompletion(
    sub {
        require Complete::Util;
        my %args = @_;
        my $word = $args{word};
        my $type = $args{type};
        my $opt  = $args{opt};
        if ($type eq 'optval' && $opt eq '--value') {
            return Complete::Util::complete_array_elem(
                word=>$word, array=>["apple","orange","apricot"]);
        }
        [];
    },
    'help|h'    => sub { },
    'version|v' => sub { },
    'value=s'   => sub { },
    'file=s'    => sub { },
);
_
        write_text("$tempdir/cli1", join("", @script_content));
        chmod 0755, "$tempdir/cli1";

        push @$pp, make_completion_participant(
            type => 'perl_code',
            name=>"optname",
            cmdline=>"$tempdir/cli1 --hel^",
        );
        push @$pp, make_completion_participant(
            type => 'perl_code',
            name=>"optval",
            cmdline=>"$tempdir/cli1 --value a^",
        );

        my $i = 0; for (@$pp) { $_->{seq} = $i++ }
    },
    #datasets => [
    #],
};

1;
# ABSTRACT:
