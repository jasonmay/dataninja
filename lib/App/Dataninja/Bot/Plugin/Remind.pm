package App::Dataninja::Bot::Plugin::Remind;
use Moose;
use DateTime;
use DateTime::Format::Natural;
use DateTime::Format::Pg;
#use DateTime::Format::SQLite;
extends 'App::Dataninja::Bot::Plugin';

=head1 NAME

App::Dataninja::Bot::Plugin::Remind - you can make and cancel reminders

=head1 COMMANDS

=over

=item * remind

When you make a reminder, the bot tells you when it will fire and give you an
ID for manipulation/deltion. The bot will say something when the time arrives.

  21:49:04 < jasonmay> !remind me The Office is on > 20 seconds from now
  21:49:04 < dataninja> will remind at: 2009-05-03 21:49:24
                        America/New_York [id: 651]
  21:49:24 < dataninja> jasonmay: The Office is on


=item * cancel B<ID>

Cancel the reminder by supplying the ID.

=item * next_reminder B<[nick|offset]>

You can view the next upcoming reminder of yourself or another nick. If you
don't supply any arguments, the offset defaults to 1 (the next reminder) and
the nick defaults to your nick. If you supply a number, say 7, it gets the
reminder that will fire 7 of your reminders from now. Otherwise it will
consider it as a nick.

Aliases: B<nextreminder>, B<nr>

=back

=cut

around 'command_setup' => sub {
    my $orig = shift;
    my $self = shift;

    $self->command(remind => sub {
            my $command_args = shift;
            my $message_data = shift;
            my $schema       = shift;
            my ($nick, $desc, $time) =
                ($command_args =~ /(\S+)? \s+ (.+) \s+>\s+ (.+)/x);
            return "format: remind NICK (message) > when"
                unless defined $nick and defined $desc and defined $time;
            my %numbers = (
                one       => 1,   two        => 2,   three      => 3,
                four      => 4,   five       => 5,   six        => 6,
                seven     => 7,   eight      => 8,   nine       => 9,
                ten       => 10,  eleven     => 11,  twelve    => 12,
                thirteen  => 13,  fourteen   => 14,  fifteen   => 15,
                sixteen   => 16,  seventeen  => 17,  eighteen  => 18,
                nineteen  => 19,  twenty     => 20,  thirty    => 30,
                fourty    => 40,  fifty      => 50,  sixty     => 60,
                seventy   => 70,  eighty     => 80,  ninty     => 90,
                ninety    => 90,
            );

            foreach my $word (keys %numbers) {
                $time =~ s/\b$word\b/$numbers{$word}/ge;
                $time =~ s/\ba\s+few\b/3/ge;
                $time =~ s/\bseveral\b/8/ge;
                $time =~ s/\ban?\b/1/ge;
            }

            $nick = $message_data->nick if $nick eq 'me';
            my $reminder = $schema->resultset('Reminder');

            my $parser = DateTime::Format::Natural->new(time_zone => 'America/New_York', prefer_future => 1);
            my $when_to_remind = eval { $parser->parse_datetime($time) };
            return $@ if $@;

            if (!$parser->success) {
                $when_to_remind = eval {
                    DateTime::Format::Pg->parse_datetime($time);
                };
                return $@ if $@;
                return "huh? see http://tinyurl.com/dtfn-examples"
                    unless defined $when_to_remind;
            }

            $when_to_remind->set_time_zone('UTC');

            return "must authenticate yourself as Doc Brown to do that"
            if DateTime->compare($when_to_remind->clone(time_zone => 'America/New_York'), DateTime->now) < 0;

            my $reminder_row = $reminder->create({
                remindee    => $nick,
                description => $desc,
                channel     => $message_data->channel,
                network     => $message_data->network,
                maker       => $message_data->nick,
                moment      => $when_to_remind
            });

            $when_to_remind->set_time_zone('America/New_York');
            return sprintf('will remind at: %s %s %s [id: %s]',
                $when_to_remind->ymd,
                $when_to_remind->hms,
                $when_to_remind->time_zone->name,
                $reminder_row->id);
    });

    $self->command(cancel => sub {
            my $requested_id = shift;
            my $message_data = shift;
            my $schema       = shift;
            return "invalid ID" if $requested_id =~ /\D/;

            my $reminder = $schema->resultset('Reminder')->find($requested_id);

            if (defined $reminder) {
                return "that reminder wasn't for you!"
                    if $message_data->nick ne $reminder->maker;
                return "you don't need to worry about that"
                if $reminder->reminded or $reminder->canceled;
                $reminder->update({canceled => 1});
                return "canceled";
            }

# catchall
            return "could not find a reminder with that ID";

    });

#    $self->command(reminders => sub {
#        my $requested_id = shift;
#        my $message_data = shift;
#        my $schema       = shift;
#
#        return "todo!";
#    });

    my $next_reminder = sub {
        my $command_args = shift;
        my $message_data = shift;
        my $schema       = shift;

        my $nick = $message_data->nick;
        my $output_nick = 'you';
        my $offset = 1;

        if ($command_args =~ /\D/) {
            $nick        = lc $command_args;
            $output_nick = $command_args;
        }
        elsif (length $command_args > 0) {
            $offset = $command_args;
        }

        my $nr_row = $schema->resultset('Reminder')->search(
            {
                moment   => {'>' => DateTime->now},
                channel  => $message_data->channel,
                network  => $message_data->network,
                remindee => $nick,
                reminded => 0,
                canceled => 0,
            },
            { rows => $offset, order_by => 'moment' }
        )->slice($offset-1, $offset-1)->single;

        if (!defined $nr_row) {
            if ($offset == 1) {
            return
                sprintf(
                    "%s %s no upcoming reminders",
                    $output_nick, ($output_nick eq 'you' ? 'have' : 'has'),
                )
            }
            else {
                return "there aren't that many reminders!";
            }
        }

        return sprintf(
            "next reminder for %s: (%s) %s",
            $output_nick,
            $nr_row->moment,
            $nr_row->description
        );
    };

    $self->command(next_reminder => $next_reminder);
    $self->command(nextreminder  => $next_reminder);
    $self->command(nr            => $next_reminder);
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

