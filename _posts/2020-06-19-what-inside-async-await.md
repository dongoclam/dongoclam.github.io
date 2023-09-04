---
layout: post
title: What's Inside async/await?
category: Javascript
tags: Async
excerpt_separator: <!--more-->
---

Bạn có thể làm việc với Javascript như một ngôn ngữ lập trình hàm. Nếu không thích, bạn cũng hoàn toàn có thể xây dựng ứng dụng của mình theo hướng đối tượng cũng chỉ với JavaScript. Có lẽ chính vì điều này mà bản thân cú pháp của Javascript chứa rất nhiều dạng **syntactic sugar**.
<!--more-->

## Syntactic sugar

Hiểu đơn giản syntactic sugar có thể được xem là một dạng syntax giúp bạn viết code nhanh hơn hay chỉ là để phù hợp và gần gũi hơn với một phong cách lập trình nào đó mà bạn chọn. Để lấy ví dụ cho điều này chúng ta sẽ xem xét đến các cách tạo ra một object trong JavaScript. Nếu bạn là một người yêu thích các function thì đây có thể là lựa chọn của bạn:

```js
function Animal(name) {
    this.name = name
}

dog = new Animal('Puppy')
```

Nhưng bạn lại là một người yêu thích OOP hơn thì cũng đừng lo vì bạn vẫn có thể làm những gì mình muốn:

```js

class Animal {
  constructor(name) {
    this.name = name
  }
}

dog = new Animal('Puppy')
```

Hai cách viết hoàn toàn khác nhau nhưng lại cho ra những kết quả giống nhau và đó có thể coi là một dạng syntactic sugar. Như bạn đã biết, trong JavaScript không hề có khái niệm class, tất cả những gì bạn nhìn thấy trông thực sự giống cú pháp của một ngôn ngữ thuần hướng đối tượng như Java, C#...tuy nhiên những gì ẩn sâu bên dưới vẫn là thứ có mặt ở khắp nơi trong JavaScript đó là function. Nếu bạn còn đang băn khoăn:

```js
typeof Animal //=> "function"
```

Tại sao mình lại đề cập đến syntactic sugar, nghe có vẻ chẳng liên quan gì đến tiêu đề bài viết? Nhưng đừng vội vàng vì trước khi đến với async/await chúng ta sẽ phải đi tìm hiểu về một vấn đề khác nghe còn chẳng liên quan hơn. Đó là generator function.

## Generator Function

Với một function bình thường, các đoạn code bên trong nó sẽ được chạy tuần tự, khi dòng code cuối cùng được thực thi, cũng là lúc function đó kết thúc. Một generator function thì khác, nó có thể chạy nhiều lần, đúng hơn là nó có thể chạy rồi tạm dừng nhưng sau đó lại chạy tiếp. Chúng ta hãy cùng xem qua ví dụ dưới đây để thấy rõ sự khác biệt:

```js
function infinityLoop() {
  i = 0

  while (true) {
    i++
  }

  console.log('Finish loop...!')
}

infinityLoop()
```

Đây là một normal function và nếu như bạn thử chạy đoạn code đó trên trình duyệt, có lẽ sẽ không mất nhiều thời gian để trình duyệt của bạn rơi vào trạng thái đơ và nhiều khi bạn còn không thể tắt nó đi được. Thế nhưng với một generator function thì sao:

```js
function* infinityLoop() {
  i = 0

  while (true) {
    yield i++
  }

  console.log('Finish loop...!')
}

infinity = infinityLoop()
```

Như bạn đã thấy, cú pháp của một generator function cũng không có gì đặc biệt ngoại trừ dấu `*` và từ khóa `yield` . Và cũng sẽ không có bất kỳ vấn đề gì xảy ra với trình duyệt của bạn nếu đoạn code trên được chạy vì khi bạn gọi một genarator function, những gì bạn nhận được chỉ là một Generator Object.

```js
typeof infinity //=> "object"
```

Vậy object này có gì đặc biệt:

```js
infinity.next() //=> {value: 0, done: false}
infinity.next() //=> {value: 1, done: false}
infinity.next() //=> {value: 2, done: false}
```

Đây chính là cách mà một genarator hoạt động. Mỗi lần gọi hàm `next`, generator sẽ được thực thi, khi gặp từ khóa `yield` nó sẽ trả về một object chứa hai thuộc tính:

