//
//  main.m
//  «PROJECTNAME»
//
//  Created by «FULLUSERNAME» on «DATE».
//  Copyright «YEAR» «ORGANIZATIONNAME». All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Nu/Nu.h>

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	id nu = [Nu parser];
	for (NSString *nuFile in [[NSBundle mainBundle] pathsForResourcesOfType:@"nu" inDirectory:@"nu"])
		[nu eval:[nu parse:[NSString stringWithContentsOfFile:nuFile]]];
	[nu close];
	[pool release];
	
    return NSApplicationMain(argc,  (const char **) argv);
}
