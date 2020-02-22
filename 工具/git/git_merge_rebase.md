#聊一聊git中merge和rebase

昨日，看到以前的老大在朋友圈中发了一条moment

> "作为一个刚入职三天的新职员，如何劝说上级使用rebase，rebase，rebase，不要使用merge，merge，merge"

以前跟着这位老大，每次都是看他使用rebase，现在自己进行项目管理了，平时基本使用的都是merge，刚好今天回忆起来，就来看看什么是rebase，和merge。

**首先可以肯定的是，merge和rebase都可以达到一种效果，就是分支的合并**

## merge

merge很容易理解，就是合并。在项目管理中，假设开始都在一条分支master上开发，到某一个时间点，项目发布出去了。然后新的需求issue来了，我们在当前master新开启一个分支iss53进行开发，如下命令行和图片。

	git branch iss53	 // 新建分支iss53
	git checkout iss53 // 切换分支到iss53
	
	git checkout -b iss53 // 上两个语句的简写

![git_merge_rebase01.png](http://upload-images.jianshu.io/upload_images/1626952-8acfea4679051e78.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


随着工作的进展，iss53每次提交，iss53指针就会不断往后延伸。如下

![git_merge_rebase02.png](http://upload-images.jianshu.io/upload_images/1626952-2af7b2662a66e7db.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

此时，iss53工作已经结束了，可以发布了，需要将iss53的代码合入到主分支master中。

	git checkout master	// 切换回主分支
	git merge iss53 // 合并分支iss53
	
**如果是这种情况，由于master和iss53有同一个父节点，所以只需要将指针master移到iss53处就可以，这种情况称之为`Fast Forward`**

另一种情况，当iss53开发到中途的时候，线上版本出现了一个bug，现在需要切回到主分支master修复，为了不影响master，我们在主分支上新开一个分支hotfix。并在该分支上修改。

	git checkout master 	// 切回主分支
	git checkout -b hotfix	// 在主分支上新开启一个分支hotfix
	
经过一段时间的修改，并且提交新的节点C4，当前指针hotfix指向的也是C4。经过测试C4节点已经成功修改了Bug，所以需要将hotfix合并到主分支master。

![git_merge_rebase03.png](http://upload-images.jianshu.io/upload_images/1626952-58ff0a5ea12b2b92.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

对应的命令行指令是

	git checkout master	// 切换回主分支
	git merge hotfix		// 合并分支hotfix
	
由于master和hotfix有着同样的祖先节点C2，所以合并hotfix分支属于`Fast Forward`

![git_merge_rebase04.png](http://upload-images.jianshu.io/upload_images/1626952-b7b65af66629aa54.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

此时就可以删除hotfix分支了

	git branch -d hotfix // 删除分支hotfix

假设此时iss53也开发完成了，并且测试通过了。现在就需要将iss53分支上的东西合并到master分支上了。如上图，此时当前指针master并不在iss53的祖先节点上。但是我们同样可以通过如下命令进行合并

	git checkout master	// 切换回主分支
	git merge iss53		// 合并分支iss53
	
**此处就不是属于`Fast Forward`，git会主动的去寻找分支master和iss53共同祖先节点C2，然后去判断之后两个分支的修改，进行合并，最后会产生一个新的快照节点C6，而C6节点是包含了master和iss53所以修改的节点**

![git_merge_rebase05.png](http://upload-images.jianshu.io/upload_images/1626952-d39220424f72cd4b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

此时就可以删除iss53分支了

	git branch -d iss53 	// 删除分支iss53
	
*以上，基本上就是merge的基本介绍了*

更详细的可以参照：[分支的新建与合并](https://git-scm.com/book/zh/v1/Git-%E5%88%86%E6%94%AF-%E5%88%86%E6%94%AF%E7%9A%84%E6%96%B0%E5%BB%BA%E4%B8%8E%E5%90%88%E5%B9%B6)


#rebase

从字面意思上来说，可以译为重新构建(重演，衍合)。

首先我们先从下图开始，表示两个分支experiment和master都进行了开发。此处当然可以通过merge来合并experiment(上文已经介绍)。此处我们来解释如何用rebase(衍合)来进行代码的合并，它们两者间的工作原理是不一致的。

![git_merge_rebase06.png](http://upload-images.jianshu.io/upload_images/1626952-653df8f41813fc1e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

进行衍合操作(衍合分支experiment)

	git checkout experiment // 切换到分支experiment(merge操作都是先回到主分支)
	git rebase master	// 在分支master上重演experiment的提交历史
	
> 衍合的工作原理：它的原理是回到两个分支最近的共同祖先，根据当前分支（也就是要进行衍合的分支 experiment）后续的历次提交对象（这里只有一个 C3），生成一系列文件补丁，然后以基底分支（也就是主干分支 master）最后一个提交对象（C4）为新的出发点，逐个应用之前准备好的补丁文件，最后会生成一个新的合并提交对象（C3'），从而改写 experiment 的提交历史，使它成为 master 分支的直接下游，如图 :

![git_merge_rebase07.png](http://upload-images.jianshu.io/upload_images/1626952-7c27d1a7e8a4d238.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

最后回到主分支，进行一次快速合并(`Fast Forward`)即可

	git checkout master	// 切回道主分支
	git merge experiment // 快速合并

![git_merge_rebase08.png](http://upload-images.jianshu.io/upload_images/1626952-55690eb6bc30b68c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

此处的快照节点C3'其时和直接合并产生的快照节点是内容是一致的。但是在提交历史过程中，就感觉是只在一个分支上开发，使的分支都是线性的。这里也将合并分支代码的conflict风险分担到了当前rebase的开发者身上。

另一种理解可以是这样，rebase相当于撤销了当前分支的所有提交，并找到主分支上最后一次提交节点，再之后经过计算，给主分支进行打补丁，最后产生C3'节点。

**以上仅仅是最基本的衍合操作，当有多分支的时候，可以参照以下详细页(感觉太长了。。)**

* 衍合的风险

	***一旦分支中的提交对象发布到公共仓库，就千万不要对该分支进行衍合操作。***
	
更精彩的详情

参照：[rebase-分支-分支的衍合](https://git-scm.com/book/zh/v1/Git-%E5%88%86%E6%94%AF-%E5%88%86%E6%94%AF%E7%9A%84%E8%A1%8D%E5%90%88)

最后，还是提示，光看还是不够的，操作才是硬道理，基于github，边看边玩，想怎么玩都行。	
	

