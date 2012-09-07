use strict;
use warnings;
use Test::More;

use App::Presto::Client::ContentHandlers::JSON;

my $j = App::Presto::Client::ContentHandlers::JSON->new;
isa_ok $j, 'App::Presto::Client::ContentHandlers::JSON';

if($INC{'JSON.pm'}){
ok $j->can_deserialize('application/json'), 'can deserialize application/json';
} else {
	ok !$j->can_deserialize('application/json'), 'no JSON available';
}

done_testing;
