## Swift -- Struct 和 Class的区别是什么

* Struct 是指类型，Class 是引用类型，所以Struct的对象赋值后修改属性不会影响到原来对象属性的值，Class对象赋值后修改属性的值会影响原来对象的属性值。
* Struct会默认生成一个对所有属性赋值的构造函数(也可以手动)，Class必须手动创建构造函数。
* 如果用let修饰Struct对象，则不能修改对象中的属性。Class对象则可以
* 使用方法给属性赋值，Struct需要用mutating修饰，但是Class用方法给属性赋值则不需要。
* Struct不支持继承关系，但是Class支持继承关系