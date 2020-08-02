#!/usr/bin/env perl

use strict;
use warnings;
use autodie qw(:all);

use feature qw(signatures);
no warnings qw(experimental::signatures);

use Getopt::Long qw(:config auto_help no_ignore_case);
use File::Which;
use Pod::Usage;

my $cmd = 'autossh';
GetOptions(
  'r|remote:s'   => \(my $host = undef),
  'a|autossh:s%' => \(
    my $autossh_defaults = {
      AUTOSSH_POLL     => undef,
      AUTOSSH_PORT     => undef,
      AUTOSSH_GATETIME => undef,
      AUTOSSH_LOGFILE  => undef,
      AUTOSSH_DEBUG    => undef,
      AUTOSSH_PATH     => undef,
    }
  ),
  'm|mosh' => sub ($opt, $val) {
    $cmd = 'mosh' if $val;
  },
  's|session:s' => \(my $session = 'smux'),
  'k|ssh-key:s' => \(my $ssh_key = "$ENV{HOME}/.ssh/id_rsa"),
  'l|list-sessions' => sub ($opt, $val) {
    my $host = ${$opt->{linkage}->{r}};
    my $ssh  = ${$opt->{linkage}->{'bin-ssh'}};

    exec "$ssh $host 'tmux list-sessions' | column -t";

    exit;
  },
  'bin-autossh' => \(my $autossh = which 'autossh'),
  'bin-ssh'     => \(my $ssh     = which 'ssh'),
  'bin-mosh'    => \(my $mosh    = which 'mosh'),
  'man'         => \(my $man     = 0),
);

pod2usage(-exitval => 0, -verbose => 2) if $man;
pod2usage(-exitval => 1, -verbose => 0, -msg => 'Hostname is required') unless $host;

my $tmux_cmd = "tmux attach -t $session || tmux new-session -s $session";
my $cmd_ref  = {
  mosh => sub ($host) {
    return "$mosh -- $host $tmux_cmd";
  },
  autossh => sub ($host) {
    return "$autossh -t $host '$tmux_cmd'";
  },
};

if ($cmd eq 'autossh') {
  {
    $autossh_defaults->{AUTOSSH_PORT} = int(rand(32000));
    last if $autossh_defaults->{AUTOSSH_PORT} >= 20000;
    redo;
  }

  for (keys %{$autossh_defaults}) {
    next unless defined $autossh_defaults->{$_};
    $ENV{$_} = $autossh_defaults->{$_};
  }
}

unless (exists $ENV{SSH_AUTH_SOCK}) {
  open my $fh, 'ssh-agent -s |';

  for (<$fh>) {
    my ($var, $val) = split(/=/);
    $ENV{$var} = $val;
  }

  close $fh;
}

exec $cmd_ref->{$cmd}->($host);

__END__

=head1 NAME

smux.pl - ssh with auto-reconnect and tmux

=head1 SYNOPSIS

smux.pl -r HOST [OPTIONS]

  Options:

    -r, --remote        Remote host to connect [required]
    -c, --cmd           How to connect to the remote host, autossh or mosh (default: autossh)
    -s, --session       Tmux session to attach or create on the remote host (default: smux)
    -l, --list-sessions List all tmux sessions on remote host
    -k, --ssh-key       Path to private ssh key to use for connection
    -a, --autossh       Set autossh environment variables. See the autossh man page
                        for details on each variable. Currently support variables
                        AUTOSSH_POLL, AUTOSSH_PORT, AUTOSSH_GATETIME, AUTOSSH_LOGFILE
                        AUTOSSH_DEBUG, AUTOSSH_PATH.

    --bin-autossh       Path to auto ssh binary
    --bin-ssh           Path to ssh binary
    --bin-mosh          Path to mosh binary

    -h, -?, --help      Usage information
    --man               Full documentation

=head1 EXAMPLES

  smux.pl -r foo.com
  smux.pl -r foo.com -m
  smux.pl -r foo.com -l
  smux.pl -r foo.com -s misc
  smux.pl -r foo.com -k ~/.ssh/id_dsa
  smux.pl -r foo.com -a AUTOSSH_POLL=20 -a AUTOSSH_DEBUG=yes

=head1 DESCRIPTION

This script is inspired by the smux shell script described in a blog
post at https://coderwall.com/p/aohfrg/smux-ssh-with-auto-reconnect-tmux-a-mosh-replacement.

I wanted to include tmux session names and have cleaner getopt handling without
doing getopts in bash.

This script relies uses autossh to maintain a connect to the remote host and
will attach to an existing tmux session, or create a new session, on the
remote host. I have been using mosh to maintain a connection to remote hosts
but getting mosh installed everywhere is sometimes difficult. That said, this
script can now use mosh if it is available on the remote host.

=head1 ENVIRONMENT VARIABLES

=head2 TODO

=over

=item * define all the autossh vars?

=item * add screen support

=item * make hostname not require an argument flag

=back

=head1 VERSION

0.1

=cut

