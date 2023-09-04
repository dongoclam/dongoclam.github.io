---
layout: post
title: "ActiveSupport: What You Didn't Know"
category: Rails
tags: ActiveSupport
excerpt_separator: <!--more-->
---

Trong quá trình làm việc với Ruby on Rails, khi gặp phải vấn đề đặc biệt cần giải quyết, nếu như không tìm hiểu kỹ, ta sẽ dễ tự tay xây dựng và giải quyết mọi thứ trong khi bản thân framework đã có sẵn những công cụ hỗ trợ cho vấn đề đó. Vì vậy thay miệt mài tìm giải pháp, hãy lướt qua `ActiveSupport` một lượt, rất có thể bạn sẽ tìm được ngay thứ mà mình cần.
<!--more-->

## ActiveSupport::CurrentAttributes

Với những trang web hỗ trợ authetication, nhất là khi sử dụng gem `devise` bạn sẽ bắt gặp `current_user` ở khắp nơi trong view hoặc controller. Có một vấn đề là `current_user` không khả dụng ở trong các models hay services…Lúc này `ActiveSupport::CurrentAttributes` có thể là một giải pháp dành cho bạn.

Theo định nghĩa, đây là một abstract class hỗ trợ singleton attribute cô lập theo thread. Nghĩa là nếu mỗi request được xử lý bởi một thread, thì bạn có thể truy cập attribute đó ở khắp mọi nơi đến khi request kết thúc. Trở lại với ví dụ trên, ta hãy so sánh trước và sau khi sử dụng current attributes:

- Trước khi sử dụng:

```ruby
# app/presenters/post_presenter.rb

class PostPresenter
  def initialize post, user
    @post = post
    @user = user
  end

  def current_user_post?
    @post.user.eql?(@user)
  end
end
```

Khi trả dữ liệu cho API:

```ruby
# app/controllers/posts_controller.rb

def show
  @presenter = PostPresenter.new(@post, current_user)
end
```

- Sau khi sử dụng:

```ruby
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end
```

```ruby
# app/controllers/application_controller.rb

before_action :set_current_user

def set_current_user
  Current.user = current_user
end
```

```ruby
# app/presenters/post_presenter.rb

class PostPresenter
  def initialize post
    @post = post
  end

  def current_user_post?
    @post.user.eql?(Current.user)
  end
end
```

```ruby
# app/controllers/user_controller.rb

def show
  @presenter = PostPresenter.new(@post)
end
```

Với những logic phức tạp, nhiều tầng code, đồng nghĩa với việc bạn phải truyền `current_user` vào sâu bên trong, lúc đó bạn sẽ thấy được lợi ích từ việc sử dụng current attributes. Tuy nhiên, tính năng này chỉ có từ phiên bản Rails 5.2 trở lên.

## ActiveSupport::Subscriber

Nếu như đã từng làm việc với Javascript, chắc bạn cũng không lạ gì với việc đăng ký và trigger sự kiện của một DOM. Rails cũng cung cấp một cơ chế tương tự như vậy và nó chính là `ActiveSupport::Subscriber`. Trong quá trình chạy, Rails trigger rất nhiều sự kiện, ví dụ như:

- `start_processing.action_controller`: Trigger khi bắt đầu process controller action .
- `process_action.action_controller`: Trigger sau khi đã process xong một action.
- `sql.active_record`: Trigger sau khi ActiveRecord chạy một câu sql.

Và còn nhiều event khác nữa. Nhưng chúng ta có thể dùng nó vào việc gì

Bạn có thể sử dụng nó vào việc monitoring hệ thống. Hãy cùng xem qua ví dụ dưới đây:

```ruby
module Monitoring
  class QuerySubscriber < ActiveSupport::Subscriber
    IGNORE_NAMES = ["SCHEMA", "EXPLAIN"]
    SLOW_TIME = 1000

    def sql event
      return if event.duration <= SLOW_TIME

      payload_name = event.payload[:name]
      return if payload_name.blank? || IGNORE_NAMES.include?(payload_name)

      event_data = event.payload.slice(:name, :sql)
      report_slow_query(event_data)
    end

    private
    def report_slow_quary event_data
      Slack.push_message(:slow_query, event_data)
    end
  end
end

Monitoring::QuerySubscriber.attach_to(:active_record)
```

