#import "GameScene.h"

#define USE_CONTAINER_NODE 1

#ifdef USE_CONTAINER_NODE
#import "SKContainerNode.h"
#endif

@interface GameScene()

@property (nonatomic, retain) SKLabelNode *normalLabel;
@property (nonatomic, retain) SKSpriteNode *sprite;
@property (nonatomic, assign) float newAngle;

#ifdef USE_CONTAINER_NODE
@property (nonatomic, retain) SKContainerNode *containerNode;
#else
@property (nonatomic, retain) SKNode *containerNode;
#endif

@end

@implementation GameScene {
    NSUInteger counter;
    NSUInteger spriteUpdateCounter;
}

- (id) initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    
    if (self != nil) {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        counter = 0;

#ifdef USE_CONTAINER_NODE
        self.containerNode = [SKContainerNode node];
#else
        self.containerNode = [SKNode node];
#endif

        self.normalLabel = [SKLabelNode labelNodeWithText:@"normalLabel"];
        self.normalLabel.position = CGPointMake(0.0, size.height/4.0);
        [self.containerNode addChild:self.normalLabel];

        self.sprite = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:CGSizeMake(50.0, 50.0)];
        self.sprite.position = CGPointMake(0.0, size.height/2.0 - 60.0);
        [self addChild:self.sprite];

        self.newAngle = 0.0;
        spriteUpdateCounter = 0;

        [self addChild:self.containerNode];

        // update the label every 100ms.
        //
        [self performSelector:@selector(updateLabels) withObject:nil afterDelay:0.1];

        // If the update is to be done every frame, don't schedule this way.
        //
#ifndef FROM_UPDATE_CALLBACK
        // update the sprite far more often.
        [self performSelector:@selector(updateSprite) withObject:nil afterDelay:0.01];
#endif
    }
    
    return self;
}

+ (GameScene*) gameSceneWithSize:(CGSize)size {
    return [[GameScene alloc] initWithSize:size];
}

// Uncommenting this causes all runAction calls to be done within a block on the main queue.  I thought this would
// eliminate my crashes however it doesn't.  I may make them less frequent, but they still happen.
//
#define ON_MAIN_QUEUE

// I had thought that by deferring all runAction calls to happen from within the update: callback, the crash would
// go away however this proves not to be the case.  It still happens.
// Uncomment this to try this method.  Ensure that ON_MAIN_QUEUE is commented out though.
//#define FROM_UPDATE_CALLBACK

// Only enable one of the following at a time, to demonstrate the differences between
// the three SKNode::runAction methods.
//
#define RUN_SOLO
//#define RUN_WITH_KEY
//#define RUN_WITH_COMPLETION
//#define RUN_WITH_MANUAL_REMOVAL

