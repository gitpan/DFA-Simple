#!/usr/bin/perl -Tw
#Copyright 1998-1999, Randall Maas.  All rights reserved.  This program is free
#software; you can redistribute it and/or modify it under the same terms as
#PERL itself.

=head1 NAME

C<DFA::Simple> -- A PERL module to implement simple Discrete Finite Automata

=head1 SYNOPSIS

   my $Obj = new DFA::Simple

or

   my $Obj = new DFA::Simple $Transitions;

or

   my $Obj = new DFA::Simple $Actions, $StateRules;

   $Obj->Actions = [...];
   my $Trans = $LP->Actions;

   $Obj->StateRules = [...];
   my $StateRules = $LP->StateRules;


=head1 DESCRIPTION

   my $Obj = new DFA::Simple $Actions,[States];

This creates a simple automaton with a finite number of individual states.
The object is composed of the following three things (with methods to match):

=over 1

=item I<State>

The object has a particular state it is in; a specific state from a set of
possible states

=item I<Actions>

The object when enterring or leaving a state may perform some action.

=item I<Rules>

The object has rules for determining what its next state should be, and how to
get there.

=back

=head2 State

C<State> is a method that can get the current state or initiate a transition to
a new state.

   my $S = $Obj->State;

   $Obj->State = $NewState;

The last one leaves the current state and goes to the specified I<NewState>.
If the current state is defined, its I<StateExitCodeRef> will be called (see
below).  Then the new states I<StateEnterCodeRef> will be called (if defined)
(see below).  Cavaet, no check is made to see if the new state is the same as
the old state; this can be used to `reset' the state.

=head2 Actions

C<Actions> is a method that can set or get the objects list of actions to
perform when enterring or leaving a particular state.

   my $Actions = $Obj->Actions;

   $Obj->Actions = [
		   [StateEnterCodeRef, StateExitCodeRef],
		 ];

   
I<Actions> is an array reference describing what to do when enterring and
leaving various states.  When a state is entered, its I<StateEnterCodeRef>
will be called (if defined).   When a state is left (as in going to a new
state) its I<StateExitCodeRef> will be called (if defined).


=head2 StateRules

   my $StateRules = [
		     #Rules for state 0
		     [
		      [NextState, Test, Thing to do after getting there
		      ],

		     #Rules for state 1
		     [
		      ...
		      ],
		     ];

=head1 Installation

    perl Makefile.PL
    make
    make install

=head1 Author

Randall Maas (L<randym@acm.org>, L<http://www.hamline.edu/~rcmaas/>)

=cut


package DFA::Simple;
use Carp;
my $Base=[];
1;

#The structure of the node is:
#[CurrentState,Transitions,States, ...]

sub new
{
   my $self=shift;
   my $B=[@{$Base}];
   if (@_) {$B->[1]=shift;}
   if (@_) {$B->[2]=shift;}
   if (@_) {$B->[3]=shift;}
   return bless $B, $self;
}

sub Actions
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
	$self->[1] = shift;
     }
   $self->[1];
}

sub State
{
   my $self=shift;

   if (!ref $self)
     {
        #Called as class method
        $self = $Base;
     }

   my $CState=$self->[0];

   if (!@_)
     {
	#Caller is just getting some info;
	return $CState;
     }

   my $Acts = $self->Actions;
   if (!defined $Acts)
     {
	croak "DFA::Simple: No transition actions!\n";
     }

   if (!defined $self->[2])
     {
	croak "DFA::Simple: No states defined!\n"; 
     }

   my $NS = shift;
   $CurrentStateTable=$self->[2]->[$NS];
   $self->[0]=$NS;

   #Handle the state exit rule
   if (defined $CState && defined $Acts->[$CState] &&
       defined $Acts->[$CState]->[1])
     {
	my $A = $Acts->[$CState]->[1];
        &$A($self);
     }

   #Handle the transition rule...
   if (defined $Acts->[$NS]->[0])
     {
	my $A = $Acts->[$NS]->[0];
        &$A($self);
     }
}

#Each state transition rule is like so:
# [$NextState, $Testcoderef, $DoCodeRef]

sub Check_For_NextState
{
   if (!defined($_[0]->[0]))
     {
        $_[0]->State(0);
     }

   foreach my $I (@{$CurrentStateTable})
    {
       #Perform the test
       if (defined $I->[1])
	 {
	    my $CodeRef=$I->[1];
	    if (!&$CodeRef($_[0])) {next;}
         }

       #Set up for the next state;
       if ($_[0]->[0] ne $I->[0])
         {
	    $_[0]->State($I->[0]);
         }

       #Do the rules
       if (defined $I->[2]) {&{$I->[2]}();}
      
       return; 
    }
   croak "Unusual circumstances?\n";
}

sub DoTheStateMachine
{
   while(<>)
   {
       Check_Current_State_Table_For_Next_Rule();
   }
}

