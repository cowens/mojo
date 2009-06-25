#!perl

# Copyright (C) 2008-2009, Sebastian Riedel.

use strict;
use warnings;

use Test::More;

plan skip_all => 'set TEST_PIPELINE to enable this test'
  unless $ENV{TEST_PIPELINE};
plan tests => 38;

# Are we there yet?
# No
# Are we there yet?
# No
# Are we there yet?
# No
# ...Where are we going?
use_ok('Mojo::Pipeline');
use_ok('Mojo::Transaction');

# Transactions
my $tx1 = Mojo::Transaction->new_get("http://127.0.0.1:3000/1/");
my $tx2 = Mojo::Transaction->new_get("http://127.0.0.1:3000/2/");

# Pipeline
my $pipe = Mojo::Pipeline->new($tx1, $tx2);

# Set up state to simulate that we're done writing
# (Do not use this in any production code!)
$_->state('read_response') for @{$pipe->{_txs}};
$pipe->{_reader}      = 0;
$pipe->{_writer}      = 2;
$pipe->{_all_written} = 1;

my $responses = <<EOF;
HTTP/1.1 204 OK
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT

HTTP/1.1 200 OK
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT
Content-Type: text/plain
Content-length: 5

1234
EOF

# Read
$pipe->client_read($responses);

# Test
ok($pipe->is_done);
ok($tx1->is_done);
ok($tx2->is_done);
is($tx1->res->code, 204);
is($tx2->res->code, 200);

# Transactions
$tx1 = Mojo::Transaction->new_get("http://127.0.0.1:3000/3/");
$tx2 = Mojo::Transaction->new_head("http://127.0.0.1:3000/4/");

# Pipeline
$pipe = Mojo::Pipeline->new($tx1, $tx2);

# Set up state to simulate that we're done writing
# (Do not use this in any production code!)
$_->state('read_response') for @{$pipe->{_txs}};
$pipe->{_reader}      = 0;
$pipe->{_writer}      = 2;
$pipe->{_all_written} = 1;

$responses = <<EOF;
HTTP/1.1 404 Not Found
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT

HTTP/1.1 200 OK
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT
Content-Type: text/plain
Content-length: 200

EOF

# Read
$pipe->client_read($responses);

# Test
ok($pipe->is_done);
ok($tx1->is_done);
ok($tx2->is_done);
is($tx1->res->code, 404);
is($tx2->res->code, 200);

# Transactions
$tx1 = Mojo::Transaction->new_head("http://127.0.0.1:3000/5/");
$tx2 = Mojo::Transaction->new_get("http://127.0.0.1:3000/6/");

# Pipeline
$pipe = Mojo::Pipeline->new($tx1, $tx2);

# Set up state to simulate that we're done writing
# (Do not use this in any production code!)
$_->state('read_response') for @{$pipe->{_txs}};
$pipe->{_reader}      = 0;
$pipe->{_writer}      = 2;
$pipe->{_all_written} = 1;

$responses = <<EOF;
HTTP/1.1 200 OK
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT
Content-Type: text/plain
Content-length: 200

HTTP/1.1 500 Internal Server Error
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT
Content-Type: text/plain
Content-length: 5

1234
EOF

# Read
$pipe->client_read($responses);

# Test
ok($pipe->is_done);
ok($tx1->is_done);
ok($tx2->is_done);
is($tx1->res->code, 200);
is($tx2->res->code, 500);

# Transactions
$tx1 = Mojo::Transaction->new_get("http://127.0.0.1:3000/7/");
$tx2 = Mojo::Transaction->new_get("http://labs.kraih.com:3000/8/");

# Pipeline
$pipe = Mojo::Pipeline->new($tx1, $tx2);

# Test
ok($pipe->has_error);
is($tx1->state, 'start');
is($tx2->state, 'start');

# Transactions
$tx1 = Mojo::Transaction->new_get("http://labs.kraih.com/7/");
$tx2 = Mojo::Transaction->new_get("http://labs.kraih.com:3000/8/");

# Pipeline
$pipe = Mojo::Pipeline->new($tx1, $tx2);

# Test
ok($pipe->has_error);
is($tx1->state, 'start');
is($tx2->state, 'start');

# Transactions
$tx1 = Mojo::Transaction->new_head("http://127.0.0.1:3000/9/");
$tx2 = Mojo::Transaction->new_get("http://127.0.0.1:3000/10/");

# Pipeline
$pipe = Mojo::Pipeline->new($tx1, $tx2);

# Set up state to simulate that we're done writing
# (Do not use this in any production code!)
$_->state('read_response') for @{$pipe->{_txs}};
$pipe->{_reader}      = 0;
$pipe->{_writer}      = 2;
$pipe->{_all_written} = 1;

$responses = <<EOF;
HTTP/1.1 151 Weird

HTTP/1.1 152 Weirder

HTTP/1.1 200 OK
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT
Content-Type: text/plain
Content-length: 2000

HTTP/1.1 204 OK
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT

EOF

# Read
$pipe->client_read($responses);

# Test
ok($pipe->is_done);
ok($tx1->is_done);
ok($tx2->is_done);
is($tx1->res->code, 200);
is($tx2->res->code, 204);

# Transactions
$tx1 = Mojo::Transaction->new_head("http://127.0.0.1:3000/11/");
$tx2 = Mojo::Transaction->new_get("http://127.0.0.1:3000/12/");

# Pipeline
$pipe = Mojo::Pipeline->new($tx1, $tx2);

# Set up state to simulate that we're done writing
# (Do not use this in any production code!)
$_->state('read_response') for @{$pipe->{_txs}};
$pipe->{_reader}      = 0;
$pipe->{_writer}      = 2;
$pipe->{_all_written} = 1;

$responses = <<EOF;
HTTP/1.1 200 OK
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT
Content-Type: text/plain
Content-length: 2000

HTTP/1.1 151 Weird

HTTP/1.1 152 Weirder

HTTP/1.1 204 OK
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT

EOF

# Read
$pipe->client_read($responses);

# Test
ok($pipe->is_done);
ok($tx1->is_done);
ok($tx2->is_done);
is($tx1->res->code, 200);
is($tx2->res->code, 204);

# Transactions
$tx1 = Mojo::Transaction->new_get("http://127.0.0.1:3000/13/");
$tx2 = Mojo::Transaction->new_get("http://127.0.0.1:3000/14/");

# Pipeline
$pipe = Mojo::Pipeline->new($tx1, $tx2);

# Set up state to simulate that we're done writing
# (Do not use this in any production code!)
$_->state('read_response') for @{$pipe->{_txs}};
$pipe->{_reader}      = 0;
$pipe->{_writer}      = 2;
$pipe->{_all_written} = 1;

$responses = <<EOF;
HTTP/1.1 151 Weird

HTTP/1.1 200 OK
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT
Content-Type: text/plain
Content-length: 5

1234
HTTP/1.1 152 Weirder

HTTP/1.1 169 Weirdest

HTTP/1.1 204 OK
Connection: Keep-Alive
Date: Tue, 09 Jun 2009 18:24:14 GMT

EOF

# Read
$pipe->client_read($responses);

# Test
ok($pipe->is_done);
ok($tx1->is_done);
ok($tx2->is_done);
is($tx1->res->code, 200);
is($tx2->res->code, 204);