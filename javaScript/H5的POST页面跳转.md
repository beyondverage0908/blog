# JSP的Post页面跳转

在H5中，一个页面的跳转，一般分为三种方式

1. window.location.href = _url;
2. a标签
3. form表单post跳转

对于方式1，方式2，如果需要传递参数，只能通过将参数添加到跳转的地址中，众所周知，对于一些要紧的参数，在地址中是非常不安全的，而且需要传递多个参数，放在链接中传递也不是很好。所以需要采用form表单提交的方式进行页面跳转。

但是在多数页面，不需要显式的添加form表单元素，此时有需要隐式的传递多个参数和要紧参数。则需要自己构建隐式的form表单，并且将需要传递的参数作为表单元素中`input`的`value`值。

### 实现方式 - 传值

具体的实现如下

	// 页面之间post跳转
	function forward(_url, _para) {
	    jQuery("#div_global_form").html("");
	    var html = "<form id='action_form' action='"+_url+"' method='post'>";
	    if(_para != null){//参数
	        for(var p in _para){
	            html += "<input type='hidden' name='"+p+"' value='"+_para[p]+"'>";
	        }
	    }
	    html += "</form>";
	    jQuery("#div_global_form").html(html);
	    jQuery("#action_form").submit();
	    jQuery("#div_global_form").html("");
	}

如上，`div_global_form`为全集的定义的一个html标签元素。我们会在`div_global_form`标签元素中生成一个form隐藏域。并且action为传递进来的`_url`。

### 取值

在跳转到指定页面后，需要获取传递过来的值。

	<script type="text/javascript">
	
		var param = "${param.alreadyImages}";
		
	</script>
	
使用如上方式，就可以获取前一个页面传递过来的参数。其中`${}`为EL表达式。为什么一定使用`param`，则是"**王八的屁股**--规定"，所以不需要纠结。

****

之上，是对最近最近HTML和JSP的学习细节总结。

	

