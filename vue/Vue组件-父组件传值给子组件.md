# Vue组件一-父组件传值给子组件

## 开始

Vue组件是学习Vue框架最比较难的部分，而这部分难点我认为可以分为三个部分学习，即

1. [组件的传值 - 父组件向子组件中传值](https://beyondverage0908.github.io/2018/05/08/blog-2018-05-08/)
2. [事件回馈 - 子组件向父组件发送消息，父组件监听消息](https://beyondverage0908.github.io/2018/05/11/blog-2018-05-11/)
3. [分发内容](https://beyondverage0908.github.io/2018/05/13/blog-2018-05-13/) 

[整个博客使用的源代码-请点击](https://gitee.com/mdiep/LearnVue/blob/master/Html/component.html)

所以将用三篇博客分别进行介绍以上三种情况和使用

## Vue的设计者对组件的理解

Vue的设计者，对组件和父组件之间的关系流上做了阐述，即**单向数据流图：**父组件向子组件传递数据，子组件回馈事件

> 组件意味着协同工作，通常父子组件会是这样的关系：组件 A 在它的模板中使用了组件 B。它们之间必然需要相互通信：父组件要给子组件传递数据，子组件需要将它内部发生的事情告知给父组件。然而，在一个良好定义的接口中尽可能将父子组件解耦是很重要的。这保证了每个组件可以在相对隔离的环境中书写和理解，也大幅提高了组件的可维护性和可重用性。
> 
> 在 Vue 中，父子组件的关系可以总结为 props down, events up。父组件通过 props 向下传递数据给子组件，子组件通过 events 给父组件发送消息。看看它们是怎么工作的。


![属性下传，事件上传](https://raw.githubusercontent.com/beyondverage0908/Blog/master/resoure/props-events.png)

## 父组件挂载的实例

上文提到的三篇文章，都使用一个父组件挂载对象，内容比较长(可以选择不看，直接看props的使用)，感兴趣可以到git上去看[源代码](https://gitee.com/mdiep/LearnVue/blob/master/Html/component.html)

模版：

	<body>
		<div id="el-component-id"></div>
	<body
	
Vue实例：

	var vm = new Vue({
		el: "#el-component-id",
		data: {
			welcome: "welcome to Vue",
			parentMessage: "this is parent message",
			iMessage: "",
			person: {
				name: "小明",
				from: "江苏",
				to: "江西",
				purpose: "喝一杯牛奶"
			},
			persons: 10,
			sumOfTotal: 0,
			nativeSumOfTotal: 0,
			food: "牛肉",
			languages: ["英语", "中文", "希腊语", "法语", "俄罗斯语"],
			dynamicComponent: "AppHeader"
		},
		methods: {
			incrementWithTotal: function() {
				this.sumOfTotal = this.sumOfTotal + 1;
			},
			nativeDoThing: function() {
				this.nativeSumOfTotal += 1;
			},
			changeCurrentComponent: function() {
				let components = ["AppHeader", "AppFooter", "AppMain"];
				let idx = components.indexOf(this.dynamicComponent);
				if (idx == 2 || idx == -1) {
					idx = 0;
				} else {
					++idx;
				}
				this.dynamicComponent = components[idx];
			}
		},
		components: {
			AppHeader: {
				props: ["initialText"],
				template: "<div><strong>{{title}}</strong></div>",
				data: function() {
					return {
						title: this.initialText
					}
				}
			},
			AppFooter: {
				props: ["initialText"],
				template: "<div><sub>{{footerTitle}}</sub></div>",
				data: function() {
					return {
						footerTitle: this.initialText
					}
				}
			},
			AppMain: {
				props: ["initialText"],
				template: "<div style='color:blue;'>{{mainContent}}</div>",
				data: function() {
					return {
						mainContent: this.initialText
					}
				}
			}
		}
	});
	

## 1. props传递单个参数

组件定义：
	
	// 使用props数组的形式进行传递参数
	Vue.component("component-span-child-1", {
		props: ["message"],
		template: "<span>{{message}}</span>"
	})

模版中进行传值：

	<div>
		<h4>组件一-props传递单个参数</h4>
		// 字面量传值
		<component-span-child-1 message="component-style-one"></component-span-child-1>
		<br />
		// 绑定父组件对象实例属性 v-bind:someProperty简写为:someProperty
		<component-span-child-1 :message="parentMessage"></component-span-child-1>
		<br />
		<component-span-child-1 v-bind:message="parentMessage"></component-span-child-1>
		<br />
		<input v-model="iMessage" placeholder="请输入值"/>
		<component-span-child-1 :message="iMessage"></component-span-child-1>
	</div>


## 2. props传递多个参数

组件定义：

	Vue.component("component-span-child-2", {
		props: ["name", "from", "to", "purpose"],
		template: "<div><span>{{name}}从{{from}}到{{to}}，{{purpose}}</span></div>"
	})
	
模版中传值：

	<div>
		<h4>组件二-props传递多个参数</h4>
		// 字面量传值
		<component-span-child-2 name="小李" from="南京" to="北京" purpose="去买个书包"></component-span-child-2>
		// 父组件实例对象属性传值
		<component-span-child-2 :name="person.name" :from="person.from" :to="person.to" :purpose="person.purpose"></component-span-child-2>
	</div>

## 3. 使用props对象高级传参，并对参数进行校验

组件定义：

可以校验传递进来的属性，例如：1. 校验类型 2. 是否必须传递 3. 提供默认值 4. 通过函数校验，如校验Number类型是否大于某个值

	Vue.component("component-span-child-3", {
		props: {
			name: {
				type: String,
				require: true
			},
			persons: {
				type: Number,
				default: 1,
				validator: function(value) {
					return value > 0;
				}
			},
			location: {
				type: String,
				default: "上海"
			},
			action: {
				type: String,
				default: "拉粑粑"
			}
		},
		template: "<div><span>{{name}}和{{persons}}个人，去{{location}}里面{{action}}</span></div>"
	})

模版中使用：

	<div>
		<h4>组件三-使用props对象传递参数，和校验</h4>
		<component-span-child-3 name="小狗" :persons="persons" location="讲述郾城" action="去淘金啊"></component-span-child-3>
	</div>

## 总结

父组件向子组件主要是通过props关键字，主要使用情况可以分为上面描述的三种。props的封装可以是一个数组，也可以是对象。

1. 当使用数组封装props的时候，只是简单将父组件的参数传递给子组件使用，此处的参数可以是对象，字符串，number类型的数据
2. 当使用对象封装props的时候，可以更加高级的校验参数，比如参数类型，默认值，参数大小等一系列校验。当不符合时候，可以看到Vue再控制台给出错误警告

熟练掌握父组件向子组件传递参数的方法，可以对Vue的关键部分更快的理解。

