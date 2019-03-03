# Vue和React组件通信的总结

在现代的三大框架中，其中两个Vue和React框架，组件间传值方式有哪些？    

## 组件间的传值方式

组件的传值场景无外乎以下几种：

1. 父子之间
2. 兄弟之间
3. 多层级之间（孙子祖父或者更多）
4. 任意组件之间

## 父子之间

**Vue**

Vue是基于单项数据流设计的框架，但是提供了一些的语法，指令去实现一些操作

**父->子**：通过props进行传递数据给子组件
**子->父**：通过emit向父组件传值

同时，还有一些其他进行父子组件通信的方式，通过$parent和$children获取组件的父或者子组件的实例，之后通过实例对象去修改组件的属性。在表单控件中，使用v-model实现了双向数据绑定，其实这里v-model是一个语法糖，内部实现还是监听了表单控件的change事件，然后将数据传递给组件修改数据，从而实现了双向数据绑定。

**React**

**父->子**：通过props将数据传递给子组件
**子->父**：通过父组件向子组件传递函数，然后子组件中调用这些函数，利用回调函数实现数据传递

## 兄弟之间

**Vue**

在Vue中，可以通过查找父组件下的子组件实例，然后进行组件进行通信。如`this.$parent.$children`，在`$children`中，可以通过组件的name找到要通信的组件，进而进行通信。

**React**

在React中，需要现将数据传递给父组件，然后父组件再传递给兄弟组件。

## 多层级组件

**Vue**

在多层级的组件中，当然可以通过不断的获取`$parent`找到需要传递的祖先级组件，然后进行通信，但是这样繁琐易错，并不推荐。Vue在2.2.0 新增提供了provide/inject的方式进行传递数据。即在祖先组件提供数据，在需要使用的组件中，注入数据，这样就可以在子组件中使用数据了。[provide/inject文档](https://cn.vuejs.org/v2/api/index.html#provide-inject)

    // 父级组件提供 'foo'
    var Provider = {
      provide: {
        foo: 'bar'
      },
      // ...
    }
    
    // 子组件注入 'foo'
    var Child = {
      inject: ['foo'],
      created () {
        console.log(this.foo) // => "bar"
      }
      // ...
    }


**React**

在React中，提供了一个和Vue类似的处理多层级组件通信的方式——`context`，这里会提供一个生产者和一个消费者，会在父组件中生产数据，在子组件中消费数据。从使用上来说，只需要将子组件包裹在生产者的`Provider`中，在需要用到数据的子组件中，通过`Consumer`包裹，就可以拿到生产者的数据。[context文档](https://reactjs.org/docs/context.html#dynamic-context)

    // Theme context, default to light theme
    const ThemeContext = React.createContext('light');

    class App extends React.Component {
      render() {
        const {signedInUser, theme} = this.props;
    
        // App component that provides initial context values
        return (
          <ThemeContext.Provider value={theme}>
            <Layout />
          </ThemeContext.Provider>
        );
      }
    }
    
    function Layout() {
      return (
        <div>
          <Sidebar />
          <Content />
        </div>
      );
    }
    
    // A component may consume multiple contexts
    function Content() {
      return (
        <ThemeContext.Consumer>
          {theme => (
             <ProfilePage  theme={theme} />
          )}
        </ThemeContext.Consumer>
      );
    }
    
## 任意组件之间

**Vue**

对于任意组件，简单的可以使用EventBus，对于更为复杂的建议使用Vuex。


**React**

简单的使用EventBus，复杂的使用Redux

## 总结

当然，组件间的传值是灵活的，可以有多种途径，父子组件同样可以使用EventBus，Vuex或者Redux，只是遵循框架开发者的建议，以及适应开发的比较好的实践而已。