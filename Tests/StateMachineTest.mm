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

class StateMachineTest : public testing::Test {
 public:
  virtual void SetUp() {
    machine_ = [[StateMachine alloc] initWithInitialState:nil];
  }

  virtual void TearDown() {
    [machine_ release];
  }

  StateMachine* machine() { return machine_; }

  TestState* MakeState() {
    return [[[TestState alloc] initWithMachine:nil historicalEvent:nil] autorelease];
  }

 private:
  StateMachine* machine_;
};

TEST_F(StateMachineTest, InitWithState) {
  TestState* state = MakeState();
  StateMachine* machine = [[[StateMachine alloc] initWithInitialState:state] autorelease];

  EXPECT_FALSE([machine previousState]);
  EXPECT_FALSE([machine currentState]);

  [machine startMachine];
  EXPECT_FALSE([machine previousState]);
  EXPECT_EQ(state, [machine currentState]);
}

TEST_F(StateMachineTest, TransitionToState) {
  TestState* state = MakeState();

  EXPECT_FALSE([machine() previousState]);
  EXPECT_FALSE([machine() currentState]);

  [machine() transitionToState:state];
  EXPECT_FALSE([machine() previousState]);
  EXPECT_EQ(state, [machine() currentState]);
}

TEST_F(StateMachineTest, TransitionThreeTimes) {
  TestState* initial = MakeState();
  TestState* middle = MakeState();
  initial.nextState = middle;
  TestState* end = [[[EndState alloc] initWithMachine:nil historicalEvent:nil] autorelease];
  middle.nextState = end;

  StateMachine* machine = [[[StateMachine alloc] initWithInitialState:initial] autorelease];
  [machine startMachine];

  EXPECT_EQ(nil, [machine previousState]);
  EXPECT_EQ(initial, [machine currentState]);
  EXPECT_FALSE([machine isAtEnd]);

  [machine transitionWithEvent:nil];
  EXPECT_EQ(initial, [machine previousState]);
  EXPECT_EQ(middle, [machine currentState]);
  EXPECT_FALSE([machine isAtEnd]);

  [machine transitionWithEvent:nil];
  EXPECT_EQ(middle, [machine previousState]);
  EXPECT_EQ(end, [machine currentState]);
  EXPECT_TRUE([machine isAtEnd]);
}

TEST_F(StateMachineTest, TransitionAfterEnd) {
  TestState* initial = MakeState();
  TestState* middle = MakeState();
  initial.nextState = middle;
  TestState* end = [[[EndState alloc] initWithMachine:nil historicalEvent:nil] autorelease];
  middle.nextState = end;
  
  StateMachine* machine = [[[StateMachine alloc] initWithInitialState:initial] autorelease];
  [machine startMachine];
  EXPECT_EQ(middle, [machine transitionWithEvent:nil]);
  EXPECT_EQ(end, [machine transitionWithEvent:nil]);

  EXPECT_EQ(middle, [machine previousState]);
  EXPECT_EQ(end, [machine currentState]);
  EXPECT_TRUE([machine isAtEnd]);

  EXPECT_FALSE([machine transitionWithEvent:nil]);
  EXPECT_EQ(middle, [machine previousState]);
  EXPECT_EQ(end, [machine currentState]);
  EXPECT_TRUE([machine isAtEnd]);
}
