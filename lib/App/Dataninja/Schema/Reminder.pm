package App::Dataninja::Schema::Reminder;
use KiokuDB::Class;
use Moose::Util::TypeConstraints;
with 'App::Dataninja::Schema::Entry';

has remindee => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has maker => (
    is       => 'ro',
    isa      => 'App::Dataninja::Schema::Nick',
    required => 1,
);

has triggered_by => (
    is       => 'ro',
    isa      => 'App::Dataninja::Schema::Message',
    required => 1,
);

has state => (
    is  => 'rw',
    isa => enum(['Active', 'Reminded', 'Cancelled']),
);

no KiokuDB::Class;

1;
