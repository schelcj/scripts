#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;

my $autossh_defaults = {
  AUTOSSH_POLL     => 20,
  AUTOSSH_PORT     => undef,
  AUTOSSH_GATETIME => undef,
  AUTOSSH_LOGFILE  => undef,
  AUTOSSH_DEBUG    => undef,
  AUTOSSH_PATH     => undef,
};

GetOptions(
  'R|host=s'     => \(my $host    = undef),
  's|session:s'  => \(my $session = 'smux-default'),
  'k|ssh-key:s'  => \(my $ssh_key = "$ENV{HOME}/.ssh/id_rsa"),
  'a|autossh:s%' => \($autossh_defaults),
  'h|help'       => \(my $help    = 0),
  'man'          => \(my $man     = 0),
  )
  or pod2usage(1);

pod2usage(1) if $help;
pod2usage(-exitval => 0, -verbose => 2) if $man;

my $port = undef;
{
  $port = int(rand(32000));
  last if $port >= 20000;
  redo;
}

for (keys %{$autossh_defaults}) {
  next unless defined $autossh_defaults->{$_};
  $ENV{$_} = $autossh_defaults->{$_};
}

unless (exists $ENV{SSH_AUTH_SOCK}) {
  for (io->pipe('ssh-agent -s')->all) {
    my ($var, $val) = split(/=/);
    $ENV{$var} = $val;
  }

  exec "ssh-add $ssh_key";
}

exec "autossh -t $host 'tmux attach -t $session || tmux new-session -s $session'";

__END__

=head1 NAME

smux.pl - ssh with auto-reconnect and tmux

=head1 SYNOPSIS

smux.pl [options]

  Options:

    -R, --host      Remote host to connect [required]
    -s, --session   Tmux session to attach or create on the remote host (default: smux-default)
    -k, --ssh-key   Path to private ssh key to use for connection
    -a, --autossh   Set autossh environment variables. See the autossh man page
                    for details on each variable. Currently support variables
                    AUTOSSH_POLL, AUTOSSH_PORT, AUTOSSH_GATETIME, AUTOSSH_LOGFILE
                    AUTOSSH_DEBUG, AUTOSSH_PATH.
    -h, --help      Usage information
    --man           Full documentation

=head1 EXAMPLES

  smux.pl -R foo.com
  smux.pl -R foo.com -s misc
  smux.pl -R foo.com -k ~/.ssh/id_dsa
  smux.pl -R foo.com -a AUTOSSH_POLL=20 -a AUTOSSH_DEBUG=yes

=head1 DESCRIPTION

This script is inspired by the smux shell script described in a blog
post at https://coderwall.com/p/aohfrg/smux-ssh-with-auto-reconnect-tmux-a-mosh-replacement.

I wanted to include tmux session names and have cleaner getopt handling without
doing getopts in bash.

This script relies uses autossh to maintain a connect to the remote host and
will attach to an existing tmux session, or create a new session, on the
remote host. I have been using mosh to maintain a connection to remote hosts
but getting mosh installed everywhere is sometimes difficult.

=head1 ENVIRONMENT VARIABLES

=over

=item * TODO: define all the autossh vars?

=back

=head1 VERSION

0.1

=cut

