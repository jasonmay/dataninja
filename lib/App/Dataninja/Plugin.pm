package App::Dataninja::Plugin;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(command);

our $_COMMAND_SUB = sub { die "Must be used in a plugin's setup() method" };

sub command { $_COMMAND_SUB->(@_) }

1;
