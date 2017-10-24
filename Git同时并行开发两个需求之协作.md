# Git多分支协作，减少master分支冲突的一种方案

**我们都知道，在使用Git作为版本管理，开发协作时候。master分支基本上代表着即将发布到生产环境的代码，在如此重要的分支中，是需要尽量减少它出错的概率的。**

### 场景描述

这里希望描述的一种场景是，有两个并行的需求，需要同时开发。

1. 一是这两个需求的上线日期接近
2. 二是这两个需求修改的文件耦合度很高。

可能出现的问题： 如此可以想象到，最终合并分支代码回到master后，一定会在master上产生过多的冲突，而解决过多的冲突中可能会无意的修改到原来的业务逻辑，导致最终部署到生产环境后出现错误。

希望： 现在则希望在合并回到master分支后，不产生过多的冲突，避免master分支合并的简易，降低出现错误的可能性。

### 如何并行开始两个需求

当确定开始并行的两个需求时，一般会从master分支checkout两个分支，一般以需求命名。之后在对应的分支上完成需求的开发，开发完成并测试后会合并分支回master。

![crate_branch.png](http://upload-images.jianshu.io/upload_images/1626952-499f3c4b864d6b2a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 降低合并回master冲突的数量

再需求完成后，现在需要合并回master分支。我们先将`dev_task_1`分支合并回master，该分支合并不会有冲突，因为该分支从master中checkout后没有受到其他分支影响。

之后，我们需要将`dev_task_2`合并回到master分支中，这个时候由于和`dev_task_1`修改的文件耦合度很高，所以，必然会在master出现大量的冲突。

![merge.png](http://upload-images.jianshu.io/upload_images/1626952-7c1cb7da7b974599.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

此时，我们可以先从已经合并了`dev_task_1`的master中checkout一个零时分支`temp_branch`。之后将`dev_task_2`合并到分支`temp_branch`，此时所有的冲突会出现在`temp_branch`中，只需要在这里解决完所有的冲突，并在此测试通过后。

![merge_temp.png](http://upload-images.jianshu.io/upload_images/1626952-ab47ccb5c2a8efbf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

就可以将`temp_branch`合并回master了。此时就不会在master出现冲突。

![merge_to_master.png](http://upload-images.jianshu.io/upload_images/1626952-95a5d211f6489a30.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 总结

整个过程并没有减少冲突的数量，只是通过转换冲突产生的分支，从而在降低了在master上解决冲突带来的风险。在此，你可能会吐槽，但是在多人协作的项目中，很多时候，master分支合并的权限你并没有，此时，需要他人来合并你开发的代码。对你的业务逻辑并不是很了解，就很有可能在解决冲突的时候出现错误。而且当一个需求开发完，不一定立即就会合并到master分支，当经历了一段时间后，此时自己已经有一点生疏，此时再合并回主分支的时候，也有可能产生错误。

所以当你开发完一个需求后，并通过测试后，就可以依照上诉的方法，通过生成一个新的分支，并在该分支解决完所有的冲突。然后等待他人来合并。

****

**认为有用则点赞关注，无用飘过**