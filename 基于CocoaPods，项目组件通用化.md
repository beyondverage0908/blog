# 基于CocoaPods，项目组件通用化

## 引子

在移动开发领域，已经不像前两年那么火热。以前公司可以有几个移动开发人员。现在一般公司都是只有一个或者两个开发人员，但是项目却有好几个。在公司项目之间，很多部分是通用的，在之前都是修改一处，其他地方都需要再一次修改，如此不仅麻烦，而且容易出错。

一直谋求一种更好的方式去管理多项目的通用组件，所以目前想到的是基于CocoaPods进行组件私有化，然后通过Pod进所有项目，做到一处修改，统一使用的效果。

## 目录

### 通过github | gitlab创建公用的Pod库

1. 注册CocoaPods账号信息
2. 本地创建共享的文件和文件仓库
3. 上传到公用仓库github | gitlab
4. 给上传到公用仓库打tag，并上传
5. 编辑 .podspec 文件
6. 发布自己的 .podspec 文件到CocoaPods 
7. 更新维护.podspec文件
8. pod搜索

## 开始操作了

### 1. 注册CocoaPods账号信息

iOS开发，应该对pod比较熟悉了，默认你的电脑已经安装了CocoaPods了。之后使用的命令都是在terminal中执行。

	# 邮箱地址：一般用github|gitlab地址 
	# 注册CocoaPods
	pod trunk register 邮箱地址 '用户名' --verbose 

注册之后，在邮箱中会收到一封邮件，需要在邮件点击一个链接激活一下即可。

查看自己pod的注册信息，以及查看自己发布过的开源的pod库

	# pod注册信息，开源pod库
	pod trunk me 
	
如下，我的

	- Name:     beyond-GH
  	- Email:    beyondaverage0908@gmail.com
  	- Since:    July 3rd, 19:40
  	- Pods:
    	- LPSToolUtil
  	- Sessions:
    	- July 3rd, 19:40 - November 9th, 01:17. IP: 118.242.18.199


### 2. 创建共享文件和文件仓库

这里从头创建一个共享库，以便对整个创建过程更加清楚。在terminal中创建一个全新的工程。

	pod lib create 新的库名
	
