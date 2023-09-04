---
layout: post
title: How Does JavaScript Execute Asynchronously?
category: Javascript
tags: Async
excerpt_separator: <!--more-->
---

***"JavaScript chạy bất đồng bộ".*** Nếu như đã từng làm việc với JavaScript chắc hẳn bạn sẽ thường xuyên nghe thấy điều đó. Nhưng cho dù nghe thấy rất nhiều nhưng không phải ai cũng có thể khẳng định mình đã hiểu rõ về nó. Nếu bạn là một trong số đó hoặc muốn có một cái nhìn khác về bất đồng bộ trong JavaScript thì chúng ta hãy cùng bắt đầu nhé.
<!--more-->

## JavaScript Engine

Có một điều mà bạn cần phải hiểu rõ đó là bản thân JavaScript là một ngôn ngữ chạy đồng bộ, giống như Ruby, PHP, Python...Khi chạy ở Client-side hay Server-side nó đều cần một chương trình để thông dịch và thực thi mã và người ta gọi đó là một **JavaScript Engine**. Và cũng chính JavaScript Engine mới thực sự là nơi hỗ trợ cho JavaScript chạy bất đồng bộ. Có rất nhiều JavaScript Engine được sử dụng trên các trình duyệt hay môi trường khác nhau, tuy nhiên chúng đều có những thành phần chính đó là Memory Heap và Call Stack.

![](</media/javascript-asychronously/67680412ebd1ebd42baac53869babec7.webp>)

Dưới đây là những chức năng chính của chúng:
* **Memory heap**: Có nhiệm vụ cấp phát sử dụng và giải phóng bộ nhớ cho chương trình.
* **Call Stack**: Là một cấu trúc dữ liệu chứa các task của chương trình thực thi.

## Khi chạy đồng bộ

Trước khi đi tìm hiểu về bất đồng bộ trong JavaScript, chúng ta hãy cùng xem khi chạy đồng bộ JavaScript Engine sẽ xử lý như thế nào:

```js
function getUp() {
  console.log('I am waking up');
}

function haveBreakfast() {
  console.log('I have my breakfast');
}

function goToSchool() {
  console.log('I go to school');
}

getUp();
haveBreakfast();
goToSchool();
```

Trên đây là một đoạn chương trình mô tả những công việc thường được thực hiện vào buổi sáng. Sẽ không khó để bạn có thể đoán được những gì sẽ được log ra bên ngoài màn hình phải không. Tuy nhiên, hãy cùng quan sát hình ảnh dưới đây để hình dung rõ hơn về những gì đã xảy ra nhé:

![](</media/javascript-asychronously/9ec6f3a58f5c9338fe1e60a483516028.gif>)

**Call Stack** hoạt động tương tự như một cấu trúc dữ liệu dạng **LIFO** (Last In - First Out). Những đoạn code chạy đồng bộ sẽ được đưa vào stack và những task được đưa vào sau cùng sẽ được thực hiện đầu tiên. Để thực hiện được điều này, chúng ta phải nhờ đến một thành phần khác trong JavaScript Engine đó là **Event loop**. Chúng ta sẽ còn gặp lại nó trong những phần sau của bài viết.

## Khi chạy bất đồng bộ

JavaScript là một ngôn ngữ chạy đơn luồng (single threaded), nghĩa là trong một chương trình chỉ tồn tại một Call Stack duy nhất. Với những tác vụ nặng và tốn nhiều thời gian, toàn bộ chương trình tại thời điểm đó sẽ bị blocking cho đến khi tác vụ đó hoàn thành. Các bạn có lẽ đã từng gặp vấn đề này khi gửi một ajax request, chạy một vòng lặp vô hạn...lúc này chúng ta không thể thao tác được bất cứ thứ gì trên trình duyệt nữa. Để giải quyết vấn đề này, các JavaScript Engine đã cung cấp các API để có thể chạy các đoạn code JavaScript bất đồng bộ.

### Callback queue

Để có thể chạy bất đồng bộ, JavaScript sử dụng thêm một thành phần nữa gọi là Callback Queue. Bạn có thể hình dung Callback Queue giống như một phòng chờ trong nhà hàng. Với những khách hàng đã đặt lịch trước sẽ được ưu tiên phục vụ ngay trong Call Stack (Synchronous). Còn nếu bạn đến nhà hàng mà không báo trước, bạn có thể sẽ phải làm một vài thủ tục nào đó và ngồi đợi trước khi được phục vụ (Asynchronous). Tuy nhiên, trong một phòng chờ sẽ có những vị khách VIP và họ sẽ được ưu tiên phục vụ trước cho dù có thể họ không phải là người đến đầu tiên.

Callback Queue cũng tương tự như vậy, mỗi tác vụ sẽ có độ ưu tiên khác nhau. Tác vụ nào có độ ưu tiên cao hơn sẽ được đưa lên Call Stack trước. Thứ tự ưu tiên trong Callback Queue lần lượt là: **Microtask** > **Macrotask** > **Render Queue**. Trong đó Render Queue là các task liên quan đến việc render và update view của trình duyệt do đó trong phần này chúng ta chỉ tìm hiểu về Microtask và Macrotask.

### Macrotask

