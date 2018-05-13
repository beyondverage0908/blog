# Vue组件-事件反馈 - 子组件向父组件发送消息，父组件监听消息

## 开始

Vue组件是学习Vue框架最比较难的部分，而这部分难点我认为可以分为三个部分学习，即

1. [组件的传值 - 父组件向子组件中传值](https://beyondverage0908.github.io/2018/05/08/blog-2018-05-08/)
2. [事件回馈 - 子组件向父组件发送消息，父组件监听消息](https://beyondverage0908.github.io/2018/05/11/blog-2018-05-11/)
3. 分发内容 

[整个博客使用的源代码-请点击](https://gitee.com/mdiep/LearnVue/blob/master/Html/component.html)

所以将用三篇博客分别进行介绍以上三种情况和使用

## 消息监听，消息发送

在理解Vue事件之前，可以简单理解一下消息中心的设计模式，如下图，即每一个订阅者，都可以去订阅消息。而消息会提供一个"消息名称"，订阅者可以通过"消息名称"，订阅特定的消息。一定订阅者订阅了消息，则只要发出消息，订阅者就会被触发。

![消息中心模型](https://raw.githubusercontent.com/beyondverage0908/Blog/master/resoure/message_center_pattern.jpg)

而在Vue中，通过`v-on`去订阅一个消息，通过`emit`发出一个消息。

这两个特有的模式是`v-on:message-name="someMethod"`订阅，`this.$emit("message-name")`发送一个消息。此时`someMethod`会被触发调用。

## 具体的实例

父组件和子组件的事件响应中，主要分为四种情况

1. "v-on"/"@"绑定事件(@是对v-on的缩写)
2. 绑定原生事件
3. .sync同步父组件和子组件之间的props
4. 兄弟组件进行通信

### "v-on"或"@"绑定事件

父组件中模版的定义

	<div>
		<h4>组件四-"v-on"绑定事件</h4>
		<span>{{sumOfTotal}}</span>
		<br />
		<!--'@'是'v-on:'监听器的简写-->
		<component-span-child-4 v-on:increment-total="incrementWithTotal"></component-span-child-4>
		<component-span-child-4 @increment-total="incrementWithTotal"></component-span-child-4>
		<component-span-child-4 @increment-total="incrementWithTotal"></component-span-child-4>
	</div>
	
子组件的定义

	Vue.component("component-span-child-4", {
		template: "<button v-on:click='incrementOfButtonCounter'>{{counter}}</button>",
		data: function() {
			return {
				counter: 0
			}
		},
		methods: {
			incrementOfButtonCounter: function() {
				this.counter = this.counter + 1;
				// post a notification of increment counter
				// 'increment-total' 相当于一个通知名称，在父组件中，会检测一个同名的通知名称
				this.$emit("increment-total");
			}
		}
	})
	
> 子组件在点击事件触发的时候，会发送一个消息名称为`"increment-total"`的消息，而在父组件中，订阅了这个名称的消息。所以父组件可以响应子组件的通知

### 绑定原生事件

父组件中模版的定义

	<div>
		<h4>组件五-绑定原生事件</h4>
		<span>{{nativeSumOfTotal}}</span>
		<br />
		<component-span-child-5 v-on:click.native="nativeDoThing"></component-span-child-5>
	</div>
	
子组件的定义

	Vue.component("component-span-child-5", {
		template: "<button>检测原生事件-点击</button>"
	})
	
> 通过`v-on:click.native="nativeDoThing"`订阅原生的事件。这里没有`emit`关键字，可以理解为这个消息是原生组件发送出的，但是订阅还是通过`v-on`

### .sync同步父组件和子组件之间的props

>**在一些情况下，我们可能会需要对一个 prop 进行『双向绑定』。当一个子组件改变了一个 prop 的值时，这个变化也会同步到父组件中所绑定的值。这很方便，但也会导致问题，因为它破坏了『单向数据流』的假设。**

父组件中模版的定义

	<div>
		<h4>组件六-.sync同步父组件和子组件之间的props</h4>
		父组件中的值: {{food}}
		<component-span-child-6 :food.sync=food></component-span-child-6>
		<component-span-child-6 v-bind:food.sync=food></component-span-child-6>
		<!--扩展之后的模版-->
		<component-span-child-6 v-bind:food=food v-on:update:food="val => food = val"></component-span-child-6>
	</div>
	
子组件中的定义

	Vue.component("component-span-child-6", {
		props: ["food"],
		template: "<div>{{selectedFood}}<button v-on:click='changeSelectedFood'>点击选择其他食物</button></div>",
		data: function() {
			return {
				selectedFood: this.food,
				foods: ["米饭", "水果", "青菜", "沙拉"]			
			}
		},
		methods: {
			changeSelectedFood: function() {
				var idx = this.foods.indexOf(this.selectedFood);
				if (idx == -1 || idx == this.foods.length - 1) {
					idx = 0;
				} else {
					idx += 1;
				}
				this.selectedFood = this.foods[idx];
				this.$emit('update:food', this.selectedFood);
			}
		}
	})
	
> 通过父组件中国呢三种写法(功能都是一样的，只是由上而下，将模版扩展开写，以窥探`.sync`的作用)，其实`.sync`其实会扩展出一个`v-on:update:food`订阅消息，并且在收到消息，进行了对原值的修改。
> 而在子组件中，依旧通过`this.$emit('update:food')`发送一个消息出来

这个就是`.sync`真正做了什么。

### 兄弟组件进行通信

两个不是父子组件的组件如何通信，可以定一个中间总线(中介的意思)，通过中间中间总线订阅消息，中间总线发送消息，完成两个组件之间的通信。如下

父组件模版的定义

	<div>
		<h4>组件七-兄弟组件进行通信</h4>
		<component-span-child-7 component-name="组件7"></component-span-child-7>
		<component-span-child-8 component-name="组件8"></component-span-child-8>
	</div>
	
子组件的定义

	var bus = new Vue();
	Vue.component("component-span-child-7", {
		props: ["componentName"],
		template: "<div><span>{{componentName}}</span>:<span>{{counter}}</span></div>",
		data: function() {
			return {
				counter: 0
			}
		},
		mounted: function() {
			// 此处在monuted阶段监听'notificationFromPartner',需要用bind方法绑定当前的this，否则回调function中的this则是bus实例，而不是当前Vue的实例
			bus.$on("notificationFromPartner", function() {
				this.counter += 1;
			}.bind(this));
		}
	})
	Vue.component("component-span-child-8", {
		props: ["componentName"],
		template: "<button v-on:click='componentClickPushMessage'>{{componentName}}</button>",
		methods: {
			componentClickPushMessage: function() {
				bus.$emit("notificationFromPartner");
			}
		}
	})

组件7在装载`mounted`后，通过`bus.$on("notificationFromPartner", callbackFunction)`订阅了`notificationFromPartner`消息，而在组件8中，通过`bus.$emit("notificationFromPartner");`发送出这个消息。则订阅者就可以响应消息。

## 总结

在学习Vue中，组件作为十分重要的一个组成部分，对组件的通信的理解也十分重要。对于组件间的事件反馈，应该先理解消息中心的设计模式，则能更快的理解其中的原理。则不用纠结一些语法特性比较奇怪。不用纠结为什么v-on要和emit匹配、为什么只需要v-on就可以监听原生native事件、为什么`.sync`可以实现props的同步等一系列问题。

[整个博客使用的源代码-请点击](https://gitee.com/mdiep/LearnVue/blob/master/Html/component.html)
