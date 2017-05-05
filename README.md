**BACKGROUND:**

This project was originally developed as part of a technical request to Apple Developer Support, to demonstrate a problem I had with some spritekit animations.

The problem I was/am having is that calls to SKNode::runAction* can intermittently cause the app to crash.

It seems that there are problems when using a SpriteKit scene object as an overlay node within a SceneKit app.  

Adding and removing actions to/from a SKNode in such an environment can cause problems because the renderer is multi-threaded, and the internal data structures don't seem to be thread safe.

So this project attempts to identify a work around for the problem so that I can get my game finished whilst Apple engineers find the root cause of the problem and address it in some future version of iOS.

In this project there are two targets, one that has a pure SpriteKit SKView as the root view of the app and another that uses an SCNView with an SKScene set to be it's overlaySKScene.

In both cases there will be a single yellow square that should rotate (perhaps spasmodically) as it is updated by SKActions.  The reason the rotation may not be smooth is that I deliberately set the duration of the animations, and the frequency of their initiation such that new initiations will typically occur before the previous one has finished.

The header file TestConfiguration.h has a number of #defines that may be used to play with the test:

**Scheduling Updates**

These items allow us to configure different techniques for the scheduling of calls to SKNode::runAction*

** ON_MAIN_QUEUE**
Uncommenting this causes all runAction calls to be done within a block on the main queue.  I thought this would
eliminate my crashes however it doesn't.  It may make them less frequent, but they still happen.

**SCHEDULE_MAIN_QUEUE**
Uncommenting this causes the update of the sprite to happen via blocks on the main queue, so that even less is happening
elsewhere.

**FROM_UPDATE_CALLBACK**
I had thought that by deferring all runAction calls to happen from within the SKNode::update: callback, the crash would
go away however this proves not to be the case.  It still happens.

Uncomment this to try this method.  Ensure that ON_MAIN_QUEUE is commented out though.

The idea here is to ensure that the SKActions are being scheduled from within the SceneKit renderer thread via the renderer callback.

**FROM_UPDATE_SCENEKIT_RENDERER_CALLBACK**
Uncomment this to try this method.  Ensure that ON_MAIN_QUEUE and FROM_UPDATE_CALLBACK
are both commented out though.


**runAction Choice**

These items allow us to configure which of the SKNode::runAction* method is used.  Mainly so that we can test if any of
them behave more reliably.

Only enable one of the following at a time, to demonstrate the differences between
the three SKNode::runAction methods.

**RUN_SOLO**
Calls SKNode:runAction:

**RUN_WITH_KEY**
Calls SKNode::runAction:withKey:

**RUN_WITH_COMPLETION**
Calls SKNode::runAction:completion:

**RUN_WITH_MANUAL_REMOVAL**
Explicitly calls SKNode:removeActionForKey: followed by SKNode::runAction:withKey:


**Miscellaneous**

These items can be used to alter how much is actually being done each update.


**INCLUDE_LABEL**
Uncomment if you want an SKLabelNode on screen to tell you how many updates have been done.  This may exacerbate the
problem however.

**USE_CONTAINER_NODE**
The SKScene (GameScene) uses the SKContainerNode to 'contain' any visible SKodes if this is uncommented.  This class
provides a more robust mechanism for removing nodes, as demonstrated for bug #30630031