Ở trên, chúng ta đăng ký một subscriber lắng nghe sự kiện `sql.active_record`. Với mỗi câu query được chạy, ta sẽ kiểm tra thời gian thực thi và report nếu như nó vượt quá 1s.

Bạn cũng có thể trigger event của riêng mình bằng việc sử dụng [ActiveSupport::Notifications](https://github.com/rails/rails/blob/5-2-stable/activesupport/lib/active_support/notifications.rb) với cơ chế tương tự.

## ActiveSupport::Callbacks

Với notifications hay subscribers, chúng sẽ được trigger tại một thời điểm thường là khi bắt đầu hay kết thúc một hành động nào đó. Callbacks cũng có phần tương đồng nhưng phạm vi của nó chỉ trong life cycle của một object. Ví dụ khi publish một bài post, bạn cần gửi notification cho followers, lúc này bạn nên sử dụng `ActiveSupport::Notifications`. Còn nếu bạn cần tự động set description cho bài post trước khi nó được save thì đó là lúc bạn nên dùng callback.

Ngoài những callbacks mặc định của Rails, bạn có thể tự đăng ký callback bằng cách sử dụng `ActiveSupport::Callbacks`. Hãy xem ví dụ dưới đây:

```ruby
class Post
  include ActiveSupport::Callbacks
  define_callbacks :publish

  def make_publish
    run_callbacks :publish do
      puts "Publish post"
    end
  end

  set_callback :publish, :before, :log_before_publish

  def log_before_publish
    puts "Log before publish"
  end

  set_callback :publish, :after do |post|
    puts "Log after publish ID: #{post.object_id}"
  end
end
```

Để define callbacks bạn cần làm các bước sau:

- Khai báo event nào trong object sẽ hỗ trợ callbacks thông qua `define_callbacks`.
- Cài đặt callbacks của events thông qua `set_callback`. Bạn có thể sử dụng instance method hoặc đơn giản là hơn là một `Proc` hay `lambda`. Các timming hỗ trợ bao gồm `before`, `arround` và `after`.
- Chạy các callback đã được đăng ký với events thông qua `run_callbacks`.

```ruby
post = Post.new
post.make_publish
```

Output:

```
Log before publish
Publish post
Log after publish ID: 2379297800
```

## ActiveSupport::StringInquirer

Đây là cách bạn có thể sử dụng để làm cho việc kiểm tra string trở nên dễ dàng và trong sáng hơn. Hãy xem ví dụ sau:

```ruby
class Media
  def initialize type
    @type = type
  end

  def text?
    @type == "text"
  end

  def image?
    @type == "image"
  end

  def video?
    @type == "photo"
  end
end
```

```ruby
media = Media.new("image")

media.image? # => true
media.text?  # => false
```

Nhưng với `ActiveSupport::StringInquirer` mọi thứ sẽ đơn giản hơn rất nhiều:

```ruby
class Media
  def initialize type
    @type = ActiveSupport::StringInquirer.new(type)
  end

  delegate :text?, :image?, :video?, to: :@type
end
```

```ruby
media = Media.new("image")

media.image? # => true
media.text?  # => false
```

## ActiveSupport::Duration

Khi bạn muốn xử lý các vấn đề liên quan đến một khoảng thời gian như countdown event, hiển thị deadline… `ActiveSupport::Duration` sẽ là điều đầu tiên bạn nên nghĩ đến. Nó hỗ trợ hầu hết các yêu cầu của bạn liên quan đến durration.

- Bạn có thể hiển thị durration:

```ruby
ActiveSupport::Duration.build(400.days)

# => 1 year, 1 month, 4 days, 7 hours, 41 minutes, and 42.0 seconds
```

- Nếu muốn lấy thông tin của durration:

```ruby
ActiveSupport::Duration.build(400.days).parts

# => {:years=>1, :months=>1, :days=>4, :hours=>7, :minutes=>41, :seconds=>42.0}
```

## Conclusion

Bản thân Rails đã hỗ trợ hầu hết các tính năng cần thiết cho việc phát triển một trang web cơ bản. Do đó, ứng dụng của ActiveSupport đôi khi bị lãng quên. Vì thế, nếu như gặp phải vấn đề với những hỗ trợ mặc định của Rails, bạn hãy tìm sự trợ giúp của ActiveSupport trước khi bắt tay vào xử lý mọi thứ.
