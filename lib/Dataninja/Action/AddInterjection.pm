use strict;
use warnings;

=head1 NAME

Dataninja::Action::AddInterjection

=cut

package Dataninja::Action::AddInterjection;
use base qw/Dataninja::Action Jifty::Action/;

use Jifty::Param::Schema;
use Jifty::Action schema {

};

=head2 take_action

=cut

sub take_action {
    my $self = shift;
    
    # Custom action code

    my $message = $self->argument_value('message');
    my $channel = $self->argument_value('channel');
    my $network = $self->argument_value('network');

    my $interjection = Dataninja::Model::Interjection->new;
    $interjection->create(
        network => $network,
        channel => $channel,
        message => "<jasonmay> $message"
    );
    
    $self->report_success if not $self->result->failure;
    
    return 1;
}

=head2 report_success

=cut

sub report_success {
    my $self = shift;
    # Your success message here
    $self->result->message('Success');
}

1;

