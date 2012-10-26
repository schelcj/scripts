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
  my ($app, $version) = @_;

return <<"EOF"
#%Module1.0
source $CAC_INCLUDES
source $MODULEFILE_PATH/$app.inc.tcl

proc ModulesHelp { } {
  global app version modroot
  cac::Message \$app \$version \$modroot
}

set version $version
set app     $app
set modroot $SPH_PATH/$app/$version

conflict $app

prepend-path PATH $modroot/bin

cac::whatis $app                                                                              
if { [ info exists NewModulesVersionDate ] == 1 } {                                           
  cac::load \$app \$version \$modroot \$ModulesVersion \$NewModulesVersion \$NewModulesVersionDate
} else {                                                                                      
  cac::load \$app \$version \$modroot                                                          
}                                                                                             
EOF
}

sub get_modulefile_desc {
return <<"EOF"
EOF
}
