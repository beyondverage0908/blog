# 旧项目添加CoCoaPods

关于在iOS的项目中使用CocoaPods，需要搭建ruby环境，更换依赖包的源头。不用多说，网上资源很多，基本都已经很清楚了。在这里仅仅是想对已经安装好了CocoaPods，要如何使用到未曾使用过CocoaPods的项目中。

	
	cd you project folder #你的工程第一级目录下
	vim Podfile #创建podfile
		
podfile中的格式如下
	
	target 'You Project Name' do
	#   Uncomment this line if you're using Swift or would like to use dynamic frameworks
	#   use_frameworks!

	#   Pods for KTVBariOS

	pod 'AFNetworking'

	end 
	
编辑podfile完成后，在终端terminal中按Esc退出编辑模式，然后使用`:wq`保存刚才的文件信息（一定在英文的输入法中操作），之后在终端terminal中执行

	pod install
	
pod会自动去下载依赖的包，之后就会发现项目使用workspace进行管理了。这用就已经OK了。