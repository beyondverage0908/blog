#聊一聊git中merge和rebase

昨日，看到以前的老大在朋友圈中发了一条moment

> "作为一个刚入职三天的新职员，如何劝说上级使用rebase，rebase，rebase，不要使用merge，merge，merge"

以前跟着这位老大，每次都是看他使用rebase，现在自己进行项目管理了，平时基本使用的都是merge，刚好今天回忆起来，就来看看什么是rebase，和merge。

* merge

merge很容易理解，就是合并。在项目管理中，假设开始都在一条分支master上开发，到某一个时间点，项目发布出去了。然后新的需求issue来了，我们在当前master新开启一个分支iss53进行开发，如下命令行和图片。

	git branch iss53	 // 新建分支iss53
	git checkout iss53 // 切换分支到iss53
	
	git checkout -b iss53 // 上两个语句的简写

![](/Users/pingjunlin/Desktop/git_merge_rebase01.png)

随着工作的进展，iss53每次提交，iss53指针就会不断往后延伸。如下

![](/Users/pingjunlin/Desktop/git_merge_rebase02.png)

此时，iss53工作已经结束了，可以发布了，需要将iss53的代码合入到主分支master中。

	git checkout master	// 切换回主分支
	git merge iss53 // 合并分支iss53
	
**如果是这种情况，由于master和iss53有同一个父节点，所以只需要将指针master移到iss53处就可以，这种情况称之为`Fast Forward`**

另一种情况，当iss53开发到中途的时候，线上版本出现了一个bug，现在需要切回到主分支master修复，为了不影响master，我们在主分支上新开一个分支hotfix。并在该分支上修改。

	git checkout master 	// 切回主分支
	git checkout -b hotfix	// 在主分支上新开启一个分支hotfix
	
进过一段时间的修改

![](/Users/pingjunlin/Desktop/git_merge_rebase03.png)