Microtask là một cấu trúc dữ liệu dạng **FIFO** (First In - First Out), nó thường lưu những tác vụ được thực hiện bởi Web APIs như `setTimeout`, DOM events...Chúng ta hãy cùng xem qua ví dụ dưới đây để hiểu rõ hơn về nó:

```js
function getUp() {
  console.log('I am waking up');
}

function makeCoffee() {
  setTimeout(() => {
    console.log('Making coffee in 5 minutes');
  }, 0);
}

function haveBreakfast() {
  console.log('I have my breakfast');
}

getUp();
makeCoffee();
haveBreakfast();
```

Trước khi chạy đoạn code trên các bạn hãy đoán xem những gì sẽ được log ra ngoài màn hình? Nếu như nó không giống như những gì bạn mong đợi thì hãy cùng xem hình ảnh dưới đây để biết điều gì đã xảy ra nhé:

![](</media/javascript-asychronously/8b71e050bcab42314d582bf836e59cc0.gif>)

Những method như `setTimeout`, `setInterval` hay các thao tác trên DOM đều là những API mà trình duyệt cung cấp cho chúng ta. Như trong ví dụ trên, `getUp()` và `haveBreakfast()` đều là những hàm chạy đồng bộ nên nó sẽ được đưa ngay vào Call Stack. Riêng hàm `makeCoffee()` do sử dụng `setTimeout` nên nội dung của nó sẽ được đưa vào Web APIs để thực hiện. Tại đây Web APIs sẽ xử lý và đặt một timer, khi hết giờ, task này sẽ được đẩy xuống Callback Queue cụ thể trong trường hợp này là Macrotask. Khi Call Stack trống thì những task dưới Callback Queue mới được lấy ra và đưa lên Call Stack. Một lần nữa Event loop sẽ lại là người giúp chúng ta thực hiện toàn bộ quá trình đó.

### Microtask

Tương tự như Macrotask nhưng có độ ưu tiên cao hơn, nghĩa là các task được lưu trong Macrotask chỉ được thực thi (đưa lên Call Stack) khi nào Microtask trống. Đó thường là những tác vụ xử lý liên quan đến Promise hoặc khi sử dụng hàm `queueMicrotask`. Chúng ta có một ví dụ với sự tham gia của cả Microtask và Macrotask:

```js
function getUp() {
  console.log('I am waking up');
}

function makeCoffee() {
  setTimeout(() => {
    console.log('Making coffee in 5 minutes');
  }, 0);
}

function haveBreakfast() {
  Promise.resolve().then(() => {
      console.log('I have my breakfast');
  });
}

makeCoffee();
haveBreakfast();
getUp();
```

Chắc sẽ không khó để chúng ta có được câu trả lời chính xác cho những gì đã diễn ra. Nhưng hãy cùng xem hình ảnh dưới đây để dễ hình dung hơn về nó nhé:

![](</media/javascript-asychronously/d1488a129a4811e189dd88279aa3b440.gif>)

* Đầu tiên hàm `makeCoffee()` được gọi và tương tự như ví dụ trên, phần xử lý của hàm này được thực hiện bởi Web APIs và ngay lập tức được đưa xuống Macrotask, hàm `makeCoffee()` đã xong và được xóa khỏi Call Stack.
* Hàm `haveBreakFast()` lập tức được đưa vào Call Stack. Hàm này chỉ thực hiện việc tạo ra và lưu một task vào trong Microtask, sau đó nó cũng được xóa khỏi CallStack.
* Lúc này `getUp()` mới được gọi và do đây là một hàm chạy đồng bộ nên phần xử lý của nó sẽ được đưa luôn vào trong CallStack.
* Sau khi hàm `getUp()` chạy xong, lúc này CallStack đã trống, các task trong Microtask sẽ được đưa ngược lên CallStack.
* Khi tất cả các Microtask đã được xử lý xong, Call Stask và Microtask lúc này đều trống thì đây mới là thời điểm để thực hiện các task đang được lưu trong Macrotask.

### Event loop

Event loop là một khái niệm rất quan trọng trong JavaScript. Ở một bài viết khác mình sẽ nói rõ hơn về nó, tuy nhiên trong khuôn khổ bài viết này, sau những ví dụ vừa qua, chúng ta cũng có thể tóm tắt cách thức hoạt động của Event loop như sau:
- Đầu tiên nó sẽ quét qua Call Stack, nếu như Call Stack còn có các task chưa được thực thi thì nó sẽ lấy ra task trên cùng và thực thi nó đồng thời loại bỏ task đó khỏi Call Stack.
- Nếu như Call Stack rỗng, các Microtask sẽ được đưa lên Call Stack theo thứ tự khi chúng được đẩy vào.
- Khi tất cả các Microtask đã được thực thi thành công, đó sẽ là lúc các Macrotask được thực thi, tương tự như với Microtask.

## Conclusion

Vừa rồi chúng ta đã đi tìm hiểu về cách JavaScript hoạt động khi chạy những đoạn code đồng bộ hay bất đồng bộ. Tuy rằng đó chỉ là cái nhìn tổng quan về những gì mà thực sự JavaScript đã làm nhưng hi vọng nó sẽ giúp cho các bạn hiểu hơn cũng như dễ hình dung hơn về những gì đã diễn ra. Hẹn gặp lại các bạn trong những bài viết khác.
