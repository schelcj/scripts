#!/usr/bin/env perl

use Modern::Perl;
use Class::CSV;
use List::MoreUtils qw(all uniq);
use Text::Autoformat;
use HTML::Template;
use Text::Names qw(reverseName cleanName);

my %students = get_students($ARGV[0]);
my %params   = get_params(\%students);
my $template = get_template();
my $tmpl     = HTML::Template->new(scalarref => \$template, die_on_bad_params => 0);

$tmpl->param(\%params);
print $tmpl->output;

sub get_students {
  my ($file)      = @_;
  my $student_ref = {};
  my $csv         = Class::CSV->parse(
    filename => $file,
    fields   => [qw(name role committee_member term title)],
  );

  my @lines = @{$csv->lines()};

  shift @lines;

  for my $line (@lines) {
    next if $line->role !~ /coch|chai/i;
    push @{$student_ref->{$line->name}{committee_members}}, reverseName(cleanName($line->committee_member));
    $student_ref->{$line->name}{titles} = [];

    if ($line->title !~ /^\s*$/) {
      my $title = $line->title;
      chomp($title);
      push @{$student_ref->{$line->name}{titles}}, $title;
    }

    ($student_ref->{$line->name}{year} = $line->term) =~ s/\D//g;
  }

  return %{$student_ref};
}

sub get_params {
  my ($student_ref) = @_;
  my $param_ref = {};

  for my $student (keys %{$student_ref}) {
    my $title = join(q{ }, uniq @{$student_ref->{$student}{titles}});
    ($title = autoformat($title, {case => 'highlight'}) || q{}) =~ s/[\n\r]+//g;

    my $committee;
    my @members = uniq @{$student_ref->{$student}{committee_members}};
    given (scalar @members) {
      when ($_ >= 3) {$committee = join(q{, and }, @members)}
      when ($_ >= 2) {$committee = join(q{ and },  @members)}
      default        {$committee = join(q{},       @members)}
    }

    push @{$param_ref->{students}}, {
      name      => reverseName(cleanName($student)),
      committee => $committee,
      year      => $student_ref->{$student}{year},
      title     => $title,
      };
  }

  return %{$param_ref};
}

sub get_template {
  return <<'EOF'
<table id="graduated_students">
  <thead>
    <tr>
      <th>Name</th>
      <th>Year of Graduation</th>
      <th>Title of Dissertation</th>
      <th>Committee Chair(s)</th>
    </tr>
  </thead>
  <tbody>
  <tmpl_loop name="students">
    <tr>
      <td><tmpl_var name="name"></td>
      <td><tmpl_var name="year"></td>
      <td><tmpl_var name="title"></td>
      <td><tmpl_var name="committee"></td>
    </tr>
  </tmpl_loop>
  </tbody>
</table>
EOF
}
