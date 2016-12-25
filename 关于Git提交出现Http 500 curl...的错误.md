# 关于Git提交出现Http 500 curl...的错误

在常使用git的一族中，在某些时候会出现如下的错误

	Counting objects: 102, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (102/102), done.
    Writing objects: 100% (102/102), 1.38 MiB | 0 bytes/s, done.
    Total 102 (delta 48), reused 0 (delta 0)
    error: RPC failed; HTTP 500 curl 22 The requested URL returned   error: 500 Internal Server Error
    fatal: The remote end hung up unexpectedly
    fatal: The remote end hung up unexpectedly
    
之前碰到这样的问题，也上网看过，当时从某些资料上说是`push`的资源过大导致的。昨天有出现了一次这样的错误，就请公司的老大帮忙看了下，一眼就看出了问题所在，主要是因为http造成的。

疑惑：很疑惑，之前还是可以`push`的。为什么现在就会出问题，导致这个问题。

原因：在获取这个项目的时候，也就是`git clone`项目的时候后是通过http协议获取的。

如下图，不论是使用GitLab还是gitHub，在clone的时候都有两种选择，即http/https和SSH两种方式：

![git clone的两种方式.png](http://upload-images.jianshu.io/upload_images/1626952-16e294a032660fc6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

获取项目命令

	git clone http://gitlab.xxxxx.cloud/xxxx/some_project.git
	
使用http协议获取的项目，`push`多文件，大文件的时候，都容易出现这样的问题，只需要改成SHH方式即可。

************

以下，就是将项目原来使用Http/Https改成SSH方式

	cd 你项目的根目录
	
	ls -la // 查看当前目录下所有的文件，包括因此文件
	
	cd .git // 进入git项目的配置目录下
	
	// 找到config文件，并且编辑config文件
	vim config
	
可以看到如下配置内容

![打开git_config.png](http://upload-images.jianshu.io/upload_images/1626952-35ac04594f474b4b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
	
替换url为SSH方式

	url = git@github.com:beyondverage0908/MyMD.git
	
SSH的链接可以从如下获取到

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1626952-644bcd5b01a7af44.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

最好保存

	:wq		// 终端编辑后保存退出
	