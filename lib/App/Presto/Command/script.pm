package App::Presto::Command::script;

# ABSTRACT: REST script-related commands

use Moo;
use File::Path qw(make_path);
with 'App::Presto::InstallableCommand', 'App::Presto::CommandHasHelp';

has scripts => ( is => 'lazy' );

sub _build_scripts {
    my $self = shift;
    my $dir = $self->scripts_dir;
    opendir(my $dh, $dir) or die sprintf("unable to open directory %s: %s", $dir, $!);
    my @files = grep { -f "$dir/$_" } readdir($dh);
    closedir($dh);
    return \@files;
}

has scripts_dir => ( is => 'lazy' );

sub _build_scripts_dir {
    my $self = shift;
    my $dir = $self->config->file('scripts');
    make_path($dir);
    return $dir;
}

sub scripts_file {
    my $self = shift;
    my $file = shift;
    return sprintf('%s/%s', $self->scripts_dir, $file);
}

sub install {
    my $self = shift;
    $self->term->add_commands(
        {
            save => {
                exclude_from_history => 1,
                desc => 'Save a series of commands from your history to a script file',
                args => 'file [offset start] [offset end]',
                minargs => 1,
                maxargs => 3,
                proc    => sub { $self->_save(@_) },
            },
            source => {
                desc => 'Execute a previously stored series of commands',
                args => '[-i] file',
                minargs => 1,
                maxargs => 2,
                args => sub {
                    my(undef,$cmpl) = @_;
                    return [grep { $cmpl->{str} eq '' || index($_, $cmpl->{str}) == 0 } @{ $self->scripts }];
                },
                proc    => sub { $self->_source(@_) },
            },
        }
    );
}

sub _save {
    my $self = shift;
    unless ( $self->term->can('GetHistory') ) {
        print " *** Your readline lib doesn't support history!\n";
        return;
    }
    my $file    = shift;
    my @range   = @_;
    my @history = $self->term->GetHistory;
    if ( @range == 2 ) {
        @history = @history[ $range[0] .. $range[1] ];
    }
    elsif ( @range == 1 ) {
        $range[1] = $range[0] < 0 ? -1 : $#history;
        @history = @history[ $range[0] .. $range[1] ];
    }
    printf "Save the following %d commands to script file '%s'?\n",
      scalar(@history), $file;
    print "  $_\n" for @history;
    my $save   = 0;
    my $target = $self->scripts_file($file);
    if ( -e $target ) {
        my $response = $self->term->readline("Overwrite existing file? (y/N) ");
        $save = 1 if $response =~ m/^y/i;
    }
    else {
        my $response = $self->term->readline("Save? (Y/n) ");
        $save = 1 unless $response =~ m/^n/i;
    }
    if ($save) {
        make_path( $self->scripts_dir );
        open( my $fh, '>', $target )
          or die "Unable to open $target for writing: $!";
        foreach my $l (@history) {
            print $fh "$l\n";
        }
        close $fh;
        print " * Saved\n";
    }
    else {
        print " * Aborted\n";
    }
}

my @STACK; # prevent circular dependencies of scripts
sub _source {
    my $self = shift;
    my $script = pop;
    my $interactive = shift;

    if(grep { $script eq $_ } @STACK){
        print " *** script $script already being run, will not run again\n";
        return;
    }

    my @commands = $self->_script_commands($script);
    if(!@commands){
        print " *** script $script not found or empty\n";
        return;
    }

    push @STACK, $script;
    foreach my $l(@commands){
        print "$l\n";
        if($interactive){
            my $response = $self->term->readline("Execute? (Y/n/a) ");
            if($response && $response =~ m/^n/){
                next;
            } elsif($response && $response =~ m/^a/){
                last;
            }
        }
        $self->term->process_a_cmd($l);
    }

    pop @STACK;
    return;
}

sub _script_commands {
    my $self = shift;
    my $script = shift;
    my $file = $self->scripts_file($script);
    if(!-e $file){
        return;
    }
    open(my $fh, '<', $file) or die "Unable to open $file for reading: $!";
    chomp(my @commands = <$fh>);
    close $fh;
    return @commands;
}

sub help_categories {
    return {
        desc => 'Work with saving and running scripts of commands',
        cmds => ['save','source'],
    };
}

1;

