package App::Dataninja::Plugin;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(command send_message);

our $_COMMAND = sub { die "Must be used in a plugin's setup() method" };
our $_SEND_MESSAGE = sub { die "Must be used in a plugin's setup() method" };

sub command { $_COMMAND->(@_) }
sub send_message { $_SEND_MESSAGE->(@_) }

1;
