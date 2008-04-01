/*
 * MacGDBp
 * Copyright (c) 2007 - 2008, Blue Static <http://www.bluestatic.org>
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

#import "BSLineNumberView.h"


@implementation BSLineNumberView

@synthesize sourceView, lineNumberRange;

/**
 * Initializer for the line number view
 */
- (id)initWithFrame:(NSRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		lineNumberRange = NSMakeRange(0, 0);
	}
	return self;
}

/**
 * Flip the coordinates
 */
- (BOOL)isFlipped
{
	return YES;
}

/**
 * Draws the line numbers whenever necessary
 */
- (void)drawRect:(NSRect)rect
{
	// background color
	[[NSColor colorWithDeviceRed:0.871 green:0.871 blue:0.871 alpha:1] set];
	[NSBezierPath fillRect:rect];
	
	[[NSColor blackColor] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(rect.origin.x, rect.origin.y) toPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.origin.y)];
	
	[[NSColor grayColor] set];
	[NSBezierPath strokeLineFromPoint:NSMakePoint(rect.origin.x, rect.size.height) toPoint:NSMakePoint(rect.origin.x + rect.size.width, rect.size.height)];
	
	// font attributes for the line number
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Monaco" size:9.0], NSFontAttributeName, [NSColor grayColor], NSForegroundColorAttributeName, nil];
	
	lineNumberRange = NSMakeRange(0, 0);
	
	unsigned i = 0, line = 1;
	while (i < [[[sourceView textView] layoutManager] numberOfGlyphs])
	{
		NSRange fragRange;
		NSRect fragRect = [self convertRect:[[[sourceView textView] layoutManager] lineFragmentRectForGlyphAtIndex:i effectiveRange:&fragRange] fromView:[sourceView textView]];
		fragRect.origin.x = rect.origin.x; // horizontal scrolling matters not
		
		// we want to paint the top and bottom line number even if they're cut off
		NSRect testRect = rect;
		testRect.origin.y -= fragRect.size.height - 1;
		testRect.size.height += fragRect.size.height - 1;
		if (NSPointInRect(fragRect.origin, testRect))
		{
			lineNumberRange.location = (lineNumberRange.length == 0 ? line : lineNumberRange.location);
			lineNumberRange.length++;
			NSString *num = [NSString stringWithFormat:@"%u", line];
			NSSize strSize = [num sizeWithAttributes:attrs];
			[num drawAtPoint:NSMakePoint([self frame].size.width - strSize.width - 3, fragRect.origin.y + ((fragRect.size.height - strSize.height) / 2)) withAttributes:attrs];
		}
		
		i += fragRange.length;
		line++;
	}
}

/**
 * Handles the mouse down event (which is adding, deleting, and toggling breakpoints)
 */
- (void)mouseDown:(NSEvent *)event
{
	NSTextView *textView = [sourceView textView];
	
	NSPoint clickLoc = [self convertPoint:[event locationInWindow] fromView:nil];
	
	unsigned line = 1;
	unsigned i = 0;
	while (i < [[textView layoutManager] numberOfGlyphs])
	{
		NSRange fragRange;
		NSRect fragRect = [[textView layoutManager] lineFragmentRectForGlyphAtIndex:i effectiveRange:&fragRange];
		fragRect.size.width = [self bounds].size.width;
		if (NSPointInRect(clickLoc, fragRect))
		{
			[[sourceView delegate] gutterClickedAtLine:line forFile:[sourceView file]];
			return;
		}
		
		i += fragRange.length;
		line++;
	}
}

@end
