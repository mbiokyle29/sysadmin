package Entry;
use Moose;
use namespace::autoclean;

has 'message' => (
	is => 'rw',
	isa => 'Str'
);

has 'type' => (
	is  => 'rw',
	isa => 'Str',
);

has 'date' => (
	is => 'rw',
	isa => 'Str',
);

__PACKAGE__->meta->make_immutable;
1;