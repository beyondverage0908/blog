# 关于iOS编程中的－我的几个问题

* 使用nib，对于外部传入到view中的参数，是先调用传入参数的`setter`方法，还是先调用view的`awakeFromNib`方法?

	答：通过代码测试，对于view而已，先调用`awakeFromNib`，之后调用`setter`方法


* 使用push的方式到下一个viewController，并传入参数。是先调用参数的`setter`方法，还是调用viewController的`viewDidLoad`方法?

	答：通过代码测试，对于controller的转场，先调用`setter`方法，之后调用`viewDidLoad`