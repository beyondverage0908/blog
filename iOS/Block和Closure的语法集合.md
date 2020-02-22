# Block和Closure的语法集合

##Block语法集合

[How Do I Declare A Block in Objective-C?](http://fuckingblocksyntax.com/)

As a local variable:

	returnType (^blockName)(parameterTypes) = ^returnType(parameters) 	{...};
	
As a property:

	@property (nonatomic, copy, nullability) returnType (^blockName)(parameterTypes);

As a method parameter:

	- (void)someMethodThatTakesABlock:(returnType (^nullability)(parameterTypes))blockName;
	
As an argument to a method call:

	[someObject someMethodThatTakesABlock:^returnType (parameters) {...}];

As a typedef:

	typedef returnType (^TypeName)(parameterTypes);
	TypeName blockName = ^returnType(parameters) {...};
	

## Closure语法集合

[How Do I Declare Closure in Swift?](http://goshdarnclosuresyntax.com/)

As a variable:

	var closureName: (ParameterTypes) -> (ReturnType)

As an optional variable:

	var closureName: ((ParameterTypes) -> (ReturnType))?

As a type alias:

	typealias ClosureType = (ParameterTypes) -> (ReturnType)

As a constant:

	let closureName: ClosureType = { ... }

As an argument to a function call:

	funcName({ (ParameterTypes) -> (ReturnType) in statements })

As a function parameter:

	array.sort({ (item1: Int, item2: Int) -> Bool in return item1 < item2 })

As a function parameter with implied types:

	array.sort({ (item1, item2) -> Bool in return item1 < item2 })

As a function parameter with implied return type:

	array.sort({ (item1, item2) in return item1 < item2 })

As the last function parameter:

	array.sort { (item1, item2) in return item1 < item2 }

As the last parameter, using shorthand argument names:

	array.sort { return $0 < $1 }

As the last parameter, with an implied return value:

	array.sort { $0 < $1 }

As the last parameter, as a reference to an existing function:

	array.sort(<)

As a function parameter with explicit capture semantics:

	array.sort({ [unowned self] (item1: Int, item2: Int) -> Bool in return item1 < item2 })

As a function parameter with explicit capture semantics and 
inferred parameters / return type:

	array.sort({ [unowned self] in return $0 < $1 })