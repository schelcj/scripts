#!/usr/bin/env perl

use Modern::Perl;
use HTML::Template;
use Getopt::Compact;
use Readonly;
use File::Spec;
use File::Slurp qw(write_file);
use autodie qw(:filesys);
use Config::Tiny;
use Carp qw(confess);

Readonly::Scalar my $CAC_INCLUDES    => q{/home/software/systems/module-lib/cac-modules.tcl};
Readonly::Scalar my $SPH_PATH        => q{/home/software/rhel6/sph};
Readonly::Scalar my $MODULEFILE_PATH => qq{$SPH_PATH/Modules/modulefiles};
Readonly::Scalar my $FILE_MODE       => oct('0664');
Readonly::Scalar my $DIR_MODE        => oct('2775');

## no tidy
my $opts = Getopt::Compact->new(
  struct => [
    [[qw(c config)],  q(Config file),               '=s'],
    [[qw(a app)],     q(Application Name),          '=s'],
    [[qw(v version)], q(Version Number),            '=s'],
    [[qw(d default)], q(Set as default version)         ],
    [[qw(i include)], q(Create include description file)],
  ]
)->opts();
## use tidy

my $modulefile_dir     = get_modulefile_dir($opts->{app});
my $modulefile_include = get_module_description($opts->{app});
my %params             = get_params($opts->{app}, $opts->{version}, $modulefile_include);

if ($opts->{config} and not -e $opts->{config}) {
  confess qq(Config defined '$opts->{config}' but does not exist);
} elsif ($opts->{config}) {
  my $conf     = Config::Tiny->read($opts->{config});
  my $app_conf = $conf->{$opts->{app}};

  @params{keys %{$app_conf}} = values %{$app_conf};
  say "Loaded desciptions and urls for $opts->{app}";
}

if (not -e $modulefile_dir) {
  mkdir($modulefile_dir);
  chmod($DIR_MODE, $modulefile_dir);
  say "Created module directory $modulefile_dir";
}

my $modulefile = get_modulefile($modulefile_dir, $opts->{version});
write_file($modulefile, get_modulefile_content());
chmod $FILE_MODE, $modulefile;
say "Wrote modulefile $modulefile";

if ($opts->{include}) {
  write_file($modulefile_include, get_modulefile_include_content());
  chmod $FILE_MODE, $modulefile_include;
  say "Wrote modulefile include $modulefile_include";
}

if ($opts->{default}) {
  my $default_version_file = File::Spec->join($modulefile_dir, '.version');
  write_file($default_version_file, get_default_version_content());
  chmod $FILE_MODE, $default_version_file;
  say "Wrote default version file $default_version_file";
}

sub get_modulefile_dir {
  my ($app) = @_;
  return File::Spec->join($MODULEFILE_PATH, $app);
}

sub get_modulefile {
  my ($module_dir, $version) = @_;
  return File::Spec->join($module_dir, $version);
}

sub get_modroot {
  my ($app, $version) = @_;
  return File::Spec->join($SPH_PATH, $app, $version);
}

sub get_module_description {
  my ($app) = @_;
  my $include = qq(${app}.inc.tcl);
  return File::Spec->join($MODULEFILE_PATH, $app, $include);
}

sub get_params {
  my ($app, $version, $include) = @_;
  return (
    cac_includes       => $CAC_INCLUDES,
    app                => $app,
    version            => $version,
    modroot            => get_modroot($app, $version),
    module_description => $include,
    description        => q{Not defined},
    vendor_url         => q{Not defined},
    manual_url         => q{Not defined},
  );
}

sub get_modulefile_content {
  return get_content(get_modulefile_template());
}

sub get_modulefile_include_content {
  return get_content(get_module_include_template());
}

sub get_default_version_content {
  return get_content(get_default_version_template());
}

sub get_content {
  my ($template) = @_;
  my $tmpl = HTML::Template->new(scalarref => \$template, die_on_bad_params => 0,);
  $tmpl->param(\%params);
  return $tmpl->output;
}

sub get_modulefile_template {
  return <<'EOF'
#%Module1.0
source <tmpl_var name="cac_includes">
source <tmpl_var name="module_description">

proc ModulesHelp { } {
  global app version modroot
  cac::Message $app $version $modroot
}

set version <tmpl_var name="version">
set app     <tmpl_var name="app">
set modroot <tmpl_var name="modroot">

conflict <tmpl_var name="app">

prepend-path PATH $modroot/bin

cac::whatis $app                                                                              
if { [ info exists NewModulesVersionDate ] == 1 } {                                           
  cac::load $app $version $modroot $ModulesVersion $NewModulesVersion $NewModulesVersionDate
} else {                                                                                      
  cac::load $app $version $modroot                                                          
}                                                                                             
EOF
}

sub get_module_include_template {
  return <<'EOF'
namespace eval ::cac::<tmpl_var name="app"> {
  namespace export load whatis message
}

proc ::cac::<tmpl_var name="app">::message {modroot version args} {
  puts stderr "\t<tmpl_var name="description">"
  puts stderr "\n\tThis adds $modroot/* to several of the"
  puts stderr "\tenvironment variables."
  puts stderr "\n\tVersion $version\n"
}

proc ::cac::<tmpl_var name="app">::whatis {args} {
  module-whatis "Description: <tmpl_var name="description">"
  module-whatis "Vendor Website: <tmpl_var name="vendor_url">"
  module-whatis "Manual: <tmpl_var name="manual_url">"
}

proc ::cac::<tmpl_var name="app">::load {app version modroot args} {

}
EOF
}

sub get_default_version_template {
  return <<'EOF'
#%Module1.0
set ModulesVersion "<tmpl_var name="version">"
EOF
}