在创建库的时候，会询问你关于对新建库的一些要求，根据自己的要求配置好就OK，可以参考[Using Pod Lib Create](https://guides.cocoapods.org/making/using-pod-lib-create.html)

> 在这里简单的介绍下新建项目的目录结构

	.
	├── Example
	│   ├── LPSToolUtil
	│   ├── LPSToolUtil.xcodeproj
	│   ├── LPSToolUtil.xcworkspace
	│   ├── Podfile
	│   ├── Podfile.lock
	│   ├── Pods
	│   └── Tests
	├── LICENSE
	├── LPSToolUtil
	│   ├── Assets
	│   └── Classes
	├── LPSToolUtil.podspec
	├── README.md
	└── _Pods.xcodeproj -> Example/Pods/Pods.xcodeproj
	
**Example为Pod公用组件测试项目**

**LPSToolUtil为通用组件库，Classes里面放的就是需要被pod的文件，Assets放一些资源文件**

**LPSToolUtil.podspec文件为配置文件需要，以后通过每次更新该文件进行组件库的升级**

### 3. 上传到公用仓库github | gitlab

之后，将新建的项目push到远程服务端github | gitlab。具体的操作需要先在github上创建一个空的repo，然后使用命令行提交。[iOS开发使用Git的那些事](https://segmentfault.com/a/1190000005844362)

### 4. 给上传到公用仓库打tag，并上传

已经上传到github | gitlab上后，需要给当前上传的版本一个tag

	# '0.1.1'当前的tag号，需要和podsepc一致
	git tag -m "tag描述" '0.1.1'
	
	# push tag到github|gitlab
	git push --tag 
	
### 5. 编辑 .podspec 文件

编辑.podspec文件，一般在简单的文本编辑器中，保证不会出现编码错误等其他错误信息。我一般使用vim进行编辑。在当前的文件下

	vim LPSToolUtil.podspec
	
编辑文件

	#
	# Be sure to run `pod lib lint LPSToolUtil.podspec' to ensure this is a
	# valid spec before submitting.
	#
	# Any lines starting with a # are optional, but their use is encouraged
	# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
	#

	Pod::Spec.new do |s|
  		s.name             = 'LPSToolUtil'
  		s.version          = '0.1.2'
  		s.summary          = 'A Tool Util for MySelf.'

	# This description is used to generate tags and improve search results.
	#   * Think: What does it do? Why did you write it? What is the focus?
	#   * Try to keep it short, snappy and to the point.
	#   * Write the description between the DESC delimiters below.
	#   * Finally, don't worry about the indent, CocoaPods strips it!

  		s.description      = <<-DESC
	TODO: Add long description of the pod here.
                       DESC

  		s.homepage         = 'https://github.com/beyondverage0908/LPSToolUtil'
  		# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  		s.license          = { :type => 'MIT', :file => 'LICENSE' }
  		s.author           = { 'beyondverage0908' => 'beyondaverage0908@gmail.com' }
  		s.source           = { :git => 'https://github.com/beyondverage0908/LPSToolUtil.git', :tag => s.version.to_s }
  		# s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  		s.ios.deployment_target = '8.0'

  		s.source_files = 'LPSToolUtil/Classes/**/*'

  		# s.resource_bundles = {
  		#   'LPSToolUtil' => ['LPSToolUtil/Assets/*.png']
  		# }

  		# s.public_header_files = 'Pod/Classes/**/*.h'
  		# s.frameworks = 'UIKit', 'MapKit'
  		# s.dependency 'AFNetworking', '~> 2.3'
	end
	    
这里的注释已经很清楚了，唯一强调的几点

* s.version 这里的版本和提交到github上的tag必须一致
* s.source_files 指定的路径一定是你需要发布出去的组件库路径
* s.dependency 如果你的组件库依赖于第三方的组件库，则需要指明

### 6. 发布自己的 .podspec 文件到CocoaPods 

当你已经编辑完了自己的.podspec文件，需要去校验是否正确。

	pod lib lint LPSToolUtil.podspec	
	
出现`LPSToolUtil passed validation.`提示即可

### 7. 更新维护.podspec文件

在校验完.podspec文件后，需要将.podspec文件提交到cocoapods

	pod trunk push LPSToolUtil.podspec

在这个过程中，会再一次校验.podspec的合法性，并且执行commit，push等一些列操作。

如下，则成功：

![成功图片](http://upload-images.jianshu.io/upload_images/1626952-e482258ea49b1aa6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 8. pod搜索

完成以上所有步骤，需要看看我们到底是否已经成功了

	pod search LPSToolUtil
	
出现->成功了

	-> LPSToolUtil (0.1.2)
   	A Tool Util for MySelf.
   	pod 'LPSToolUtil', '~> 0.1.2'
   	- Homepage: https://github.com/beyondverage0908/LPSToolUtil
   	- Source:   https://github.com/beyondverage0908/LPSToolUtil.git
   	- Versions: 0.1.2, 0.1.1 [master repo]

注：

**有提到在第7步已经成功了，但是无法使用`pod search`到，解决方案**

> 成功后需要等待的时间不定, 目前一般比较快, 一般使用pod setup和pod search查看是否已经可以使用, 本人创建这个库之后一个星期内每天尝试pod setup和pod search '你的组件库' 始终无法查找到自己的库, 查找资料之后找到解决办法:

> 1.pod setup成功后生成的~/Library/Caches/CocoaPods/search_index.json文件, 是用来查找的索引文件, 终端输入:

> rm ~/Library/Caches/CocoaPods/search_index.json
删除~/Library/Caches/CocoaPods目录下的search_index.json文件, 删除成功后再执行:pod search 库名, 等待输出：Creating search index for spec repo 'master'.. Done! 稍等片刻就会出现你想要的结果~

