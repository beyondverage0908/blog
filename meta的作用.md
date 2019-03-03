meta有什么作用

在html的head标签中，会使用很多的meta标签，例下：
    
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <meta http-equiv="X-UA-Compatible" content="ie=edge">
      <meta name="keywords" content="编程, 前端, 极客, Call, Apply, Bind">
      <meta name="theme" content="xh-2">
      <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
      <meta http-equiv="Pragma" content="no-cache" />
      <meta http-equiv="Expires" content="0" />
      <title>Document</title>
    </head>
  
那么这些标签有什么作用呢？

## 解释

meta，称为元数据。元数据是对数据的描述。可能你会有些疑惑，什么叫做元数据。举个例子，以前在背单词的时候，在单词表上只会有"hello: 你好"，以及音标信息，还会有一段对hello的解释，而这段解释可以理解为元数据，即描述数据的数据。

html，本身是描述信息的数据，而`mata`就是对整个html文件信息的描述。

在`mata`中，常见的有两种格式

    <meta name="keywords" content="编程, 前端, 极客, Call, Apply, Bind">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />

`meta`使用k,v的结构，在content中是对name的一个详细描述，比如name="keywords"，content是说明当前的html中是`编程, 前端, 极客, Call, Apply, Bind`关键字的描述。比如name="viewport"，主要是应用于移动设备，决定当前页面的一个锚，所有的element的像素布局相当于这个`viewport`定义的大小。

而`http-equiv`是则是http的传输相关，如上的`Cache-Control`，当前页面使用content中对应策略，`no-cache`不使用客户端的缓存。

## meta和SEO

因为`meta`是对当前页面的内容的精简描述，所有有利于SEO，比如在`meta`中设置了`keywords`，`description`等，搜索引擎会放出"蜘蛛"，去抓取页面中的"关键信息"，然后放到搜索引擎的服务中，所有设置合适的`meta`有利于搜索引擎优化

## 使用第三方的服务，生成meta组

如果你不知道应该有一个什么样的`meta`标签组，可以使用该网站[HEY META](http://www.heymeta.com)，你只需要输入如`description`，`keywords`等信息，它会生成专门针对Google，Facebook，Twitter的`meta`组，喜欢的可以访问尝试下。如使用一个之前博客的，生成的`meta`组如下

	<!-- HTML Meta Tags -->
	<title>Vue组件三-Slot分发内容</title>
	<meta name="description" content="Vue组件三-Slot分发内容开始Vue组件是学习Vue框架最比较难的部分，而这部分难点我认为可以分为三个部分学习，即  组件的传值 - 父组件向子组件中传值 事件回馈 - 子组件向父组件发送消息，父组件监听消息 分发内容  整片博客使用的源代码-请点击 所以将用三篇博客分别进行介绍以上三种情况和使用 木头楔子/插槽在学习内容分发之前，我们先了解一个木工会经常使用的一种拼接两个家具的接口——木头楔">
	
	<!-- Google / Search Engine Tags -->
	<meta itemprop="name" content="Vue组件三-Slot分发内容">
	<meta itemprop="description" content="Vue组件三-Slot分发内容开始Vue组件是学习Vue框架最比较难的部分，而这部分难点我认为可以分为三个部分学习，即  组件的传值 - 父组件向子组件中传值 事件回馈 - 子组件向父组件发送消息，父组件监听消息 分发内容  整片博客使用的源代码-请点击 所以将用三篇博客分别进行介绍以上三种情况和使用 木头楔子/插槽在学习内容分发之前，我们先了解一个木工会经常使用的一种拼接两个家具的接口——木头楔">
	<meta itemprop="image" content="http://raw.githubusercontent.com/beyondverage0908/Blog/master/resoure/componet_slot_qizi.jpeg">
	
	<!-- Facebook Meta Tags -->
	<meta property="og:url" content="https://beyondverage0908.github.io/2018/05/13/blog-2018-05-13">
	<meta property="og:type" content="website">
	<meta property="og:title" content="Vue组件三-Slot分发内容">
	<meta property="og:description" content="Vue组件三-Slot分发内容开始Vue组件是学习Vue框架最比较难的部分，而这部分难点我认为可以分为三个部分学习，即  组件的传值 - 父组件向子组件中传值 事件回馈 - 子组件向父组件发送消息，父组件监听消息 分发内容  整片博客使用的源代码-请点击 所以将用三篇博客分别进行介绍以上三种情况和使用 木头楔子/插槽在学习内容分发之前，我们先了解一个木工会经常使用的一种拼接两个家具的接口——木头楔">
	<meta property="og:image" content="http://raw.githubusercontent.com/beyondverage0908/Blog/master/resoure/componet_slot_qizi.jpeg">
	
	<!-- Twitter Meta Tags -->
	<meta name="twitter:card" content="summary_large_image">
	<meta name="twitter:title" content="Vue组件三-Slot分发内容">
	<meta name="twitter:description" content="Vue组件三-Slot分发内容开始Vue组件是学习Vue框架最比较难的部分，而这部分难点我认为可以分为三个部分学习，即  组件的传值 - 父组件向子组件中传值 事件回馈 - 子组件向父组件发送消息，父组件监听消息 分发内容  整片博客使用的源代码-请点击 所以将用三篇博客分别进行介绍以上三种情况和使用 木头楔子/插槽在学习内容分发之前，我们先了解一个木工会经常使用的一种拼接两个家具的接口——木头楔">
	<meta name="twitter:image" content="http://raw.githubusercontent.com/beyondverage0908/Blog/master/resoure/componet_slot_qizi.jpeg">
	
	<!-- Meta Tags Generated via http://heymeta.com -->