**BACKGROUND:**

This project was originally developed as part of a technical request to Apple Developer Support, to demonstrate a problem I had with some spritekit animations.

The project contains the complete solution as suggested by the Apple engineer (thanks!) with some code-tidyup on my part to try and formalise the solution.

Essentially, I had attributed text labels being updated on the fly and because of the way they work, doing this outside the rendered thread could cause crashes.

The Apple engineer showed me that I needed to defer the actual updates to the renderer thread in it's update callback.

This then highlighted the need to be able to manage this, and in a very long conversation with Apple, I decided to do so with a manager class which is used as a container for any nodes needing attention during the update callback.

I then found problems with my implementation whereby nodes needed to "know" when they are no longer in the node tree so that they could automatically remove themselves from the new manager (and thus, not cause a crash in the update thread).

The Apple engineer suggested that I use the SKNode.removeFromParent message to let a node know when it is no longer part of the node tree however this does not always work, as the internal implementation does not consistently release objects when this is done.

I ended up enhancing this project to demonstrate the problems with removeFromParent (and the other removeFromParent like methods), and this repo is the result.

I will be submitting this project to Apple as a bug report in an attempt to get a consistent, and leak-free implementation of removeFromParent.

**INSTRUCTIONS:**

This project is a stock standard SceneKit app as created by Xcode 8, with the alterations as outlined above.

Within the GameScene class, there are a number of #define's that can be used to demonstrate the behaviours I've mentioned:

    #define TEST_REMOVAL

If uncommented, then the project will update the label 100 times before removing it from the node tree, at which time, a dealloc call should occur (traced).

In addition to this:

    #define TEST_VIA_REMOVE_FROM_PARENT

Will cause the removal to be done via a call to removeFromParent.  This will not cause a call to dealloc, resulting in a leak.

    #define TEST_VIA_REMOVE_ALL_CHILDREN

Will cause the removal to be done via a call to removeAllChildren.  This does call dealloc.

    #define TEST_VIA_REMOVE_CHILDREN

Will cause the removal to be done via a call to removeChildrenInArray.  This does call dealloc.

 

**ContainerNode**

Finally, as a workaround for the leak in removeFromParent, I created a node called ContainerNode that is a direct subclass of SKNode.  It overrides each of the removal messages so that all work in a consistent manner.

This can be demonstrated by uncommenting:

    //#define USE_CONTAINER_NODE 1

With this done, all of the above tests will result in a dealloc, showing that the leak has been corrected.
