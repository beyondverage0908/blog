# 结合RSA，AES128，MD5---移动端与服务端在通信层的加密处理

> 很高兴能在项目中使用到RSA，AES128，以及MD5，用以保证客户端(Client)和服务端(Server)之间的通信安全。接下来会尽力的描述清楚关于本次使用的流程。具体关于算法的细节，自行Wiki。

> 原来只是对加密这一块很简单的了解，比如只知道一些对称加密，非对称加密，md5单向加密等。通过本次的学习，很惊艳于可以将多种加密方式那么完美的结合到一起。让整个通信过程变得如此美妙。虽然增加了服务端和客户端的工作量，但是保证数据的一致出口，一致入口，只需要在出口和入口处加上逻辑，就可以很好的避免扰乱原有逻辑的烦恼。

## 简单的概念，文章可能会涉及到

1. RSA——非对称加密，会产生公钥和私钥，公钥在客户端，私钥在服务端。公钥用于加密，私钥用于解密。
2. AES——对称加密，直接使用给定的秘钥加密，使用给定的秘钥解密。(加密解密使用相同的秘钥)
3. MD5——一种单向的加密方式，只能加密，不能解密
4. Base64编码——对字节数组转换成字符串的一种编码方式

## 客户端，服务端的通信逻辑

**之前：明文传输通信**

1. 客户端将要上传的数据以字典(Map)的方式打包，Post提交给服务器。
2. 服务器接收提交的数据包，通过Key-Value的形式获取客户端提交的值，进行处理。
3. 处理结束，将数据以字典(Map)的形式打包，返回给客户端处理。

**加密传输通信**

整个流程是：

**客户端上传数据加密** ==> **服务器获取数据解密** ==> **服务器返回数据加密** ==> **客户端获取数据解密**

* 客户端上传数据加密 A

	1. 客户端随机产生一个16位的字符串，用以之后AES加密的秘钥，AESKey。
	2. 使用RSA对AESKey进行公钥加密，RSAKey
	3. (此处某些重要的接口需要加签处理，后续讲解，不要加签处理的省略该步骤)
	4. 将明文的要上传的数据包(字典/Map)转为Json字符串，使用AESKey加密，得到JsonAESEncryptedData。
	5. 封装为{key : RSAKey, value : JsonAESEncryptedData}的字典上传服务器，服务器只需要通过key和value，然后解析，获取数据即可。
	
* 服务器获取数据解密 B
	
	1. 获取到RSAKey后用服务器私钥解密，获取到AESKey
	2. 获取到JsonAESEncriptedData，使用AESKey解密，得到明文的客户端上传上来的数据。
	3. (如果客户端进行了加签处理，此处需要验签，以保证数据在网络传输过程中是否被篡改)

* 服务器返回数据加密 C
	
	1. 将要返回给客户端的数据(字典/Map)转成Json字符串，用AESKey加密处理
	2. (此处也可以加签处理)
	3. 封装数据{data : value}的形式返回给客户端

* 客户端获取数据解密 D

	1. 客户端获取到数据后通过key为data得到服务器返回的已经加密的数据AESEncryptedResponseData
	2. 对AESEncryptedResponseData使用AESKey进行解密，得到明文服务器返回的数据。

## 加签和验签

> 第二节——**"客户端，服务端的通信逻辑"**已经基本上把客户端和服务端的通信加密逻辑讲完了。至于**"加签和验签"**主要是针对数据传输过程中，防止数据被篡改的一种做法。

数据被篡改，栗子：

对于一个运动类型的APP，上传运动的步数，是一个常见的接口操作。比如该接口会有几个字段，step(步数)，time(步数产生的时间)，memberId(用户id)。

假设某用户抓取了你上传的数据包，然后成功的破解了你之前的加密方式。得到对应的明文，此时该用户就可以随意修改你的数据，比如step，然后以相同的方式加密，post到你的服务器，此时服务器会认为这是一次正常的请求，便接受了这个修改后的步数。其实此时的数据是错误的。如此神不知鬼不觉。。。

