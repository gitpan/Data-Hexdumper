package Data::Hexdumper;

$VERSION = "0.01";

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(Hexdump);

use strict;

=pod

=head1 NAME

Hexdumper - A module for displaying binary data in a readable format

=head1 SYNOPSIS

use Data::Hexdumper;
Data::Hexdumper::dump(
    data => $data,          # what to dump
    number_format => 'S',   # display as unsigned 'shorts'
    start_position => 100,  # start at this offset ...
    end_position => 148     # ... and end at this offset
);

=head1 DESCRIPTION

C<Data::Hexdumper> provides a simple way to format and display arbitary
binary data in a way similar to how some debuggers do for lesser languages.
It gives the programmer a considerable degree of flexibility in how the
data is formatted, with sensible defaults.  It is envisaged that it will
primarily be of use for those wrestling alligators in the swamp of binary
file formats, which is why it was written in the first place.

C<Data::Hexdumper> provides the following subroutine:

=over 4

=item Hexdump

Does everything :-)  Takes a hash of parameters, one of which is mandatory,
the rest having sensible defaults if not specified.  Available parameters
are:

=over 4

=item data

A scalar containing the binary data we're interested in.  This is
mandatory.

=item start_position

An integer telling us where in C<data> to start dumping.  Defaults to the
beginning of C<data>.

=item end_position

An integer telling us where in C<data> to stop dumping.  Defaults to the
end of C<data>.

=item number_format

A character specifying how to format the data.  This tells us whether the
data consists of bytes, shorts (16-bit values), longs (32-bit values),
and whether they are big- or little-endian.  The permissible values are
C<C>, C<S>, C<n>, C<v>, C<L>, C<N>, and C<V>, having exactly the same
meanings as they do in C<unpack>.  It defaults to 'C'.

=cut

sub VERSION {
	return $Data::Hexdumper::VERSION;
}

sub Hexdump {
	my %params=@_;
	my %num_bytes=(
		C => 1, # unsigned char
		S => 2, # unsigned short
		n => 2, # big-endian short
		v => 2, # little-endian short
		L => 4, # unsigned long
		N => 4, # big-endian long
		V => 4, # little-endian long
	);
	my $output='';

	my($data, $number_format, $start_position, $end_position)=
		@params{qw(data number_format start_position end_position)};

	die("No data given to Hexdump.") unless $data;

	my $addr = $start_position ||= 0;
	die("start_position must be numeric.") if($start_position=~/\D/);

	$number_format ||= 'C';
	my $num_bytes=$num_bytes{$number_format};
	die("number_format $number_format not recognised.") unless $num_bytes;

	$end_position ||= length($data)-1;
	die("end_position must be numeric.") if($end_position=~/\D/);

	$data=substr($data, $start_position, $end_position-$start_position);

	while(length($data)) {
		# Get a chunk of 16 bytes
		my $chunk=substr($data,0,16);
		# Remove 'em from data
		if(length($data)>16) { $data=substr($data,16); }
		 else { $data=''; }

		$output.=sprintf('  0x%04X : ', $addr);

		# have to keep chunk for printing, so make a copy we
		# can 'eat' $num_bytes at a time.
		my $line=$chunk;

		my $lengthOfLine=0;         # used for formatting in inner loop

		while(length($line)) {
			# grab a $num_bytes element, and remove from line
			my $thisElement=substr($line,0,$num_bytes);
			if(length($line)>$num_bytes) {
				$line=substr($line,$num_bytes);
			} else { $line=''; }
			my $thisData=sprintf('%0'.($num_bytes*2).'X ',
				       unpack($number_format, $thisElement));
			$lengthOfLine+=length($thisData);
			$output.=$thisData;
		}
		$chunk=~s/[^a-z0-9\\|,.<>;:'\@[{\]}#`!"£\$%^&*()_+=~?\/-]/./gi;
		$output.=' ' x (48-$lengthOfLine) .": $chunk\n";
		$addr+=16;
	}
	$output;
}

=head1 SEE ALSO

L<Data::Dumper>

L<Data::HexDump> if your needs are simple

perldoc -f unpack

perldoc -f pack

=head1 BUGS

If displaying data in 'short' or 'long' formats, the last element
displayed may be screwed up if it does not end on the boundary of
a short or a long - eg, if you try to display 39 bytes as longs.

=head1 AUTHOR

David Cantrell (david@cantrell.org.uk).

=head1 HISTORY

=item Version 0.01 

Original version.

=cut

1;

