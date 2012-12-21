#!/usr/bin/env perl

use Modern::Perl;
use Mojolicious::Lite;
use Slurm;
use Data::Dumper;
use Readonly;
use DateTime;

Readonly::Scalar my $EMPTY       => q{};
Readonly::Scalar my $TIME_FORMAT => q{%d-%d:%d:%d};
Readonly::Scalar my $NO_RUN_TIME => q{0:00};

Readonly::Array  my @QUEUE_HDRS  => (qw(job_id partition name user_id job_state start_time time_limit num_nodes nodes)); 

get '/queue' =>  sub {
  my ($self) = @_;

  my $now     = DateTime->now();
  my $slurm   = Slurm::new();
  my $job_ref = $slurm->load_jobs();

  return $self->render() if not $self->stash('format');

  given ($self->stash('format')) {
    when (/json/) {
      my @jobs = ();

      foreach my $job (@{$job_ref->{job_array}}) {    
        my @columns    = (map {$job->{$_}} @QUEUE_HDRS);
        my $reason     = $slurm->job_reason_string($job->{state_reason});
        my $state      = $slurm->job_state_string($job->{job_state});

        given ($state) {
          when (/PENDING/) {
            $columns[5] = $NO_RUN_TIME;  
          }
          when (/RUNNING/) {
            my $start   = DateTime->from_epoch(epoch => $job->{start_time});
            my $dt      = $now - $start;
            $columns[5] = sprintf $TIME_FORMAT, $dt->days(), $dt->hours(), $dt->minutes(), $dt->seconds();
          }
        }

        $columns[3] = getpwuid($job->{user_id});
        $columns[4] = $slurm->job_state_string_compact($job->{job_state});
        $columns[6] = sprintf $TIME_FORMAT, (gmtime($job->{time_limit} * 60))[7,2,1,0];
        $columns[8] = sprintf q{%s (%s)}, $job->{nodes}||$EMPTY, $reason;

        push @jobs, \@columns;
      }

      return $self->render_json({aaData => \@jobs});
    }
    when (/txt/) {
      return $self->render_text(Dumper $job_ref);
    }
    default {
      return $self->render();
    }
  }
};

get '/job/:jobid' => sub {
  my ($self) = @_;

  my $slurm   = Slurm::new();
  my $job_ref = $slurm->load_jobs();
  my ($job)   = grep {$_->{job_id} == $self->param('jobid')} @{$job_ref->{job_array}};

  given ($self->stash('format')) {
    when (/json/) {
      $self->render_json($job);
    }
    when (/txt/) {
      $self->render_text(Dumper $job);
    }
    default {
      $self->render();
    }
  }

  return;
};

app->start;

__DATA__

@@ queue.html.ep
<!doctype html>
<html>
  <head>
    <title>Biostat Cluster Job Queue</title>
    <link rel="stylesheet" type="text/css" href="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.0/css/jquery.dataTables.css">
    <link rel="stylesheet" href="http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.9/themes/base/jquery-ui.css" type="text/css" media="all" /> 
    <script type="text/javascript" charset="utf8" src="http://ajax.aspnetcdn.com/ajax/jQuery/jquery-1.7.1.min.js"></script>
    <script type="text/javascript" charset="utf8" src="http://ajax.aspnetcdn.com/ajax/jquery.ui/1.8.9/jquery-ui.min.js"></script>
    <script type="text/javascript" charset="utf8" src="http://ajax.aspnetcdn.com/ajax/jquery.dataTables/1.9.0/jquery.dataTables.min.js"></script>

    <script type="text/javascript">
      if (typeof(jQuery) != 'undefined') { (function($) {
        $(document).ready(function() {
          $('#queue').dataTable({
            bAutoWidth:  false,
            bProcessing: true,
            bDestroy:    true,
            iDisplayLength: 25,
            sAjaxSource: '/queue.json',
            aoColumns: [
              { sTitle: 'Jobid'            },
              { sTitle: 'Partition'        },
              { sTitle: 'Name'             },
              { sTitle: 'User'             },
              { sTitle: 'State'            },
              { sTitle: 'Time'             },
              { sTitle: 'Timelimit'        },
              { sTitle: 'Nodes'            },
              { sTitle: 'Nodelist(Reason)' },
            ],
            aoColumnDefs: [{
              aTargets: ['_all'],
              fnCreatedCell: function (nTd, sData, oData, iRow, iCol) {
                if (iCol == 0) {
                  $('<a />', {href: '/job/' + sData, text: sData}).click(function() {
                    $.getJSON({url: $(this).attr('href'), data: job_data});
                    $('<div />', {id: '_' + sData, text: job_data}).dialog();
                  }).appendTo($(nTd).empty());
                }
              }
            }],
          });
        });
      })(jQuery)};
    </script>
  </head>
  <body>
    <table id="queue" class="dataTable"></table>
  </body>
</html>
