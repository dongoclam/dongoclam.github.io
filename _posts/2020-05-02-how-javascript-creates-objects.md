---
layout: post
title: How Does JavaScript Create Objects
category: Javascript
tags: Prototype
excerpt_separator: <!--more-->
---

**JavaScript** là một ngôn ngữ rất linh hoạt, tuy nhiên ban đầu mình thực sự không có cảm tình với nó cho lắm. Có lẽ do đã quen với OOP và đem cái tư tưởng đó đi để tìm hiểu về nó, mình đã luôn cảm thấy mọi thứ ở đây lúc nào cũng rất lộn xộn. Function và object có ở khắp mọi nơi, chúng hòa trộn vào nhau làm cho bản thân mình nhiều khi không biết điều gì đang xảy ra.  Nhưng sau cùng thì mình lại cảm thấy thích nó và nếu như nhìn vào quá trình phát triển và mục đích mà nó hướng tới thì bạn có thể hiểu phần nào lý do mà JavaScript đã trở nên như vậy.
<!--more-->

Như chúng ta đã biết, JavaScript là một ngôn ngữ kịch bản. Khi thao tác với DOM, nó thể hiện mình như là một **Functional Programing**. Khi có sự xuất hiện của NodeJs, React, VueJs...thì lúc này, cũng chỉ với JavaScript, bạn hoàn toàn có thể thể sử dụng nó như một **Object Oriented Programing** để thoải mái vẽ vời và cũng để phù hợp hơn với công nghệ mà mình đang sử dụng. Điều này dường như làm cho mọi developer sử dụng JavaScript đều cảm thấy thoải mái và không bị bỡ ngỡ dù chỉ mới bắt đầu với lập trình hay đơn giản là chuyển từ một ngôn ngữ nào đó sang.

Vậy làm thế nào để JavaScript có thể hỗ trợ cho chúng ta một cách hiệu quả như vậy? Để biết được điều này, hãy cùng nhau tìm đến nơi mà JavaScript đã sử dụng `Function` để tạo ra các `Object`. Khi hiểu được quá trình này, có lẽ chúng ta sẽ có luôn câu trả lời cho câu hỏi trên.

## __proto__

Chắc hẳn bạn đã từng nghe rất nhiều về nó trong quá trình sử dụng JavaScript. Nếu như bạn đã biết nó là gì thì có thể bỏ qua phần này, còn nếu không chúng ta hãy cùng nhau tìm hiểu về nó nhé. Trước tiên hãy xem qua ví dụ dưới đây:

```js
const dog = {
  name: 'Puppy',
  run() {
    console.log(this.name + ' is running...')
  }
}

const puppy = Object.create(dog)

puppy.run()        //=> Puppy is running...
console.log(dog)   //=> {name: "Puppy", run: ƒ}
console.log(puppy) //=> {}
```

Mọi thứ nhìn có vẻ khó hiểu nhưng thực ra thì khó hiểu thật. Sẽ không khó để bạn đưa ra nhận định rằng  `puppy` dường như đã được kế thừa điều gì đó từ `dog` thì mới có thể `run` một cách ngon lành như vậy. Nhưng chúng ta cũng đã thấy, thực sự thì `puppy` không có gì bên trong nó cả, vậy mấu chốt của vấn đề này là gì?

```js
dog.isPrototypeOf(puppy) //=> true
puppy.__proto__ === dog  //=> true
```

Như vậy có thể hiểu `Object.create`  đã tạo ra một object mới kế thừa từ một object ban đầu, nhưng đây cũng không hẳn là kế thừa, vì như trong ví dụ trên, `puppy` đã không thực sự nhận được gì cả. Người thừa kế `puppy` của chúng ta chỉ có một đặc quyền duy nhất đó là `deletgating` (ủy thác) những việc mình muốn làm cho `dog` thực hiện. Và đặc quyền này được `puppy` cất giấu trong một property đặc biệt mà mọi object đều có đó là `__proto__`. Chúng ta cũng có thể kết luận rằng khi tạo ra một object từ một object khác bằng method `Object.create`  thì `__proto__` của object mới sẽ luôn trỏ tới object ban đầu, trừ khi chúng ta sử dụng `Object.setPrototypeOf` để bắt nó trỏ tới một object khác.

