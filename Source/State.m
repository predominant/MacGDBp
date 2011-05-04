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

#import "State.h"

#import "StateMachine.h"

@implementation State

@synthesize machine = machine_;

- (id)initWithMachine:(StateMachine*)machine
      historicalEvent:(StateEventData*)data
{
  if ((self = [super init])) {
    machine_ = machine;
    event_ = data;
  }
  return self;
}

+ (StateMachine*)newAsInitialState
{
  State* state = [[[State alloc] initWithMachine:nil historicalEvent:nil] autorelease];
  StateMachine* machine = [[StateMachine alloc] initWithInitialState:state];
  state.machine = machine;
  return machine;
}

+ (BOOL)isEndState
{
  return NO;
}

- (void)enterState
{}

- (void)exitState
{}

- (State*)transitionWithEvent:(StateEventData*)event
{
  return nil;
}

@end
