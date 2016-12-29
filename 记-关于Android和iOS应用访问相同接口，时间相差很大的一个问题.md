# 记-关于Android和iOS应用访问相同接口，时间相差很大的一个问题

#### 故事背景

> 在目前的公司中，同一款应用，iOS平台和Android平台，在访问相同的接口的时候，表现出很大的时间差异性。其中主要表现为在iOS平台上应用获取到数据紧紧只需要300ms左右。但是使用Android获取数据在30s-70s左右，但是奇怪的是，可能某一个时刻，Android平台的应用获取数据也能在300ms获取。如此不稳定，非常让人头疼

下图使用postman来模拟客户端网络请求，红色表明部分，使用时间为75s左右，对于如此长的时间，一般都已经超过了设置的超时时间了。

数据请求很慢的情况

![模拟客户端发起网络请求-75s.png](http://upload-images.jianshu.io/upload_images/1626952-fba814a2cfc77223.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

数据请求正常的情况

![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1626952-772acc6e6d94f60a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

以上请求的是相同的接口，时间会相差很大。


## 发现问题端倪

> 这个问题困扰了我们Android工程师很久，经过多方面的努力。最后再一次数据处理抓包过程中，发现访问时间长和访问时间短的两次ip地址不一样。由此打开了一扇窗户

## 问题分析

1. 使用`nslookup`分析DNS域名解析，如下图

	![nslookup解析DNS.png](http://upload-images.jianshu.io/upload_images/1626952-58e15c6de5089b2e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
	
	不论是Windows下的Dos还是mac下bash，键入`nslookup`后输入你的域名，就可以看到域名解析出来的ip地址，一般而言，我们可以在地址栏中，使用ip替换域名直接访问对应的网址。有兴趣者可以解析百度的域名。
	* **重点是从图片可以看出，改域名解析出两个ip地址，然后如何能在终端中知道哪个ip地址可以快速访问，哪个不能呢？或者两个都可以快速的访问**

2. 使用`telnet`测试ip是否可以访问到接口服务端

	![使用telnet测试是否访问到接口服务器.png](http://upload-images.jianshu.io/upload_images/1626952-36168fb25938af20.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
	
3. 使用postman，通过使用ip替换域名验证访问效率

	使用终端中一致trying的ip替换域名，结果

	![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1626952-3c23ee0c307e827b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
	
	使用终端中可以访问通的ip替换域名，如下
	
	![Paste_Image.png](http://upload-images.jianshu.io/upload_images/1626952-2ad911030060160a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
	
**综上多个测试，可以发现，导致Android上的应用访问慢是由于DNS域名解析，返回一个无效的ip地址导致的。经过多次测试，发现DNS解析出两个ip的顺序不是确定的，所以在Android应用中有时候快是因为android应用获取ip是至上而下的，所以当有效的ip是第一个获取的ip时候，android应用表现的则很快的得到了数据。反正，则不能**

## 疑问

虽然是相同的接口，但是在iOS平台表现则良好。这无疑让人产生很大的疑问，为什么。

猜想

1. 在iOS中，对DNS解析出来的两个ip地址同时发起请求，response优先选择可以访问通的。
2. 通过查找资料，在iOS平台，对DNS解析做了缓存，而且清理缓存的时间周期为24小时，所以，可能只是某一次数据请求成功后，缓存了成功的ip地址到本地，然后每次请求都使用这个ip地址。

## 希望但是没有做到的

本希望搞清楚iOS平台是对DNS解析出多ip的情况是如何选择ip进行请求的。

希望可以打印出DNS解析的日志，以及接口请求选择ip的日志。这样就可以知道iOS选择的ip的工作原理了。

> **有知道希望告知方法，方案等，Th**