## prototype

Qua ví dụ trên, chúng ta đã biết `__proto__` là một property mà mọi object trong JavaScript đều có. Vậy còn với một `Function` thì sao, tất nhiên nó cũng là một object nhưng hơn thế nữa nó còn có một property đặc biệt khác mà đã từng làm mình rất bối rối đó là `prototype`. Chúng ta hay xem ví dụ sau để hiểu hơn về nó:

```js
function Dog() {}

Dog.prototype.name = 'Puppy'

Dog.prototype.run = function () {
    console.log(this.name + ' is running...')
}

console.log(Dog.prototype) //=> {name: "Puppy", run: ƒ, constructor: ƒ}
```

Như bạn đã thấy, mình vừa tạo ra một function có tên là `Dog` và chẳng làm gì với nó cả. Tuy nhiên bên trong function này đã có sẵn một property có tên là `prototype`. Đúng như tên gọi của nó, `prototype` là nơi để ta xây dựng các nguyên mẫu và sau đó đem nhân bản ra các object khác:

```js
puppy = new Dog()
puppy.run()                        //=> Puppy is running...
Dog.prototype.isPrototypeOf(puppy) //=> true
puppy.__proto__ === Dog.prototype  //=> true
```
Đến đây chắc hẳn bạn cũng đã hiểu điều gì đã xảy ra và có thể khẳng định rằng, mọi object được tạo ra bằng keyword `new` sẽ có `__proto__` trỏ tới `prototype` của đối tượng đã tạo ra nó (trong trường hợp trên là function `Dog`).

## Object creation

Chúng ta vừa đi qua hai ví dụ về `__proto__` và `prototype`. Nếu để ý các bạn cũng có thể nhận ra, qua các ví dụ đó mình đã sử dụng tới 3 cách để tạo ra một object:

* **Object as literal**: Sử dụng cặp dấu ngoặc `{}` và bên trong đó là danh sách các property, method của object.
* **Object.create**:  Sử dụng `Object.create` để tạo một object mới với `__proto__` trỏ tới object ban đầu.
* **Function constructor**: Tạo object bằng việc sử dụng từ khóa `new`. Object mới sẽ có `__proto__` trỏ tới `prototype` của function tạo ra nó.

Có thể bạn sẽ thắc mắc là tại sao mình không nhắc tới một kiểu tạo object nữa từ class. Ví dụ như:
```js
class Animal {
    constructor(name) {
        this.name = name
    }
    run() {
        console.log('Running...')
    }
}

dog = new Animal('Puppy')
```
Đúng là bạn có thể tạo một object theo cách như trên nhưng sự thật là trong JavaScript không có khái niệm class. Tất cả những gì bạn vừa thấy chỉ là một kiểu syntax khác để JavaScript trở nên thân thiện hơn đối với các lập trình viên đã quá quen với OOP. Ẩn sâu sau lớp vỏ bọc đó vẫn là các `Function`. Nếu các bạn còn băn khoăn thì có thể kiểm chứng:
```js
typeof Animal //=> function
```

### Object as literal

Đây là cách để tạo ra object đơn giản nhất và có thể cũng là thông dụng nhất trong JavaScript :
```js
const student = {
    name: 'Lam',
    say: function () {
        console.log('Hi! I am ' + this.name)
    }
}

student.name  //=> Lam
student.say() //=> Hi! I am Lam
```
Có lẽ cũng không cần nói nhiều về cách tạo ra một object theo kiểu này. Có thể hiểu nó đơn giản như một kiểu dữ liệu dạng `key-value`, trong đó `value` là bất cứ thứ gì mà bạn muốn, nhưng khi nó là một `function` thì người ta sẽ gọi nó là một method.

