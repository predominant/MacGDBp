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

#import "StateEventData.h"

static NSString* const kPendingEventIDKey = @"org.bluestatic.PendingEventID";

@implementation StateEventData

@synthesize info = info_;

- (id)initWithInfo:(NSMutableDictionary*)info
{
  if ((self = [super init])) {
    info_ = [info retain];
    if (!info_) {
      info_ = [[NSMutableDictionary alloc] init];
    }
  }
  return self;
}

- (void)dealloc
{
  [info_ release];
  [super dealloc];
}

- (id)initWithPendingEventID:(id)pendingID
                 contextInfo:(NSMutableDictionary*)info
{
  if ((self = [self initWithInfo:info])) {
    [info_ setObject:pendingID forKey:kPendingEventIDKey];
  }
  return self;
}

- (BOOL)matchesEvent:(StateEventData*)other
{
  id otherKey = [other.info objectForKey:kPendingEventIDKey];
  return [[self.info objectForKey:kPendingEventIDKey] isEqual:otherKey];
}

@end
