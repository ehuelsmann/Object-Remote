package Object::Remote::Node;

use strictures 1;
use Object::Remote::Connector::STDIO;
use Object::Remote::Logging qw(:log);
use Object::Remote;
use CPS::Future;

sub run {
  log_trace { "run() has been invoked on remote node; creating STDIO connector" };
  my $c = Object::Remote::Connector::STDIO->new->connect;

  $c->register_class_call_handler;

  my $loop = Object::Remote->current_loop;

  $c->on_close->on_ready(sub { 
    log_info { "Node connection with call handler has closed" };
    $loop->want_stop 
  });

  print { $c->send_to_fh } "Shere\n";

  log_debug { "Node is going to start the run loop" };
  $loop->want_run;
  $loop->run_while_wanted;
  log_debug { "Run loop invocation in node has completed" };
}

1;
