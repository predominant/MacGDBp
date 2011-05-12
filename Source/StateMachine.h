/*
 * MacGDBp
 * Copyright (c) 2011, Blue Static <http://www.bluestatic.org>
 * 
 * This program is free software; you can redistribute it and/or modify it under the terms of the GNU 
 * General Public License as published by the Free Software Foundation; either version 2 of the 
 * License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without 
 * even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
 * General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
 */

#import <Cocoa/Cocoa.h>

@class State;
@class StateEventData;

// A StateMachine manages the transitions from one state to another.
@interface StateMachine : NSObject {
 @private
  State* initialState_;  // strong
  StateEventData* pendingEvent_;  // weak
  NSMutableArray* states_;
}

// Creates a new machine with a given initial state. The machine must be started
// before any work will be done.
- (id)initWithInitialState:(State*)initialState;

// This starts the state machine by transitioning to the initial state.
- (void)startMachine;

// Checks if the machine can dispatch the event.
- (BOOL)wantsEvent:(StateEventData*)event;
// Causes the machine to transition from the current state to its next state
// based on the event.
- (State*)transitionWithEvent:(StateEventData*)event;

// These methods are meant to be used by a State:
// This causes the machine to perform an actual transition and calls the
// appropriate methods on each state, as well as updating the internal context.
- (void)transitionToState:(State*)state;
// Notifies the machine that the current state is waiting for a specific event
// response before transitioning.
- (void)waitForEvent:(StateEventData*)event;

// Queries the machine for the current state.
- (State*)currentState;
// Queries the machine for the state it was previously in.
- (State*)previousState;
// Checks if the machine is done executing by asking if the current state is an
// end state.
- (BOOL)isAtEnd;

@end
