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

#include <gtest/gtest.h>

#include "Fixtures.h"
#include "StateEventData.h"
#include "StateMachine.h"
#include "StateSystemController.h"

class StateSystemControllerTest : public testing::Test {
 public:
  virtual void SetUp() {
    controller_ = [[StateSystemController alloc] init];
  }

  virtual void TearDown() {
    [controller_ release];
  }

  StateSystemController* controller() { return controller_; }

 private:
  StateSystemController* controller_;
};

TEST_F(StateSystemControllerTest, Init)
{
}

TEST_F(StateSystemControllerTest, SingleStateMachine)
{
  TestState* state = [[TestState alloc] initWithMachine:nil historicalEvent:nil];
  StateMachine* machine = [[StateMachine alloc] initWithInitialState:state];
  [controller() startMachine:machine];
  EXPECT_EQ(state, [machine currentState]);
  [state release];
  [machine release];
}

TEST_F(StateSystemControllerTest, DispatchEvent)
{
  TestState* state = [[TestState alloc] initWithMachine:nil historicalEvent:nil];
  StateMachine* machine = [[StateMachine alloc] initWithInitialState:state];
  TestState* nextState = [[TestState alloc] initWithMachine:machine historicalEvent:nil];
  state.nextState = nextState;

  StateEventData* pendingEvent = [[[StateEventData alloc] initWithPendingEventID:@"peid"
                                                                     contextInfo:nil] autorelease];
  [machine waitForEvent:pendingEvent];

  [controller() startMachine:machine];
  EXPECT_FALSE([machine previousState]);
  EXPECT_EQ(state, [machine currentState]);

  StateEventData* realEvent = [[[StateEventData alloc] initWithPendingEventID:@"peid"
                                                                  contextInfo:nil] autorelease];
  [controller() dispatchEvent:realEvent];
  EXPECT_EQ(state, [machine previousState]);
  EXPECT_EQ(nextState, [machine currentState]);

  [state release];
  [nextState release];
  [machine release];
}
