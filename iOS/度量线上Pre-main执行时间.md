# 度量线上Pre-main执行时间

在应用已经上到生产环境后，这个时候需要统计App在Pre-main使用的时间。更应该关注开发者能够操控的部分，对于系统的主导的部分，则心有余而力不足。下图为App启动过程，其中黄色部分`class load`和`category load`和`initializer`是开发者可以想办法获取时间的。

![在Pre-main可以操作的部分.png](https://upload-images.jianshu.io/upload_images/1626952-648d4117bd136f48.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/700)

