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

@class StateEventData;
@class StateMachine;

// A state is a logical unit of work that happens in response to some stimuli.
// States transition between each other on events.
@interface State : NSObject {
 @private
  StateMachine* machine_;
  StateEventData* event_;
}

// Creates a new state with the option of carrying content over through the
// shared data structure.
- (id)initWithMachine:(StateMachine*)machine
      historicalEvent:(StateEventData*)data;

// Creates a machine with an instance of this state as the initial state.
+ (StateMachine*)newAsInitialState;

// Checks whether this state should terminate the execution of the machine,
// making it the last state.
+ (BOOL)isEndState;

// These methods are called by the machine when it is transitioning to and from
// a new state. It is ILLEGAL to transition from these methods as a transition
// is currently in progress when these are called.
- (void)enterState;
- (void)exitState;

// Given an event, the state will produce its next state. The machine will
// transition away from this state to the state returned by this method.
- (State*)transitionWithEvent:(StateEventData*)event;

@end
