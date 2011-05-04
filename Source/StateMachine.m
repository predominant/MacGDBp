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

#import "StateMachine.h"

#import "State.h"
#import "StateEventData.h"

@implementation StateMachine

- (id)initWithInitialState:(State*)initialState
{
  if ((self = [super init])) {
    initialState_ = [initialState retain];
    pendingEvents_ = [[NSMutableDictionary alloc] init];
    states_ = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)dealloc
{
  [initialState_ release];
  [pendingEvents_ release];
  [states_ release];
  [super dealloc];
}

- (void)startMachine
{
  State* state = [initialState_ autorelease];
  initialState_ = nil;
  [self transitionToState:state];
}

- (BOOL)wantsEvent:(StateEventData*)event
{
  for (StateEventData* pendingEvent in pendingEvents_)
    if ([event matchesPendingEvent:pendingEvent])
      return YES;
  return NO;
}

- (State*)transitionWithEvent:(StateEventData*)event
{
  State* nextState = [[self currentState] transitionWithEvent:event];
  [self transitionToState:nextState];
  return nextState;
}

- (void)transitionToState:(State*)state
{
  if ([self currentState])
    [[self currentState] exitState];
  [states_ addObject:state];
  [state enterState];
}

- (void)state:(State*)state isWaitingForEvent:(StateEventData*)pendingEvent
{
  [pendingEvents_ setObject:state forKey:pendingEvent];
}

- (State*)currentState
{
  if (![states_ count])
    return nil;
  return [states_ lastObject];
}

- (State*)previousState
{
  if ([states_ count] < 2)
    return nil;
  return [states_ objectAtIndex:[states_ count] - 2];
}

- (BOOL)isAtEnd
{
  return [[[self currentState] class] isEndState];
}

@end
