package Dataninja::Bot::Plugin::Foobar;
use Path::Dispatcher::Declarative -base;

on qr/^foo/ => sub {
    return "food";
};

on qr/^bar/ => sub {
    return "bears";
};

1;
