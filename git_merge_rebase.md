#聊一聊git中merge和rebase

昨日，看到以前的老大在朋友圈中发了一条moment

> "作为一个刚入职三天的新职员，如何劝说上级使用rebase，rebase，rebase，不要使用merge，merge，merge"

以前跟着这位老大，每次都是看他使用rebase，现在自己进行项目管理了，平时基本使用的都是merge，刚好今天回忆起来，就来看看什么是rebase，和merge。

* merge

merge很容易理解，就是合并。在项目管理中，假设开始都在一条分支master上开发，到某一个时间点，项目发布出去了。然后新的需求issue来了，我们在当前master新开启一个分支iss53进行开发。

	git branch iss53	 // 新建分支iss53
	git checkout iss53 // 切换分支到iss53
	
	git checkout -b iss53 // 上两个语句的简写
	


	
	