package MojoMojo::Formatter::Textile;

use parent 'MojoMojo::Formatter';

use Text::Textile;
use Text::SmartyPants;
my $textile = Text::Textile->new(
    flavor => 'xhtml1',
    charset => 'utf-8',
    char_encoding => 0,  # don't encode any other entities than <, >, " and &
);

# We do not want Text::Textile to encode HTML entities at all because that will
# conflict with with <pre> tags generated by SyntaxHighlight. SyntaxHighlight
# already converts C<< < >> and C<< > >> to C<&lt;> and C<&gt;,> and letting
# Textile process that again will produce C<&amp;lt;> and C<&amp;gt;>
{
    no strict 'refs';
    no warnings;
    *{"Text::Textile::encode_html"} = sub { my ($self, $html) = @_; return $html; };
}

=head1 NAME

MojoMojo::Formatter::Textile - Texile+SmartyPants formatting for your content

=head1 DESCRIPTION

This formatter processes content using L<Text::Textile> (a syntax for writing
human-friendly formatted text), then post-processes that using L<Text::SmartyPants>
(which transforms plain ASCII punctuation characters into "smart" typographic
punctuation HTML entities, such as smart quotes or the ellipsis character).

Textile reference: <http://hobix.com/textile/>

=head1 METHODS

=head2 main_format_content

Calls the formatter. Takes a ref to the content as well as the
context object. Note that this is different from the format_content method
of non-main formatters. This is because we don't want all main formatters
to be called when iterating over pluggable modules in
L<MojoMojo::Schema::ResultSet::Content::format_content>.

C<main_format_content> will only be called by <MojoMojo::Formatter::Main>.

=cut

sub main_format_content {
    my ( $class, $content ) = @_;

    $$content = $textile->process($$content);
    $$content = Text::SmartyPants->process($$content);
    # for uniformity with Markdown, make sure the output ends with *one* newline.
    # See justification in L<MojoMojo::Formatter::Markdown/format_content>.
    $$content =~ s/\n*$/\n/;
    return $$content;
}

=head1 SEE ALSO

L<MojoMojo>, L<Module::Pluggable::Ordered>, L<Text::Textile>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
