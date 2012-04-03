package Textmark;

use strict;
use warnings;

use Exporter qw/import/;

our @EXPORT_OK = qw/textmark/;

our $VERSION = '0.01';

my $NL = qr/\r?\n/;

my $LIST_MARKER = qr/(\*|#)/;

# Formats  text!
# Returns HTML!
sub textmark {
	my( $text ) = @_;

	# Remove any tailing newline so we don't duplicate it
	chomp $text;
	# When we ensure the text ends with a newline to make parsing simpler.
	$text .= "\n"; 

	my $output = ""; #The text we return
	my @list_struct;

	while( defined( local $_ = get_line( \$text ) ) ) {

		############################################
		# List handling
		if( s/^\s*$LIST_MARKER\s+// ) {
			push @list_struct, [ $1, $_ ];
			my $current_list_level = \@list_struct;
			my @current_list_level_stack;

			my $current_depth = 1;

			while( local $_ = get_line( \$text ) ) {

				my $depth = 0;
				$depth++ while s/^(\s*$LIST_MARKER\s+)//g;

				my $row_item = [ $2, $_ ];

				if( $depth < 1 ) { 
					unget_line( $_ );
					last;
				}
				elsif( $depth == $current_depth ) {
					push @{$current_list_level}, $row_item;
				}
				elsif( $depth > $current_depth ) {
					push @current_list_level_stack, $current_list_level;
					$current_list_level = $current_list_level->[-1][2] ||= [];
					$current_depth++;

					push @{$current_list_level}, $row_item;
				}
				elsif( $depth < $current_depth ) {
					$current_list_level = pop @current_list_level_stack
						for( 1 .. ( $current_depth - $depth ) );
					$current_depth = $depth;
					push @{$current_list_level}, $row_item;
				}
				else {
					die "How exactly did we get here?";
				}

			}

			$output .= build_list( \@list_struct );
		}
		############################################
		# Block quotes
		elsif( s/\s*>\s*// ) {
			$output .= "<blockquote>\n".escape_html($_)."\n";

			while( defined( my $line = get_line( \$text ) ) ) {
				if( $line =~ s/^\s*>\s*// ) {
					$output .= escape_html($line)."\n";
				}
				else {
					unget_line($line);
					last;
				}
			}
			
			$output .= "</blockquote>\n";
		}
		
		############################################
		# Code Blocks
		elsif( /^```+$/ ) {
			$output .= "<code>\n";

			while( defined( my $line = get_line( \$text ) ) ) {
				last if $line =~ /^```+$/;

				$output .= escape_html($line)."\n";
			}

			$output .= "</code>\n";
		}
		############################################
		# Code Blocks Part Two
		elsif( /^(\t|   +)(.+)$/ ) {
			my( $indent, $code ) = ($1,$2);
			
			$output .= "<code>\n".escape_html($code)."\n";

			while( defined( my $line = get_line( \$text ) ) ) {
				if( $line !~ /\S/ or $line !~ /^$indent/) {
					unget_line( $line );
					last;
				}

				$line =~ s/^$indent//;

				$output .= escape_html($line)."\n";
			}

			$output .= "</code>\n";
		}
		
		############################################
		# Headers
		elsif( s/^(=+)\s*([^=]+?)\s*(=+)// ) {
			my( $size, $text ) = ($1,$2);
			$size=length($size);

			$output .= "<h$size>".parse_inline($text)."</h$size>\n";
		}

		############################################
		# Horizontal rule
		elsif( /^----+$/ ) {
			$output .= "<hr>\n";
		}

		############################################
		# Paragraphs 
		# Must be last block!
		elsif( /\S/ ) {
			$output .= "<p>".parse_inline($_);

			while( defined( my $line = get_line( \$text ) ) ) {
				last if $line eq "";
				$output .= " ".parse_inline($line);
			}

			$output .= "</p>\n";
		}
	}

	return $output;
}

sub escape_html {
	local $_ = shift;

	# Escapes
	s/&/&amp;/g;
	s/</&lt;/g;
	s/>/&gt;/g;

	return $_;
}

sub parse_inline {
	local $_ = escape_html( shift );

	# Formatting
	s/\*(\w+)\*/<b>$1<\/b>/g;
	s/_(\w+)_/<u>$1<\/u>/g;
	s{/(\w+)/}{<i>$1</i>}g;
	s/`([^`]+)`/<code>$1<\/code>/g;

	#TODO Make this work, we want to transform 'plain' urls into hyperlinks.
	# Currently interferes with the actual link codes below.
	#s{(https?://[\w/.?&=%\@,#!+-]+)}{<a href='$1'>$1</a>}g;

	# Links
	s/\[\s*([^\]]+?)\s*\]\(\s*([^)]+?)\s*\)/<a href='$2'>$1<\/a>/g;
	# Images
	s/\[\s*([^\]]+?)\s*\]\{\s*([^)]+?)\s*\}/<img src='$2' alt='$1'>/g;

	return $_;
}


my @line_buffer;
sub unget_line {
	push @line_buffer, $_[0];
}
sub get_line {
	my( $text_ref ) = @_;
	
	if( @line_buffer ) { return pop @line_buffer; }

	if( $$text_ref =~ s/^(.*?)$NL// ) { 
		return $1;
	}
		
	return;
}


############################################ 
# HTML GENERATION
############################################ 

my %list_close_tag = (
	'*' => '</ul>',
	'#' => '</ol>',
);

my %list_start_tag = (
	'*' => '<ul>',
	'#' => '</ol>'
);

sub build_list {
	my $list = shift;
	my $indent_level = shift || 0;

	my $indent_space = "\t" x $indent_level;

	my $output;
	my $last_type = '';

	for( @$list ) { 

		if( $_->[0] eq '*' and $last_type ne '*' ) {
			if( $last_type eq '#' ) {
				$output .= $indent_space . "</ol>\n";
			}
			$output .= $indent_space . "<ul>\n";
			$last_type = '*';
		}
		elsif( $_->[0] eq '#' and $last_type ne '#' ) {
			if( $last_type eq '*' ) {
				$output .= $indent_space . "</ul>\n";
			}
			$output .= $indent_space . "<ol>\n";
			$last_type = '#';
		}

		$output .= $indent_space . "<li><p>".parse_inline($_->[1])."</p>";

		if( $_->[2] ) {
			$output .= "\n" . build_list( $_->[2], $indent_level + 1 );
			$output .= $indent_space;
		}

		$output .= "</li>\n";
	}

	$output .= $indent_space . $list_close_tag{ $last_type } . "\n";

	return $output;
}


1;
__END__
=head1 NAME

Textmark - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Textmark;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Textmark, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.


=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Robert Grimes, E<lt>rmzgrimes@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Robert Grimes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
