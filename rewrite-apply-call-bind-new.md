# 重写JS中的apply，call，bind，new方法

**在js中，经常会用到`apply`，`call`， `bind`， `new`，这几个方法在前端占据非常重要的作用，今天来看一下这些方法是如何实现，方便更加深入的理解它们的运作原理。**

## this的绑定问题

引用一点点其他知识点：一个方法的内部上下文`this`如何确定？

一个方法的调用分为一下四种：

1. **方法直接调用，称之为函数调用，当前的上下文this，绑定在全局的`window`上，在严格模式`use strict`下，`this`为`null`**
2. **方法作为一个对象的属性，这个是否通过对象调用方法，`this`绑定在当前对象上**。如下：

		let dog = {
			name: '八公',
			sayName: function() {
				console.log(this.name)
			}
		}
		dog.sayName() // 八公
	
3. **`apply`，`call`调用模式，当前的方法的上下文为方法调用的一个入参**，如下：

		function sayHello() {
			console.log(this.hello)
		}
		
		let chineseMan = {
			hello: '你好啊'
		}
		sayHello.apply(chineseMan) // 你好啊
		
		let englishMan = {
			hello: 'how are you'
		}
		sayHello.apply(englishMan) // how are you
		
4. **构造函数的调用，当前方法的上下文为新生的实例**，如下

		// 声明构造函数
		function Animal(name) {
			this.name = name
			this.sayName = function() {
				console.log(this.name)
			}
		}
		
		let dog = new Animal('dog')
		dog.sayName() // dog
		
		let cat = new Animal('cat')
		cat.sayName() // cat
	
## 正文 

### apply实现

思路：apply方法实现在Function.prototype中

1. 获取到当前调用方法体
2. 获取方法的入参
3. 绑定方法体中的上下文为传入的context--使用的方法就是对象调用属性方法的方式绑定
4. 调用方法

		Function.prototype.myApply = function() {
			let _fn = this
			if (typeof _fn !== 'function') {
				throw new TypeError('error')
			}
			let ctx = [...arguments].shift()
			// 因为apply的入参是数组，所有只需要取第一个
			let args = [...arguments].slice(1).shift()
			ctx.myApplyFn = _fn
			// 由于apply会将原方法的参数用数组包裹一下，所以需要展开参数
			let res = ctx.myApplyFn(...args)
			delete ctx.myApplyFn
			return res
		}

### call实现

思路：实现在Function.prototype中，大致和apply相似，却别在对于参数的处理上

1. 获取到当前调用方法体
2. 获取方法的入参
3. 绑定方法体中的上下文为传入的context
4. 调用方法

		Function.prototype.myCall = function() {
			let _fn = this
			if (typeof _fn !== 'function') {
				throw new TypeError('error')
			}
			let ctx = [...arguments].shift()
			// call使用的多个入参的方式，所有直接取参数第二个参数开始的所有入参，包装成一个数组
			let args = [...arguments].slice(1)
			ctx.myCallFn = _fn
			let res = ctx.myCallFn(...args)
 			delete ctx.myCallFn
 			return res
		}
		
### bind实现

思路：实现在Function.prototype中，并且返回一个已经绑定了上下文的函数。利用闭包可以捕获函数上下文的变量来实现，总体上比起之前两个方法稍微复杂一些。

1. 获取调用bind的实例方法体
2. 获取需要绑定的上下文context
3. 声明闭包函数
4. 闭包函数中绑定context到实例方法体中
5. 闭包函数中调用原来的方法体
6. 返回闭包函数

		Function.prototype.myBind = function() {
			let _fn = this
			if (typeof _fn !== 'function') {
				throw new TypeError('error')
			}
			let ctx = [...arguments].shift()
			let args = [...arguments].slice(1)
			return function() {
				// 因为bind的调用方式，会有bind({}, 'para1', 'para2')('para3', 'para4')，这个时候需要将外面参数和内部参数拼接起来，之后调用原来方法
				args = args.concat([...arguments])
				ctx.myBindFn = _fn
				let res = ctx.myBindFn(...args)
				delete ctx.myBindFn
				return res
			}
		}
	
**codepen演示** 需要翻墙
<p class="codepen" data-height="265" data-theme-id="0" data-default-tab="js,result" data-user="beyondverage0908" data-slug-hash="PXMyqB" style="height: 265px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid black; margin: 1em 0; padding: 1em;" data-pen-title="rewrite bind">
  <span>See the Pen <a href="https://codepen.io/beyondverage0908/pen/PXMyqB/">
  rewrite bind</a> by avg (<a href="https://codepen.io/beyondverage0908">@beyondverage0908</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>

### new 方法实现

思路：需要明白new到底做了什么

1. 生成一个新的实例对象
2. 实例对象`__proto__`链接到构造函数的prototype对象
3. 绑定构造函数的上下文为当前实例
4. 获取参数，传入参数，并调用构造函数

		function newObj() {
			let _o = {}
			let constructor = [...arguments].shift()
			let args = [...arguments].slice(1)
			if (typeof constructor !== 'function') {
				throw new TypeError('error')
			}
			_o.__proto__ = constructor.prototype
			
			// 第一种调用方式：借助apply，call，或者bind实现绑定_o
			// constructor.apply(_o, args)
			
			// 第二种，使用属性方法绑定的方式
			_o.myNewFn = constructor
			_o.myNewFn(...args)
			delete _o.myNewFn
			return _o
		}
		
		// how to use - 如何使用
		function Animal(name, weight) {
			this.name = name
			this.weight = weight
		}
		
		
		let dog = newObj(Animal, 'dog', '18kg')
		// the animal name: dog weight: 18kg
		console.log(`the animal name: ${dog.name} weight: ${dog.weight}`)
		
		let cat = newObj(Animal, 'cat', '11kg')
		// the animal name: cat weight: 11kg
		console.log(`the animal name: ${cat.name} weight: ${cat.weight}`)
		
**codepen需要翻墙**

<p class="codepen" data-height="265" data-theme-id="0" data-default-tab="js,result" data-user="beyondverage0908" data-slug-hash="MZNPoK" style="height: 265px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid black; margin: 1em 0; padding: 1em;" data-pen-title="MZNPoK">
  <span>See the Pen <a href="https://codepen.io/beyondverage0908/pen/MZNPoK/">
  MZNPoK</a> by avg (<a href="https://codepen.io/beyondverage0908">@beyondverage0908</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://static.codepen.io/assets/embed/ei.js"></script>


## 结语

熟悉函数内部的实现，了解内部的原理，对理解运行会有很多好处，亲自实现一遍会给你很多领悟。同时这些知识点又是非常重要的。




