---
layout: post
title: SPA With Vue And Rails
category: Infrastructure
tags: Vue
excerpt_separator: <!--more-->
---

Ứng dụng SPA đang ngày càng trở nên phổ biến bởi những ưu điểm mà nó mang lại. Có thể kể đến như tốc độ tải trang nhanh, trải nghiệm mượt mà, tách biệt logic frontend và backend, giúp chuyên môn hoá từng bộ phận trong dự án.

Khó khăn khi phát triển ứng dụng SPA nằm ở việc kết nối giữa và đảm bảo tính đồng bộ giữa hai server frontend và backend. Đây là những vấn đề mà bạn không bao giờ gặp ở một ứng dụng SSR. Chưa kể việc tạo ra nhiều server có thể gây lãng phí vì thực tế chỉ có server backend chịu tải chính, server frontend sẽ chỉ lưu các tài nguyên như html, css, js…

Có một hướng tiếp cận đơn giản hơn giúp bạn sử dụng SPA cho dự án của mình mà không phải lo lắng đến các vấn đề trên. Bài viết này sẽ giúp bạn thực hiện điều đó với Vue và Rails.
<!--more-->

## Setup Rails

Ý tưởng của việc kết hợp Vue và Rails trong bài viết này là sử dụng Vue thay thế cho phần frontend mặc định của Rails. Nghĩa là Rails sẽ chỉ cung cấp các APIs để phía frontend là Vue sẽ gọi và hiển thị kết quả lên màn hình.

Đầu tiên, bạn cần khởi tạo dự án Rails:

```
rails new rails-vue
```

Sau khi cài đặt hoàn tất, chạy Rails server bằng lệnh:

```
cd rails-vue

rails s
```

Kiểm tra đường dẫn `localhost:3000`:

![alt text](/media/spa-with-vue-and-rails/fad83cebba01f4788175a8887eee68c7.png)

Như đã nói ở trên, Rails sẽ không quản lý và render view. Ứng dụng chỉ cần một trang home duy nhất để nhúng toàn bộ code frontend vào. Bạn tạo `HomeController` như sau:

```ruby
# app/controllers/home_controller.rb

class HomeController < ApplicationController
  def index
  end
end
```

Tạo file home index, đây sẽ là file chứa toàn bộ code của frontend:

```html
# app/views/home/index.html.erb

<h1>Home page</h1>
```

Sửa lại layout mặc định:

```erb
# app/views/layouts/application.html.erb

<%= yield %>
```

Khi người dùng nhập một đường dẫn, Rails sẽ redirect request đó về home. Tại đây, Vue xác định page nào sẽ được hiển thị để gọi các APIs tương ứng. Bạn cần config route luôn redirect về home:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root to: "home#index"

  get "*path", to: "home#index"
end
```

Bây giờ khi nhập bất kỳ đường dẫn nào:

![alt text](/media/spa-with-vue-and-rails/2c401008d36f05812d9b2eb1b6ac070c.png)

Bạn sẽ luôn thấy màn hình trên hiển thị.

## Setup Vue

Chúng ta sẽ sử dụng `vue-cli` để tạo một dự án Vue. Bạn có thể chạy lệnh sau để cài đặt:

```
yarn global add @vue/cli@next
```

Tại thư mục dự án, chạy lệnh dưới đây để tạo một dự án Vue:

```
vue create frontend
```

Thư mục `frontend` sẽ xuất hiện và bạn cần thêm config sau:

```js
// frontend/vue.config.js

const { defineConfig } = require('@vue/cli-service')
module.exports = defineConfig({
  transpileDependencies: true,
  indexPath: '../../app/views/home/index.html.erb',
  outputDir: '../public/frontend',
  publicPath: '/frontend',
})
```

Chúng ta đã trỏ `indexPath` đến trang home. Mỗi lần build, Vue sẽ update nội dung vào file này. Bây giờ hãy thử build bằng lệnh:

```
cd frontend

yarn && yarn build --watch
```

Refresh lại page, nếu màn hình dưới đây hiển thị thì mọi thứ đã thành công:

![alt text](/media/spa-with-vue-and-rails/7b4e1068000ec80273c9fa4d5daf9fb0.png)

Thử thay đổi nội dung template thành:

```html
# frontend/src/App.vue

<template>
  <img alt="Vue logo" src="./assets/logo.png">
  <HelloWorld msg="Rails Vue - Everything work well!"/>
</template>
```

Bạn sẽ thấy màn hình đã được update:

![alt text](/media/spa-with-vue-and-rails/5836446c0de43f2b7dae2a90d843a53a.png)

## Deploy

Do không sử dụng server riêng cho frontend nên việc deploy ứng dụng sẽ đơn giản hơn. Dưới đây sẽ là một số điều bạn cần lưu ý.

Đảm bảo vue-cli nằm trong phần `dependencies`:

```js
// frontend/package.json

{
  // ...
  "dependencies": {
    // ...
    "@vue/cli-plugin-babel": "~5.0.0",
    "@vue/cli-service": "^5.0.8"
  },
}
```

Không tạo source map trên production với config:

```js
// frontend/vue.config.js

module.exports = defineConfig({
  productionSourceMap: false,
  // ...
});

```

Nếu bạn sử dụng capistrano để deploy hãy thêm setting và rake task sau.

* Setting role cho frontend:

```ruby
# config/deploy.rb

set :yarn_role, :frontend
set :frontend_path, ->{release_path.join("frontend")}
```

* Rake task build frontend:

```ruby
# lib/capistrano/tasks/yarn.rake

namespace :yarn do
  desc "Build the frontend via yarn"
  task :build do
    on fetch(:yarn_role) do
      within fetch(:frontend_path) do
        execute :yarn, "install"
        execute :yarn, "build"
      end
    end
  end
end

before "deploy:updated", "yarn:build"
```

## Conclusion

Như vậy chúng ta đã tích hợp thành công Vue vào trong Rails. Với cách tiếp cận như trên, việc phát triển một ứng dụng SPA trở nên dễ dàng hơn. Hi vọng bài viết hữu ích với bạn.