为了防止这种做法，我们可以是加签的处理方式

* 加签处理(数据发起方都可以加签，此处是客户端)

	1. 我们一般取其中的关键字段(别人可能修改的字段)，比如此时step，和time及memberId，都比较敏感。
	2. 在上文的A中的第二步之后，获取step，time，memberId，拼接成一个字符串(顺序和服务器约定好)，然后使用md5加密，采用base64编码(编码格式和服务约定)。得到signData
	3. 然后将获取到的signData以key-value的形式保存到原来明文的数据包中，然后进行A的第三步

* 验签处理(数据接受方都可以验签，此处服务端)
	
	1. 如上，到B的第三步，此时已经得到了客户端上传的明文数据
	2. 按照喝客户端约定的字段拼接，将得到的step，time，memberId拼接后，使用同样的md5_base64处理，然后比较数据包中的签名sign是否和客户端当时的签名一致。
	3. 如果一致，接受数据。不一致，抛弃数据，终止本次操作

> 假设加签之后的数据包被截获，然后解密成功，得到明文的数据包。但是签名md5加密是无法解密的(单向加密)。此时即时修改了step，然后post到服务器，服务器通过修改后的step，time，memberId得到的字符串经过md5加密后，一定会与客户端的签名不一致。从而数据被抛弃。

## 流程图描述上文

![客户端服务端通信加密逻辑.png](http://upload-images.jianshu.io/upload_images/1626952-b9991bb49d2f4f42.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 示例代码

关于AES，和RSA加密解密，只能出iOS端的代码。关于如何在Linux下生成RSA公钥和私钥证书，参照[RSA公钥、私钥生成，详细讲解](http://www.jianshu.com/p/bfa57e049a7e)，网上很多

[github的demo地址--CAAdvancedTech](https://github.com/beyondverage0908/CAAdvancedTech)

运行，如下入显示

![首页选择加密模块](http://upload-images.jianshu.io/upload_images/1626952-d672dbe8b91fa7ed.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![AES，RSA加密解密页面](http://upload-images.jianshu.io/upload_images/1626952-103e1ca8ed1d8540.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## RSA公钥-生成自签名证书

	// 生成1024位私钥
	openssl genrsa -out private_key.pem 1024

	// 根据私钥生成CSR文件
	openssl req -new -key private_key.pem -out rsaCertReq.csr
	
	// 根据私钥和CSR文件生成crt文件
	openssl x509 -req -days 3650 -in rsaCertReq.csr -signkey private_key.pem -out rsaCert.crt
	
	// 为IOS端生成公钥der文件
	openssl x509 -outform der -in rsaCert.crt -out public_key.der
	
	// 将私钥导出为这p12文件
	openssl pkcs12 -export -out private_key.p12 -inkey private_key.pem -in rsaCert.crt

参照 [漫谈RSA非对称加密解密](http://www.jianshu.com/p/51bb0ad0b113)

## 推荐工具

1. 关于画流程图

	之前一致比较苦扰在Mac上有哪一款好用的可以画流程图，UML的工具，甚至都考虑过Keynote。最后发现这款在线的工具很不错，上图就是使用这款工具，第一次画的。效果不错。就是导出png图片分辨率不是很好
	
	[工具processOn](http://www.processon.com/)
	
	[Mac 上最好用的流程图软件是什么？](https://www.zhihu.com/question/19588698)
	
2. 关于AES加密解密在线工具
	
	[在线AES加解密](http://www.seacha.com/tools/aes.html?src=kjwfNbM%2B%2BAKaIF8%2BbMMKdQ%3D%3D&mode=CBC&keylen=128&key=1111&iv=&bpkcs=&session=MCRm2Ac3VV2CGGBaWu00&aes=e006c1c0738be822b222bc4d2603a82a&encoding=base64&type=1)



