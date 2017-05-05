//
//  TestConfiguration.h
//  TestSKActionCalls
//
//  Created by Peter Easdown on 5/5/17.
//  Copyright © 2017 PKCLsoft. All rights reserved.
//

#ifndef TestConfiguration_h
#define TestConfiguration_h

/***********
 *
 * These items allow us to configure different techniques for the scheduling of calls to SKNode::runAction*
 *
 ***********/

// Uncommenting this causes all runAction calls to be done within a block on the main queue.  I thought this would
// eliminate my crashes however it doesn't.  It may make them less frequent, but they still happen.
//
//#define ON_MAIN_QUEUE 1

// Uncommenting this causes the update of the sprite to happen via blocks on the main queue, so that even less is happening
// elsewhere.
//
//#define SCHEDULE_MAIN_QUEUE 1

// I had thought that by deferring all runAction calls to happen from within the update: callback, the crash would
// go away however this proves not to be the case.  It still happens.
// Uncomment this to try this method.  Ensure that ON_MAIN_QUEUE is commented out though.
//#define FROM_UPDATE_CALLBACK 1

// My last ditch attempt to fix this problem (for now).  The idea here is to ensure that the SKActions are being
// scheduled from within the SceneKit renderer thread via the renderer callback.
//
// Uncomment this to try this method.  Ensure that ON_MAIN_QUEUE and FROM_UPDATE_CALLBACK
// are both commented out though.
//
#define FROM_UPDATE_SCENEKIT_RENDERER_CALLBACK 1


/***********
 *
 * These items allow us to configure which of the SKNode::runAction* method is used.  Mainly so that we can test if any of
 * them behave more reliably.
 *
 ***********/

// Only enable one of the following at a time, to demonstrate the differences between
// the three SKNode::runAction methods.
//
#define RUN_SOLO 1
//#define RUN_WITH_KEY 1
//#define RUN_WITH_COMPLETION 1
//#define RUN_WITH_MANUAL_REMOVAL 1

/***********
 *
 * These items can be used to alter how much is actually being done each update.

 ***********/

// Uncomment if you want an SKLabelNode on screen to tell you how many updates have been done.  This may exacerbate the
// problem however.
//
//#define INCLUDE_LABEL

// The SKScene (GameScene) uses the SKContainerNode to 'contain' any visible SKodes if this is uncommented.  This class
// provides a more robust mechanism for removing nodes, as demonstrated for bug #30630031
//
#define USE_CONTAINER_NODE 1

#endif /* TestConfiguration_h */
