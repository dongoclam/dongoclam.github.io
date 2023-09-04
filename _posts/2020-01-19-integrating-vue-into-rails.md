---
layout: post
title: Integrating Vue into Rails
category: Rails
tags: Vue
excerpt_separator: <!--more-->
---

Nếu như đã từng làm việc với **Laravel**, chắc hẳn các bạn cũng biết **Vue** là framework mà Laravel lựa chọn để hỗ trợ cho phía frontend. Laravel đang là một trong những framework PHP phổ biến nhất hiện nay, vì thế sẽ không quá ngạc nhiên khi độ nổi tiếng của Vue cũng một phần do đó mà tăng lên dù bản thân Vue cũng đã mang trong mình sức mạnh, sự linh hoạt của những người đi trước như **React**, **Angular**...
<!--more-->

![](/media/integrating-vue-into-rails/a01a3410c2c18fab03f01f4cc00ff42c.png)

Về phía **Ruby on Rails**, độ phổ biến cũng như sức mạnh mà framework này mang lại là điều không phải bàn cãi. Tuy nhiên tính cho đến thời điểm hiện tại, phiên bản mới nhất của Rails là 6.0.2.1 vẫn sử dụng **Jquery** như là một thư viện mặc định hỗ trợ cho phần frontend. Trong khi các Javascript framework ngày một chiếm ưu thế về hiệu năng cũng như sự linh hoạt thì Jquery sẽ lộ ra nhiều hạn chế nếu như đem sử dụng trong các chức năng phức tạp đòi hỏi thao tác nhiều trên DOM. Vậy nếu như bạn yêu thích Rails cũng như yêu thích sự nhỏ gọn và mạnh mẽ của Vue thì tại sao không kết hợp chúng lại với nhau. Đó chắc chắn sẽ mang lại những kết quả rất tuyệt vời.

## Cài đặt

