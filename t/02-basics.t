use Test::More;
use strict;

use Textmark qw/textmark/;

my $input = <<EOF;
= This is my h1 header =
this is a paragraph
of text

and this is the next paragraph.

* and this is a list
* of items
* and so on

with a following paragraph
EOF

my $output = <<EOF;
<h1>This is my h1 header</h1>
<p>this is a paragraph of text</p>
<p>and this is the next paragraph.</p>
<ul>
<li><p>and this is a list</p></li>
<li><p>of items</p></li>
<li><p>and so on</p></li>
</ul>
<p>with a following paragraph</p>
EOF

is( textmark( $input), $output );

$input = <<EOF;
= h1 header =
== h2 header ==
=== h3 header ===
==== h4 header ====

ending paragraph
EOF

$output = <<EOF;
<h1>h1 header</h1>
<h2>h2 header</h2>
<h3>h3 header</h3>
<h4>h4 header</h4>
<p>ending paragraph</p>
EOF

is( textmark( $input), $output );

$input = <<EOF;
This is *bold* text followed by _underline_ text
followed by /italic/ text. Followed by `code type` text.

This is a google link [google](http://google.com)
Followed by a google image: [image]{http://google.com/image.jpg}

* list with *bold* and _underscore_ text
* and maybe some /italic/ and `code` text
EOF

$output = <<EOF;
<p>This is <b>bold</b> text followed by <u>underline</u> text followed by <i>italic</i> text. Followed by <code>code type</code> text.</p>
<p>This is a google link <a href='http://google.com'>google</a> Followed by a google image: <img src='http://google.com/image.jpg' alt='image'></p>
<ul>
<li><p>list with <b>bold</b> and <u>underscore</u> text</p></li>
<li><p>and maybe some <i>italic</i> and <code>code</code> text</p></li>
</ul>
EOF

is( textmark( $input), $output );

$input = <<EOF;
Paragraph text

	Followed by some code
	in a block
	via indents

another paragraph

````````````````
if( x > 42 ) {
	printf "yo";
}
````````````````

Some complex code

	first level of indent
		followed by second
		and still second
	back to first
		and second
			and third
		second again
	first again

Break paragraph

        first level of indent
                followed by second
                and still second
        back to first
                and second
                        and third
                second again
        first again
EOF

$output = <<EOF;
<p>Paragraph text</p>
<code>
Followed by some code
in a block
via indents
</code>
<p>another paragraph</p>
<code>
if( x &gt; 42 ) {
	printf "yo";
}
</code>
<p>Some complex code</p>
<code>
first level of indent
	followed by second
	and still second
back to first
	and second
		and third
	second again
first again
</code>
<p>Break paragraph</p>
<code>
first level of indent
        followed by second
        and still second
back to first
        and second
                and third
        second again
first again
</code>
EOF

is( textmark( $input), $output );


$input = <<EOF;
EOF

$output = <<EOF;
EOF

is( textmark( $input), $output );
done_testing();
