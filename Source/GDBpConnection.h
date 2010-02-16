/*
 * MacGDBp
 * Copyright (c) 2007 - 2010, Blue Static <http://www.bluestatic.org>
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

#import "Breakpoint.h"
#import "StackFrame.h"

@protocol GDBpConnectionDelegate;

@interface GDBpConnection : NSObject
{
	int port;
	BOOL connected;
	
	/**
	 * An ever-increasing integer that gives each transaction a unique ID for
	 * the debugging engine. Managed by |-createCommand:|.
	 */
	int transactionID;
	
	/**
	 * Human-readable status of the connection
	 */
	NSString* status;
	
	// The raw CFSocket on which the two streams are based. Strong.
	CFSocketRef socket_;
	
	// The read stream that is scheduled on the main run loop. Weak.
	CFReadStreamRef readStream_;
	NSMutableString* currentPacket_;
	int packetSize_;
	int currentPacketIndex_;
	
	// To prevent blocked writing, we enqueue all writes and then wait for the
	// write stream to tell us it's ready. We store the pending commands in this
	// array. We use this as a stack (FIFO), with index 0 being first.
	NSMutableArray* queuedWrites_;
	
	// The write stream. Weak.
	CFWriteStreamRef writeStream_;
	
	// A dictionary that maps routingIDs to StackFrame objects.
	NSMutableDictionary* stackFrames_;
	
	id <GDBpConnectionDelegate> delegate;
}

@property (readonly, copy) NSString* status;
@property (assign) id <GDBpConnectionDelegate> delegate;

// initializer
- (id)initWithPort:(int)aPort;

// getter
- (int)port;
- (NSString*)remoteHost;
- (BOOL)isConnected;
- (NSArray*)getCurrentStack;

// communication
- (void)reconnect;
- (void)run;
- (void)stepIn;
- (void)stepOut;
- (void)stepOver;
- (void)addBreakpoint:(Breakpoint*)bp;
- (void)removeBreakpoint:(Breakpoint*)bp;

// helpers
- (NSArray*)getProperty:(NSString*)property;

@end

@protocol GDBpConnectionDelegate <NSObject>

// Passes up errors from SocketWrapper and any other errors generated by the
// GDBpConnection.
- (void)errorEncountered:(NSString*)error;

// Called when the socket connects. Passed up from SocketWrapper.
- (void)debuggerConnected;

// Called when we disconnect.
- (void)debuggerDisconnected;

// Tells the debugger to destroy the current stack display.
- (void)clobberStack;

// Tells the debugger that a new stack frame is avaliable.
- (void)newStackFrame:(StackFrame*)frame;

// A simple step has occurred. Pop the top frame the new current one is provided.
- (void)popStackFrame:(StackFrame*)frame;

@end

