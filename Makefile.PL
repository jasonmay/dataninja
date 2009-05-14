use inc::Module::Install;

name           'App-Dataninja';
license        'perl';
author         'Jason May <jason.a.may@gmail.com>';
all_from       'lib/App/Dataninja.pm';
perl_version   '5.8.8';

build_requires 'Test::More';
requires 'App::Nopaste';
requires 'Bot::BasicBot';
requires 'DBD::Mock';
requires 'DBD::Pg';
requires 'DBD::SQLite';
requires 'DBIx::Class';
requires 'DBIx::Class::InflateColumn::Boolean';
requires 'DBICx::Deploy';
requires 'DateTime::Duration';
requires 'DateTime::Format::Duration';
requires 'DateTime::Format::Human::Duration';
requires 'DateTime::Format::Natural';
requires 'DateTime::Format::Pg';
requires 'DateTime';
requires 'Hash::Merge';
requires 'List::MoreUtils';
requires 'List::Permutor';
requires 'List::Util';
requires 'Module::Pluggable';
requires 'MooseX::NonMoose';
requires 'Moose';
requires 'MooseX::NonMoose' => '0.03';
requires 'Net::Hiveminder';
requires 'Net::Twitter';
requires 'Path::Dispatcher';
requires 'REST::Google::Translate';
requires 'String::Util';
requires 'URI';
requires 'WWW::Google::Calculator';
requires 'Weather::Underground';
requires 'Web::Scraper';
requires 'YAML::XS';

install_script('bin/dataninja.pl');

auto_install;
WriteAll;
