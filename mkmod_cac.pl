#!/usr/bin/env perl

use FindBin qq($Bin);

use Modern::Perl;
use HTML::Template;
use Getopt::Compact;
use Readonly;

Readonly::Scalar my $CAC_INCLUDES    => q{/home/software/systems/module-lib/cac-modules.tcl};
Readonly::Scalar my $SPH_PATH        => q{/home/software/rhel6/sph};
Readonly::Scalar my $MODULEFILE_PATH => qq{$SPH_PATH/Modules/modulefiles};

my $opts = Getopt::Compact->new(
  struct => [
    [[qw(a app)],     q(Application Name), '=s'],
    [[qw(v version)], q(Version Number),   '=s'], 
  ]
)->opts();

my $module_tmpl = 'modulefile.tmpl';

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

sub get_modulefile_desc {
return <<'EOF'
namespace eval ::cac::<tmpl_var name="app"> {
  namespace export load whatis message
}

proc ::cac::<tmpl_var name="app">::message {modroot version args} {
  puts stderr "Description: Not defined"
}

proc ::cac::<tmpl_var name="app">::whatis {args} {
  module-whatis "Description: Not defined"
  module-whatis "Vendor Website: Not defined"
  module-whatis "Manual: Not defined"
}

proc ::cac::<tmpl_var name="app">::whatis {args} {
}
EOF
}