* value: Giá trị ở bên phải `yield` được trả về
* done: Trạng thái của generator, nếu là `true` điều đó có nghĩa là generator đã chạy xong, ngược lại là `false`

Generator lúc này sẽ rơi vào trạng thái ngủ đông, nó chờ đợi cho đến khi được gọi một lần nữa. Trở lại ví dụ trên, chúng ta có một vòng `while` vô hạn và một biến `i` có giá trị được tăng thêm sau mỗi vòng lặp. Vấn đề ở đây là chúng ta không bao giờ rơi vào vòng lặp vô hạn ấy mà chỉ sau khi gọi `infinity.next()` thì một vòng lặp mới được thực thi. Như vậy bằng cách nào đó, giá trị của `i` được lưu lại và sẽ tăng lên sau mỗi lần gọi. Trong trường hợp này, giá trị đó sẽ tăng lên vô hạn và không bao giờ chúng ta nhìn thấy dòng `Finish loop...!` được in ra màn hình.

Trong một ví dụ khác:

```js
function* sayHello() {
  let name = yield

  console.log('Hello ' + name)
}

hello = sayHello()
hello.next()       //=> {value: undefined, done: false}
hello.next('Lam')  //=> Hello Lam {value: undefined, done: true}
```

Bạn có thể thấy, hàm `next` có thể nhận vào một giá trị và giá trị này sau đó sẽ được gán cho `yield`. Như vậy, có thể thấy, `yield` sẽ ném ra giá trị bên phải nó và nhận về giá trị được truyền vào từ `next`.

Tóm lại, điểm khác biệt giữa một genarator function và một normal function là nó có thể tạm dừng quá trình thực thi và sau đó thực thi trở lại, nó trả về các kết quả khác nhau tại những thời điểm khác nhau.

## Async/await

Trước khi đi vào vấn đề chính chúng ta hãy cùng xem hai đoạn code dưới đây có điểm gì tương đồng:

* **Async Function**

```js
async function getUsers() {
  let url = 'https://reqres.in/api/users'
  let users = await fetch(url)

  console.log('Users: ', users)
}
```

* **Genarator Function**

```js
function* getUsers() {
  let url = 'https://reqres.in/api/users'
  let users = yield fetch(url)

  console.log('Users: ', users)
}
```

Nhìn vào đây chúng ta sẽ thấy `async` dường như là `function*` còn `await` có lẽ nào lại là `yield` . Vậy `async/await` liệu có phải là một dạng syntactic sugar và đằng sau lớp vỏ bọc đó là Genarator Function? Cách tốt nhất để có được câu trả lời là hãy sử dụng một function đơn giản để làm một generator function hoạt động giống như một async function.

```js
function runGeneratorLikeAsyncAwait(generator) {
  const generatorObject = generator()

  function loopUntilDone(value) {
    const next = generatorObject.next(value)

    if (next.done) return

    next.value.then(data => loopUntilDone(data))
  }

  loopUntilDone()
}
```

Ý tưởng và chức năng của function bên trên là:

* Nhận vào một genarator function
* Tạo ra generator object từ genarator function đó
* Gọi `next` trên generator object
* Vì giá trị `value` của mỗi lần gọi là một `Promise` nên giá trị truyền vào `next` ở lần gọi sau sẽ là `data` của `then`
* Lặp lại quá trình trên đến khi nào trạng thái `done` là `true`

Bây giờ là lúc để chúng ta kiểm tra kết quả:

* **Run Async**
```js
await getUsers()
```
* **Run Genarator**

```js
runGeneratorLikeAsyncAwait(getUsers)
```

Chắc chắn sẽ không có sự khác biệt nào khi chúng ta thực hiện hai đoạn code trên.

## Conclusion

Có rất nhiều điều thú vị trong Javascript dù đôi lúc nó có thể làm bạn không thể hiểu nổi chuyện gì đang sảy ra. Nhưng rất có thể, vấn đề đó của bạn không hoàn toàn phức tạp như bạn nghĩ mà đơn thuần nó chỉ là một biến thể nào đó của những thứ đã quá quen thuộc với bạn. Cũng giống như promises hay async/await, chúng không phải điều gì đó mới mẻ, vẫn là những thứ mà ta đã biết chỉ có điều là nó đã được Javascript khéo léo dấu bên dưới lớp vỏ bọc gọn gàng ấy.