- (void) updateSprite {
    const float duration = 1.0/30.0;

    self.newAngle += 10.0; // degrees

    self.newAngle = fmodf(self.newAngle, 360.0);

    spriteUpdateCounter++;

#ifdef ON_MAIN_QUEUE
    dispatch_async(dispatch_get_main_queue(), ^{
#endif

#ifdef RUN_SOLO
        // This crashes with:
        //
        // 2017-05-05 12:38:59.456 TestSKActionCalls[5439:648467] *** Terminating app due to uncaught exception
        // 'NSGenericException', reason: '*** Collection <__NSArrayM: 0x15d94a10> was mutated while being enumerated.'
        // *** First throw call stack:
        // (0x20a6791b 0x20202e17 0x20a673a1 0x2cd86e85 0x2cd41b09 0x2ccfbc7b 0x2ccfb9e7 0x2ccfba97 0x2cd0e339 0x2cce8d4d 0x2cce6bc1
        //  0x2d784e1d 0x2d7d940d 0x2d7d9db1 0x2d6f74fd 0x2d784481 0x2d784597 0x2d784a29 0x2d7d47bb 0x2d7b0a49 0x449b7f 0x454493
        //  0x44cde1 0x455975 0x457a57 0x2079b85b 0x2079b7cf 0x20799724)
        // libc++abi.dylib: terminating with uncaught exception of type NSException
        //
        // #0	0x206f2c5c in __pthread_kill ()
        // #1	0x2079c732 in pthread_kill ()
        // #2	0x206870ac in abort ()
        // #3	0x201deae4 in abort_message ()
        // #4	0x201f769e in default_terminate_handler() ()
        // #5	0x202030b0 in _objc_terminate() ()
        // #6	0x201f4e16 in std::__terminate(void (*)()) ()
        // #7	0x201f45f4 in __cxa_throw ()
        // #8	0x20202eea in objc_exception_throw ()
        // #9	0x20a673a0 in __NSFastEnumerationMutationHandler ()
        // #10	0x2cd86e84 in -[NSMutableArray(removeExactObject) removeExactObject:] ()
        // #11	0x2cd41b08 in -[SKNode(removeInternal) _removeAction:] ()
        // #12	0x2ccfbc7a in SKCNode::removeAction(SKCAction*) ()
        // #13	0x2ccfb9e6 in SKCNode::update(double, float) ()
        // #14	0x2ccfba96 in SKCNode::update(double, float) ()
        // #15	0x2cd0e338 in -[SKScene _update:] ()
        // #16	0x2cce8d4c in -[SKSCNRenderer _update:] ()
        // #17	0x2cce6bc0 in -[SKSCNRenderer updateAtTime:] ()
        // #18	0x2d784e1c in -[SCNRenderer _drawOverlaySceneAtTime:] ()
        // #19	0x2d7d940c in __C3DEngineContextRenderPassInstance ()
        // #20	0x2d7d9db0 in C3DEngineContextRenderMainTechnique ()
        // #21	0x2d6f74fc in C3DEngineContextRenderScene ()
        // #22	0x2d784480 in -[SCNRenderer _drawSceneWithLegacyRenderer:] ()
        // #23	0x2d784596 in -[SCNRenderer _drawScene:] ()
        // #24	0x2d784a28 in -[SCNRenderer _draw] ()
        // #25	0x2d7d47ba in -[SCNView _drawAtTime:] ()
        //
        [self.sprite runAction:[SKAction rotateToAngle:GLKMathDegreesToRadians(self.newAngle) duration:duration]];
#endif

#ifdef RUN_WITH_KEY
        // This will crash after a while.  it's not consistent, but I've seen it crash after as little as 8000 updates,
        // or as many as 120000
        [self.sprite runAction:[SKAction rotateToAngle:GLKMathDegreesToRadians(self.newAngle) duration:duration] withKey:@"rotateSprite"];
#endif

#ifdef RUN_WITH_MANUAL_REMOVAL
        // This seems to crash much more quickly.
        //
        [self.sprite removeActionForKey:@"rotateSprite"];

        [self.sprite runAction:[SKAction rotateToAngle:GLKMathDegreesToRadians(self.newAngle) duration:duration] withKey:@"rotateSprite"];
#endif

#ifdef RUN_WITH_COMPLETION
        // This crashes too with the following:
        //
        // 2017-05-05 12:31:00.295 TestSKActionCalls[5427:646805] *** Terminating app due to uncaught exception 'NSRangeException',
        // reason: '*** -[__NSArrayM insertObject:atIndex:]: index 20 beyond bounds [0 .. 18]'
        // *** First throw call stack:
        // (0x20a6791b 0x20202e17 0x2097cded 0x2cd48517 0x2cd486a9 0x3cca5 0x3bab7f 0x3bab6b 0x3bf655 0x20a29b6d 0x20a28067
        //  0x20977229 0x20977015 0x21f67ac9 0x2504b189 0x3e7ab 0x2061f873)
        // libc++abi.dylib: terminating with uncaught exception of type NSException
        //
        // 2017-05-05 12:33:14.665 TestSKActionCalls[5427:646871] *** Terminating app due to uncaught exception
        // 'NSInvalidArgumentException', reason: '*** -[__NSPlaceholderArray initWithObjects:count:]: attempt to insert nil object
        // from objects[0]'
        // *** First throw call stack:
        //
        // #10	0x20202eea in objc_exception_throw ()
        // #11	0x2097cdec in -[__NSArrayM insertObject:atIndex:] ()
        // #12	0x2cd48516 in -[SKNode _runAction:] ()
        // #13	0x2cd486a8 in -[SKNode runAction:completion:] ()
        // #14	0x0003cca4 in __25-[GameScene updateSprite]_block_invoke at .../TestSKActionCalls/GameScene.m:128
        // #15	0x003bab7e in _dispatch_call_block_and_release ()
        // #16	0x003bab6a in _dispatch_client_callout ()
        // #17	0x003bf654 in _dispatch_main_queue_callback_4CF ()
        //
        [self.sprite runAction:[SKAction rotateToAngle:GLKMathDegreesToRadians(self.newAngle) duration:duration] completion:^{
        }];
#endif

#ifdef ON_MAIN_QUEUE
    });
#endif

#ifndef FROM_UPDATE_CALLBACK
    // update the sprite every 1ms.   this is artificially frequent so that we can be sure that we attampt to call
    // runAction before the previous instance of the action can complete.  I believe that the crashes occur because there
    // is a problem inside SKNode that doesn't handle this situation reliably.
    //
    [self performSelector:@selector(updateSprite) withObject:nil afterDelay:0.001];
#endif
}

- (void) updateLabels {
    NSString *labelText = [NSString stringWithFormat:@"count: %lu", (unsigned long)spriteUpdateCounter];
    self.normalLabel.text = labelText;

    counter++;

    [self performSelector:@selector(updateLabels) withObject:nil afterDelay:0.01];
}

#ifdef FROM_UPDATE_CALLBACK
-(void) update:(NSTimeInterval)currentTime {
    // so this will update the sprite actions once per frame which isn't as frequent, but it ensures that the actions are not
    // added/removed outside the update callback.
    //
    [self updateSprite];
}
#endif

- (void) dealloc {
}

@end
