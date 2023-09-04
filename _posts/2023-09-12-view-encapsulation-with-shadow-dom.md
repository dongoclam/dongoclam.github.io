---
layout: post
title: View Encapsulation with Shadow DOM
category: HTML
tags: Encapsulation
excerpt_separator: <!--more-->
---

Với sự phát triển mạnh mẽ của các frameworks, công việc phía font-end cũng ngày một trở nên dễ dàng hơn. Xu hướng chia trang web thành các components khác nhau để quản lý và có thể tái sử dụng đang dần phổ biến. Các component được đóng gói và chỉ giao tiếp với nhau thông qua public API, tương tự như trong lập trình hướng đối tượng. Mỗi framework sẽ có những giải pháp khác nhau cho vấn đề này, tuy nhiên với HTML, bạn cũng hoàn toàn có thể đóng gói các components trong trang web của mình thông qua Shadow DOM.
<!--more-->

## Shadow DOM

Đây là một API của HTML, cho phép tạo ra các phần tử độc lập trên trang web. Chúng không thể bị can thiệp bởi stylesheet hay JS từ bên ngoài và ngược lại. Ví dụ thẻ `<video>`, `<iframe>`...là một trong những shadow DOM.

![](</media/view-encapsulation-with-shadow-dom/5507e17768a3bb5f22c79fc4fda6e8c7.svg>)

Một shadow DOM sẽ bao gồm các thành phần:

* **Shadow host**: Là một phần tử DOM thông thường, nơi mà shadow DOM được gắn vào.
* **Shadow boundary**: Giới hạn phạm vi của một shadow DOM.
* **Shadow tree**: Bao gồm toàn bộ nội dung HTML (DOM tree) của shadow DOM.
* **Shadow root**: Là root note của toàn bộ shadow tree.

## Create Shadow DOM

Để tạo một shadow DOM chúng ta có thể sử dụng phương thức `attachShadow` được hỗ trợ trong HTML5.

* Định nghĩa template cho element:


```html
<template id="my-element">
  <style>
    .inner {
      color: red;
    }
  </style>
  <div class="inner">
    This content is inside the shadow DOM
  </div>
</template>
```

* Tạo và attach shadow DOM:

```html
<script>
  class MyElement extends HTMLElement {
    constructor() {
      super();
      const shadowRoot = this.attachShadow({mode: 'open'});
      const template = document.getElementById('my-element');
      shadowRoot.appendChild(template.content.cloneNode(true));
    }
  }

  customElements.define('my-element', MyElement);
</script>
```

Ở đây, chúng ta tạo một [custom element ](https://developer.mozilla.org/en-US/docs/Web/API/Web_components/Using_custom_elements), shadow DOM sẽ được attach trực tiếp lên element đó. Chúng ta cũng có thể attach shadow DOM lên một element bất kỳ thông qua phương thức `attachShadow` của nó:

```html
<script>
  const shadowHost = document.querySelector('#shadow-host');
  const shadowRoot = shadowHost.attachShadow({mode: 'open'});
  shadowRoot.innerHTML = '<span>Inside shadow DOM</span>';
</script>
```

## Using Shadow DOM

Tương tự như các thẻ cơ bản khác của HTML, để sử dụng shadow DOM chúng ta chỉ cần gọi:

```html
<my-element></my-element>
```

Trình duyệt sau đó sẽ render ra nội dung tương ứng:

```html
<my-element>
  #shadow-root
    <style>
      .inner {
        color: red;
      }
    </style>
    <div class="inner">
      This is inside the shadow DOM
    </div>
</my-element>
```

Shadow host trong trường hợp này là `<my-element></my-element>`, mỗi một phần tử sẽ có một `shadowRoot`, toàn bộ nội dụng HTML trong `template` sẽ được quản lý bởi shadow root này.

Nội dung của thẻ `div.inner` sẽ không bị tác động bởi stylesheet hay JS bên ngoài, nó chỉ chịu sự tác động bởi các thay đổi diễn ra bên trong `<my-element>`.

## Conclusion

Việc sử dụng Shadown DOM có thể giúp bạn cấu trúc và quản lý một trang web thông qua components một cách hiệu quả. Đây là cách mà một số framework sử dụng để đóng gói components một cách toàn diện nhất.