### Object.create

Khi bạn muốn tạo ra nhiều object có chung các thuộc tính hay method thì việc sử dụng `object as literal` thực sự không phải là một lựa chọn tốt. Bạn sẽ phải lặp lại rất nhiều các đoạn code giống nhau và khi muốn thay đổi một điều gì đó thì nó còn tồi tệ hơn là khi bạn tạo ra chúng. Lúc này bạn có thể sẽ nghĩ đến `Object.create`.
```js
const student = {
    say: function () {
        console.log('Hi! I am ' + this.name)
    }
}

const studentA = Object.create(student)
studentA.name = 'Student A'
studentA.say() //=> Hi! I am Student A

const studentB = Object.create(student)
studentB.name = 'Student B'
studentB.say() //=> Hi! I am Student B

student.say = function () {
    console.log('Hello everyone! I am ' + this.name.toUpperCase())
}

studentA.say() //=> Hello everyone! I am STUDENT A
studentB.say() //=> Hello everyone! I am STUDENT B
```
Như mình đã giải thích ở phần trên, `studentA` và `studentB` đều có `__proto__` trỏ đến `student`, vì thế khi `student` thay đổi thì chúng cũng sẽ được cập nhật các thay đổi tương ứng. Có thể thấy rằng `Object.create` đã thực hiện hai việc:
* Tạo một empty object mới
* Trỏ `__proto__` của object mới đó đến object ban đầu

Để dễ hình dung hơn, chúng ta cũng có thể biểu diễn chúng thông qua một đoạn code đơn giản sau:

```js
function createObject(object) {
    let newObject = {}

    Object.setPrototypeOf(newObject, object)

    return newObject
}

studentA = createObject(student)
```

Kết quả nhận được chắc chắn sẽ không có gì khác biệt.

### Function constructor
Trở lại ví dụ bên trên về `Animal` và thay đổi một chút:
```js
function Animal(name) {
    this.name = name
    this.run = function () {
        console.log(this.name + ' is running...')
    }
}

dog = new Animal('Puppy')
dog.name  //=> Puppy
dog.run() //=> Puppy is running...
```

Mình không chắc về những gì JavaScript thực sự đã làm sau từ khóa `new`, tuy nhiên đoạn code dưới đây có thể mang đến cái nhìn tổng quan cho toàn bộ quá trình đó:

```js
function createObjectOf() {
    let newObject = {}
    let args = Array.from(arguments)
    let constructor = args.shift()

    constructor.apply(newObject, args)
    Object.setPrototypeOf(newObject, constructor.prototype)

    return newObject
}

dog = createObjectOf(Animal, 'Puppy')
dog.name  //=> Puppy
dog.run() //=> Puppy is running...
```

Mọi thứ hoạt động đúng như mong muốn và bây giờ là lúc quay lại để xem chúng ta đã làm những gì trong `createObjectOf`:

* Đầu tiên là tạo ra một empty object mới.
* Lấy ra constructor và arguments tương ứng từ dữ liệu được truyền vào.
* Sử dụng `Function.prototype.apply` để gọi đến function constructor (ở đây là `Animal`) với `this` ở đây chính là `newObject`.
* Trỏ `__proto__` của `newObject` đến `prototype` của constructor thông qua `Object.setPrototypeOf`.
* Cuối cùng là trả về `newObject` vừa được tạo.

Đó là tất cả những gì JavaScript đã làm, có thể là với một cách thức khác nhưng kết quả thì không có gì khác biệt.

## Conclusion
Như vậy chúng ta đã cùng nhau tìm hiểu về cách thức mà một object được tạo ra trong JavaScript cũng như cách chúng kế thừa lẫn nhau. Hi vọng bài viết cũng sẽ hữu ích cho những ai còn đang băn khoăn về những vấn đề này giống như mình đã từng gặp phải. Hẹn gặp lại các bạn trong những bài viết sau.
