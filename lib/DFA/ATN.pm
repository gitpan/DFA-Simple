#!/usr/bin/perl -Tw
#Copyright 1998-1999, Randall Maas.  All rights reserved.  This program is free
#software; you can redistribute it and/or modify it under the same terms as
#PERL itself.

=head1 NAME

C<DFA::ATN> -- An augmented transition network object.

=head1 DESCRIPTION

   my $Obj = new DFA::ATN $Actions,[States];

This creates a powerful automaton with a finite number of individual states.
It inherits many of its methods from L<DFN::Simple>.
The object is composed of the following three things (with methods to match):

=over 1

=item I<State>

The object has a particular state it is in; a specific state from a set of
possible states.  L<DFA::Simple>

=item I<State Stack>

You can push a stack onto the stack, or pop one off.  The register frame is
saved and restored as well.

=item I<Actions>

The object when enterring or leaving a state may perform some action.
L<DFA::Simple>

=item I<Rules>

The object has rules for determining what its next state should be, and how to
get there.
L<DFA::Simple>

=item I<Registers>

The object has the method for storing and retrieving information about its
processing.

=back

=head2 The State Stack

    $Obj->Save;
    $Obj->Restore;

C<Save> will save the current state of the automaton, including the registers.

C<Restore> will restore the automaton's previously saved state and registers.

=head2 Register

   $Obj->Register->{'name'}='fred';

C<Register> is a method that can set or get the objects register reference.
This is a information that the actions, conditions, or transitions can employ
in their processing.  The reference can be anything.  It is otherwise not used
by the object implementation.

=head1 Installation

    perl Makefile.PL
    make
    make install

=head1 Author

Randall Maas (L<randym@acm.org>, L<http://www.hamline.edu/~rcmaas/>)

=cut

package DFA::ATN;
@ISA=qw(DFA::Simple);

#The structure of the node is:
#[CurrentState,Transitions,States, Stack, Registers]

sub Register
{
   my $self = shift;

   if (!ref $self)
     {
        #Called as class method
        $self = $Base;
     }

   if (@_)
     {
	#Called to set the actions
	$self->[4] = shift;
     }
   $self->[4];
}

sub Save
{
   my $self=shift;
   #Save the state and frame
   push @{$self->[3]}, $self->State, [@{$self->Register}];
}

sub Pop
{
   my $self=shift;
   $self->Register = pop @{$self->[3]};
   $self->State(pop @{$self->[3]});
}