Đề bắt đầu chúng ta cần phải cài đặt [webpacker](https://github.com/rails/webpacker). Từ đây chúng ta sẽ cài đặt Vue và các packet cần thiết khác.
Thêm gem `webpacker` vào trong `Gemfile`, sau đó chạy `bundle install` để cài đặt:

```ruby
gem "webpacker"
```

Để hoàn tất quá trình cài đặt Vue bạn chạy tiếp hay lệnh:

```
rails webpacker:install
rails webpacker:install:vue
```

Sau quá trình này trong project của bạn sẽ xuất hiện thêm một số file config. Trong đó hãy chú ý đến file
`app/javascript/packs/application.js` vì đây là nơi chúng ta thực sự bắt đầu với Vue.

## Kết hợp

Để sử dụng được các component của Vue bên trong các file view của Rails chúng ta cần khởi tạo một đối tượng Vue và một component toàn cục, sau đó là đăng ký các component khác vào trong component này.
Thêm vào trong file `app/javascript/packs/application.js`:

```js
import "core-js/stable";
import "regenerator-runtime/runtime";
import Vue from 'vue/dist/vue.esm';
import App from '../app.vue';

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#vue-app',
    components: {
      App,
    },
  });
});
```

Như đã nói ở trên, trong trường hợp này `App` sẽ là component toàn cục. Nó được định nghĩa trong file `app/javascript/app.vue`:

```js
<script>
import Home from './components/home';
import Navbar from './components/header/navbar';
import PostDetail from './components/posts/detail';

export default {
  components: {
    Home,
    Navbar,
    PostDetail
  }
}
</script>
```

Đây là nơi chúng ta sẽ đăng ký các component để có thể sử dụng chúng ở bất cứ đâu trong view của Rails.
Việc cuối cùng của quá trình kết hợp này sẽ được chúng ta thực hiện trong file `app/views/layouts/application.html.erb`:

```html
<!DOCTYPE html>
<html>
  <head>
    <%= yield(:title) %>
    <%= stylesheet_link_tag "application", media: "all" %>
    <%= javascript_include_tag "application" %>
    <%= javascript_pack_tag "application" %>
  </head>

  <body>
    <div id="vue-app">
      <app inline-template>
        <div>
           <navbar />
           <h1>You can use any custom component inside the App components</h1>
           <%= yield %>
           <home />
        </div>
      </app>
    </div>
  </body>
</html>
```

Bên trong thể head chúng ta thêm vào tag `<%= javascript_pack_tag "application" %>`. Đây là một helper của gem `webpacker`, chức năng của nó chỉ là đưa nội dung của file `application.js` sau khi đã compile vào view tương tự như `javascript_include_tag` của Rails.

Như các bạn đã biết, Vue cần một element để có thể `mount` vào và trong trường hợp này là thẻ `div#vue-app`. Tiếp đó chúng ta sử dụng thuộc tính `inline-template` cho component `App`. Điều này là rất quan trọng bởi vì nó sẽ cho phép chúng ta có thể nhúng các vue component vào trong các file view của Rails đồng thời không làm ảnh hưởng đến các thành phần khác được `yield` vào từ các `partial` khác.

## Các cài đặt cần thiết

Về cơ bản, sau bước kết hợp ở trên chúng ta đã có thể sử dụng Vue trong Rails không khác gì so với trong Laravel. Tuy nhiên có một số vấn đề mà ta cần phải giải quyết để có thể hoàn toàn thoải mái khi sử dụng các component của Vue.

* Config I18njs

Khi ứng dụng có hỗ trợ nhiều ngôn ngữ khác nhau thì sẽ thật tốt nếu như chúng ta cũng có thể áp dụng điều này trong các vue component. Rất may mắn là đã có [i18n-js](https://github.com/fnando/i18n-js). Để cài đặt, đơn giản bạn chỉ cần thêm vào trong Gemfile.

```ruby
gem "i18n-js"
```

Sau đó chạy `bundle install` để hoàn tất. Tiếp theo là thêm vào cuối file `app/assets/javascripts/application.js`:

```
//= require i18n/translations
```

Chạy lệnh `rails i18n:js:export` để export toàn bộ config I18n trong các file `yml` ra một file `js`. Cuối cùng là đưa chúng ra ngoài view để sử dụng. Trong file `app/views/layouts/application.html.erb` chúng ta thêm vào bên trong thẻ head:

```
<%= javascript_include_tag "i18n" %>
```

Để sử dụng chúng ta chỉ cần gọi:

```js
I18n.t('posts.index.title') // => Post Detail
```

Tương tự như khi ta sử dụng gem `rails-i18n` chỉ khác là `i18n-js` không thể lazy loading giống như `rails-i18n` được.

* Routes

Rails cung cấp các url helper và path helper rất thuận tiện. Nếu như bạn cũng muốn sử dụng các helper này ở trong các vue component thì [js-routes](https://github.com/railsware/js-routes) sẽ là một lựa chọn tốt dành cho bạn. Đơn giản ta chỉ cần thêm dòng sau vào Gemfile:

```ruby
gem "js-routes"
```

Chạy bundle install để cài đặt. Bước cuối cùng là require nó vào trong file `app/assets/javascripts/application.js`:

```
//= require js-routes
```

Cách sử dụng cũng rất đơn giản, bạn chỉ cần gọi:

```js
Route.post_path(1, {comment_id: 2}) // => /posts/1?comment_id=2
```

* Tích hợp vào trong Vue

Để thuận tiện hơn trong việc sử dụng hai thư viện trên trong các vue component, chúng ta sẽ đưa những hàm cần dùng vào trong một file helper sau đó sử dụng `Vue.mixin` để đưa chúng vào trong tất cả các component khác. Tạo ra một file `app/javascript/mixins/helpers.js` có nội dung là:

```js
export default {
  methods: {
    t(key, options) {
      return window.I18n.t(key, options);
    },
    route(name, params = null) => {
      if (params && typeof(params) == 'object' && (params.slug || params.id)) {
        params = {...params, id: (params.slug || params.id)};
      }
      return params ? window.Routes[name](params) : window.Routes[name]();
    }
  }
};
```

Trong file `app/javascript/packs/application.js` chúng ta thêm đoạn code dưới đây vào ngay phía trên phần khởi tạo Vue:

```js
import helpers from '../mixins/helpers';
Vue.mixin(helpers);
```

Và bây giờ ở trong một component bất kì chúng ta có thể sử dụng:


```html
 <template>
  <div>
    <h1>{% raw %}{{ t('page.title') }}{% endraw %}</h1>
    <a :href="route('post_path', post)">{{ post.name }}</a>
  </div>
  </div>
</template>

<script>
export default {
  props: {
    post: {
      default: Object
    }
  }
}
</script>
```

* Vue tag helper

Khi sử dụng các vue component trong các file view của Rails, chắc chắn sẽ có lúc bạn cần truyền dữ liệu prop cho các component đó. Bình thường chúng ta có thể làm như sau:

```html
<div class="page-content">
  <post-detail :post="<%= @post.to_json %>" :is-voted="<%= current_user.voted? @post %>" />
</div>
```

Thực sự là nhìn nó không được mượt và chuyên nghiệp cho lắm, đấy là chưa kể đến những trường hợp cần phải truyền vào nhiều dữ liệu hơn thay vì như ví dụ trên. Để giải quyết vấn đề này, trong `ApplicationHelper` chúng ta thêm vào đoạn code sau:

```ruby
module ApplicationHelper
  def vue_tag name, **props, &block
    content_tag normalize_vue_key(name), normalize_vue_props(props) do
      capture(&block) if block_given?
    end
  end

  private
  def normalize_vue_key key
    key.to_s.downcase.gsub "_", "-"
  end

  def normalize_vue_props props
    props.transform_keys do |key|
      ":#{normalize_vue_key key}"
    end.transform_values do |value|
      !!value == value ? value : value.to_json
    end
  end
end
```

Trở lại với ví dụ bên trên, bây giờ chúng ta có thể viết lại thành:

```html
<div class="page-content">
  <%= vue_tag :post_detail, post: @post, is_voted: current_user.voted?(@post) do %>
      <div>Any content here</div>
   <% end %>
</div>
```

## Conclusion

Vừa rồi chúng ta đã cùng nhau hoàn thành việc kết hợp Vue vào trong Ruby on Rails. Hi vọng bài viết sẽ hữu ích cho những bạn cùng yêu cả hai framework này và mong muốn được làm việc với chúng trong cùng một project một cách hiệu quả.

