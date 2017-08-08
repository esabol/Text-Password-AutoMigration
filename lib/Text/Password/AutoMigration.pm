package Text::Password::AutoMigration;
our $VERSION = "0.05";

use Moose;
extends 'Text::Password::SHA';

=encoding utf-8

=head1 NAME

Text::Password::AutoMigration - generate and verify Password with any contexts

=head1 SYNOPSIS

 my $pwd = Text::Password::AutoMigration->new();
 my( $raw, $hash ) = $pwd->genarate();          # list context is required
 my $input = $req->body_parameters->{passwd};
 my $data = $pwd->encrypt($input);              # salt is made automatically
 my $flag = $pwd->verify( $input, $data );

=head1 DESCRIPTION

Text::Password::AutoMigration is the Module for lasy Administrators.

It always generates the password with SHA512.
 
And verifies Automatically the hash with
B<CORE::crypt>, B<MD5>, B<SHA-1 by hex>, B<SHA-256> and of course B<SHA-512>.

All You have to do are those:
 
1. use this module

2. replace the hashes in your DB periodically.

=head2 Constructor and initialization

=head3 new()
 
No arguments are required. But you can set some parameters.

=over

=item default

You can set default length with param 'default' like below

 $pwd = Text::Pasword::AutoMiglation->new( default => 12 );

=item readablity

Or you can set default strength for password with param 'readablity'.

It must be a Boolen, default is 1.

If it was set as 0, you can generate stronger passwords with generate()

 $pwd = Text::Pasword::AutoMiglation->new( readability => 0 );

=item migrate

It must be a Boolen, default is 1.

This module is for Administrators who try to replace hashes in their DB.
However, if you've already done to replace them or start to make new Apps with this module,
you can set param migrate as 0. 
Then it will work a little faster to skip making alternative hashes.

=cut

has migrate => ( is => 'rw', isa => 'Bool', default => 1 );

=back

=head2 Methods and Subroutines

=head3 verify( $raw, $hash )

returns true value if the verify is success

Actually, the value is new hash with SHA-512 from $raw

So you can replace hashes in your DB very easily like below
 
 my $pwd = Text::Password::AutoMigration->new();
 my $input = $req->body_parameters->{passwd};
 my $hash = $pwd->verify( $input, $db{passwd} ); # returns hash with SHA-512, and it's true

 if ($hash) { # you don't have to excute this every times
    $succeed = 1;
    my $sth = $dbh->prepare('UPDATE DB SET passwd=? WHERE uid =?') or die $dbh->errstr;
    $sth->excute( $hash, $req->body_parameters->{uid} ) or die $sth->errstr;
 }

=cut

override 'verify' => sub {
    my $self = shift;
    my ( $input, $data ) = @_;
     die __PACKAGE__. " doesn't allow any Wide Characters or white spaces\n"
    if $input !~ /[!-~]/ or $input =~ /\s/;

    if (   $data =~ /^\$6\$[!-~]{1,8}\$[!-~]{86}$/
        or $data =~ /^\$5\$[!-~]{1,8}\$[!-~]{43}$/
        or $data =~ /^[0-9a-f]{40}$/i )
    {
        return $self->encrypt($input) if super() and $self->migrate();
        return super();
    }elsif( $self->Text::Password::MD5::verify(@_) ){
        return $self->encrypt($input) if $self->migrate();
        return $self->Text::Password::MD5::verify(@_);
    }
    return undef;
};

=head3 nonce($length)

generates the strings with enough strength

the length defaults to 8($self->default)

=head3 encrypt($raw)

returns hash with unix_sha512_crypt()

salt will be made automatically
 
=head3 generate($length)

genarates pair of new password and it's hash

not much readable characters(0Oo1Il|!2Zz5sS$6b9qCcKkUuVvWwXx.,:;~-^'"`) are fallen
unless $self->readability is 0.

the length defaults to 8($self->default)
 
=cut

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=head1 SEE ALSO

=over

=item L<GitHub|https://github.com/worthmine/Text-Password-AutoMigration>

=item L<CPAN|http://search.cpan.org/perldoc?Text%3A%3APassword%3A%3AAutoMigration>

=back

=head1 LICENSE

Copyright (C) Yuki Yoshida(worthmine).

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Yuki Yoshida(worthmine) E<lt>worthmine!at!gmail.comE<gt>
