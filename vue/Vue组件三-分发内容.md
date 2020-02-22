# Vue组件三-Slot分发内容

## 开始

Vue组件是学习Vue框架最比较难的部分，而这部分难点我认为可以分为三个部分学习，即

1. [组件的传值 - 父组件向子组件中传值](https://beyondverage0908.github.io/2018/05/08/blog-2018-05-08/)
2. [事件回馈 - 子组件向父组件发送消息，父组件监听消息](https://beyondverage0908.github.io/2018/05/11/blog-2018-05-11/)
3. [分发内容](https://beyondverage0908.github.io/2018/05/13/blog-2018-05-13/)

[整片博客使用的源代码-请点击](https://gitee.com/mdiep/LearnVue/blob/master/Html/component.html)

所以将用三篇博客分别进行介绍以上三种情况和使用


## 木头楔子/插槽

在学习内容分发之前，我们先了解一个木工会经常使用的一种拼接两个家具的接口——木头楔子。它的作用就是将两个家具组件，通过这个木头楔子连接拼合到一起。

而Vue中的内容分发，其实就是子组件提供了一个"木头楔子"，让父组件可以将一些内容嵌入到子组件中。这个就是内容分发的思想。接下来，学习下内容分发的几种常见的格式。

![木头楔子](https://raw.githubusercontent.com/beyondverage0908/Blog/master/resoure/componet_slot_qizi.jpeg)

## 具体的实例

内容分发主要分为两种语法模式，不具名的slot和具名的slot，对于具名的slot，在使用的时候需要指定父组件的标签的slot名称。这部分标签将嵌入到具名的slot部分。

### 内容分发-单个slot

父组件中模版的定义

	<div>
		<h4>组件八-内容分发1-单个slot</h4>
		<component-slot-child-9 component-name="单个slot例子">
			<p>这是来自父组件的p标签内容</p>
		</component-slot-child-9>
	</div>
	
子组件的定义

	Vue.component("component-slot-child-9", {
		props: ["componentName"],
		template: "<div><h5>{{componentName}}</h5><slot>只有父组件有需要slot(插槽)才能生效</slot></div>"
	})

### 内容分发-具名的slot

父组件中模版的定义

	<div>
		<h4>组件九-内容分发-具名的slot</h4>
		<component-slot-child-10 component-name="具名的slot">
			<strong slot="companyName">好人生集团</strong>
			<p slot="scope">好人生旗下员工人数1000人</p>
			<sub>好人生成立于2008年，十年历史，专注于健康。全民的健康才是我们的最求</sub>
			<br />
			<sub>积极 * 正直 * 责任 * 卓越 * 团队合作 * 客户第一</sub>
		</component-slot-child-10>
	</div>
	
子组件的定义

	Vue.component("component-slot-child-10", {
		props: ["componentName"],
		template: "<div><h5>{{componentName}}</h5><slot name='companyName'></slot><slot name='scope'></slot><slot></slot></div>"
	})
	
## 作用域插槽slot

在一些情况下，父组件即将嵌入到子组件插槽中的标签需要动态获取子组件内部的数据，这个时候则需要规范出一种方式，使子组件的数据可以在即将插入插槽的时候则可以使用。这个便是作用域插槽的作用。

需要注意的作用域插槽，需要使用`<template></template>`标签包裹插槽。

### 作用域插槽-简单使用

父组件定义

	<div>
		<h4>组件十-作用域插槽-简单使用</h4>
		<component-slot-child-11>
			<template slot-scope="ps">
				<small>组件内部给组件的插槽进行传值</small>
				<br />
				<span>{{ps.city.name}}</span>
				<span>{{ps.city.area}}</span>
				<span>{{ps.city.numbers}}</span>
			</template>
		</component-slot-child-11>
	</div>

子组件的定义

	Vue.component("component-slot-child-11", {
		template: "<div><slot v-bind:city='city'></slot></div>",
		data: function() {
			return {
				city: {
					name: "上海",
					area: "100平方公里",
					numbers: "2000万人"
				}
			}
		}
	})

这里通过对`<slot></slot>`绑定一个名字为city的对象，将子组件的数据可以在父组件定义的时候使用。

### 作用域插槽-复杂使用-列表自定义使用

父组件模版定义

	<div>
		<h4>组件十一-作用域插槽-复杂使用-列表自定义使用</h4>
		<component-slot-child-12 v-bind:items="languages">
			<template slot="ul-list-child-12" slot-scope="props">
				<li style="color: red;">{{props.text}}</li>
			</template>
		</component-slot-child-12>
	</div>
	
子组件定义

	Vue.component("component-slot-child-12", {
		props: ["items"],
		template: "<ul><slot name='ul-list-child-12' v-for='item in items' v-bind:text='item'>默认</slot></ul>",
		data: function() {
			return {
				messageDefault: "this is li default message"	
			}
		}
	})

如上，将列表的li标签作为外部传入的，当需要修改列表样式时，只需更换父组件的插槽部分即可，不需要更改组件部分。

## 动态切换组件

在一些情况下，定义了多个组件，需要只显示其中一个或者一部分，这个时候则需要动态的切换组件

> 通过使用保留的`<component>`元素，动态地绑定到它的`is`特性，我们让多个组件可以使用同一个挂载点，并动态切换：dynamicComponent
	
	var vm = new Vue({
	  el: '#example',
	  data: {
		dynamicComponent: "AppHeader"
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
	})

父组件模版

	<div>
		<h4>组件十二-动态组件</h4>
		<button v-on:click="changeCurrentComponent">点击切换不同的组件-{{dynamicComponent}}</button>
		<keep-alive>
			<component :initial-text="dynamicComponent" v-bind:is="dynamicComponent"></component>
		</keep-alive>
	</div>
	
**如果把切换出去的组件保留在内存中，可以保留它的状态或避免重新渲染。则可以添加一个 keep-alive**

## 总结

至此，关于组件学习的大部分内容基本学习完毕。


参考：

[1. Vue-组件](https://cn.vuejs.org/v2/guide/components.html)

[2. Vue-插槽](https://cn.vuejs.org/v2/guide/components-slots.html)