package App::Dataninja::Plugin;
use Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(command send_message add_hook);

my $override_this_sub = sub { die "Must be used in a plugin's setup() method" };

our $_COMMAND      = $override_this_sub;
our $_SEND_MESSAGE = $override_this_sub;
our $_ADD_HOOK     = $override_this_sub;

sub command      { $_COMMAND->(@_) }
sub send_message { $_SEND_MESSAGE->(@_) }
sub add_hook     { $_ADD_HOOK->(@_) }

1;
