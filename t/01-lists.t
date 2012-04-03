use strict;
use Test::More;

use Textmark qw/textmark/;

my $input = <<EOF;
* a list
* of
* items
* here
EOF

my $output = <<EOF;
<ul>
<li><p>a list</p></li>
<li><p>of</p></li>
<li><p>items</p></li>
<li><p>here</p></li>
</ul>
EOF

is( textmark( $input ), $output );


$input = <<EOF;
* more complicated
* lists
* * containing a sub list
* * with items
* * * and another sub
* * back to level
* at first again
* blah
* * second sub list
* * with two items
* and a final element
EOF

$output = <<EOF;
<ul>
<li><p>more complicated</p></li>
<li><p>lists</p>
	<ul>
	<li><p>containing a sub list</p></li>
	<li><p>with items</p>
		<ul>
		<li><p>and another sub</p></li>
		</ul>
	</li>
	<li><p>back to level</p></li>
	</ul>
</li>
<li><p>at first again</p></li>
<li><p>blah</p>
	<ul>
	<li><p>second sub list</p></li>
	<li><p>with two items</p></li>
	</ul>
</li>
<li><p>and a final element</p></li>
</ul>
EOF

is( textmark( $input ), $output );

$input = <<EOF;
* testing rapid
* * decreases
* * * and increases
* * * in
* levels
EOF

$output = <<EOF;
<ul>
<li><p>testing rapid</p>
	<ul>
	<li><p>decreases</p>
		<ul>
		<li><p>and increases</p></li>
		<li><p>in</p></li>
		</ul>
	</li>
	</ul>
</li>
<li><p>levels</p></li>
</ul>
EOF

is( textmark( $input ), $output );

$input = <<EOF;
# Testing
# ordered
# lists
EOF

$output = <<EOF;
<ol>
<li><p>Testing</p></li>
<li><p>ordered</p></li>
<li><p>lists</p></li>
</ol>
EOF

is( textmark( $input ), $output );


$input = <<EOF;
# multi
# # level
# # # ordered
# # list
# # items
# being tested
# here
EOF

$output = <<EOF;
<ol>
<li><p>multi</p>
	<ol>
	<li><p>level</p>
		<ol>
		<li><p>ordered</p></li>
		</ol>
	</li>
	<li><p>list</p></li>
	<li><p>items</p></li>
	</ol>
</li>
<li><p>being tested</p></li>
<li><p>here</p></li>
</ol>
EOF

is( textmark( $input ), $output );

$input = <<EOF;
* Testing
* adjacent
# Types
# of
# lists
EOF

$output = <<EOF;
<ul>
<li><p>Testing</p></li>
<li><p>adjacent</p></li>
</ul>
<ol>
<li><p>Types</p></li>
<li><p>of</p></li>
<li><p>lists</p></li>
</ol>
EOF

is( textmark( $input ), $output );

done_testing();

