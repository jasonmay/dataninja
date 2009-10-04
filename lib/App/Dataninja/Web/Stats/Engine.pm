#!/usr/bin/env perl
package App::Dataninja::Web::Stats::Engine;
use strict;
use warnings;
use Apache2::RequestUtil;
use CGI qw/:standard/;
use App::Dataninja::Schema;
use DDS;


sub handler {
    my $r = shift;
    $r->content_type('text/html');
    my $config_dir = '/home/jasonmay/.dataninja';

    # can't use connect_with_defaults with apache's ENV
    my $schema = App::Dataninja::Schema->connect_with_defaults(
        default_config => "$config_dir/config.yml",
        site_config    => "$config_dir/site_config.yml",
        secret_config  => "$config_dir/secret_config.yml",
    );
    $r->print('<html><body>');
    $r->print("<ul>\n");

    #$r->print('<pre>' . Dump(\%ENV)->Out . '</pre>');

    my $jasonmay = $schema->resultset('Message')->search({nick => 'jasonmay'}, {rows => 10, order_by => {-desc => 'moment'}});
    foreach my $row ($jasonmay->all) {
        $r->print('<li>' . $row->message . "</li>\n");
    }

    $r->print("</ul>\n");
    $r->print('</body></html>');

    return;
}

1;

