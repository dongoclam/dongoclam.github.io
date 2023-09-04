---
layout: post
title: Sidekiq Memory Problem
category: Rails
tag: Sidekiq
excerpt_separator: <!--more-->
---
Nếu đã từng sử dụng Sidekiq trong ứng dụng Rails, chắc hẳn bạn đã nghe hoặc gặp phải vấn đề liên quan đến memory. Dễ thấy nhất là việc memory mà Sidekiq chiếm dụng ngày một tăng lên và không có dấu hiệu giảm mặc dù không có job nào đang chạy. Có nhiều nguyên nhân dẫn đến tình trạng này, nhưng dưới đây có thể được xem như là những nguyên nhân chính.
<!--more-->

## Sidekiq Threading

Sidekiq hoạt động trên kiến trúc multithreaded, mỗi job sẽ được xử lý trên một thread. Các thread này không được khởi tạo và kết thúc cùng với job mà chúng sẽ được tạo ngay từ đầu theo setting `concurrency`. Nghĩa là nếu bạn setting concurrency là 15 thì lúc start, Sidekiq sẽ tạo ra 15 threads tương ứng và chúng sẽ luôn tồn tại cho đến khi stop Sidekiq.

Trong mỗi Sidekiq job, bạn có thể xử lý rất nhiều các tác vụ nặng, tạo ra nhiều objects và cần nhiều bộ nhớ. Nếu không quản lý tốt, sẽ còn nhiều vùng nhớ không được giải phóng sau khi job kết thúc. Lâu dần sẽ dẫn đến tình trạng Sidekiq không còn đủ bộ nhớ để sử dụng.

Để giải quyết vấn đề này, bạn có thể chạy job trong một forked process (child process). Mỗi khi job kết thúc, child process sẽ exit và vùng nhớ mà process sử dụng sẽ được giải phóng. Bạn có thể sử dụng gem [childprocess](https://github.com/enkessler/childprocess) hoặc sử dụng `Process.fork`.

Ruby hỗ trợ tạo child process từ parent process thông qua việc sửa dụng `Process.fork` method. Khi parent process exit thì child process vẫn có thể tiếp tục chạy và trở thành zombie process. Vì vậy, hãy luôn chắc chắn child process sẽ được kill ngay sau khi job kết thúc. Đây là một ví dụ để bạn tham khảo:

* Đầu tiên, bạn cần tạo một middleware:

```ruby
class Sidekiq::Middleware::ForkWorker
  def call _, message, _
    return yield unless message["fork"]

    pid = Process.fork do
      Process.setproctitle("#{message['class']} running in forked process #{pid}")
      yield
    ensure
      Sidekiq.logger.info("child process #{pid} completed")
    end

    Process.wait(pid)
  end
end
```

* Đăng ký middleware vừa tạo với Sidekiq:

```ruby
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add(Sidekiq::Middleware::ForkWorker)
  end
end
```

* Sau đó bạn có thể sử dụng ở các worker:

```ruby
class TestWorker
  include Sidekiq::Worker

  sidekiq_options fork: true

  def perform
  end
end
```

## Codding

Những tác vụ chạy trong background job thường nặng và xử lý mất nhiều thời gian. Trong quá trình đó, nếu như số lượng objects tạo ra không được kiểm soát sẽ dẫn đến tình trạng lãng phí bộ nhớ. Vì vậy, hãy luôn thận trọng khi xử lý dữ liệu những mảng dữ liệu lớn trong job.

* Khi kiểm tra điều kiện:

Khi sử dụng `present?`, bạn sẽ cần fetch toàn bộ records ra mảng:

```ruby
return if User.search(params).present?
```

Bạn nên dùng `exists?` hoặc `any?` trong trường hợp này:

```ruby
return if User.search(params).any?
```

* Khi loop:

Không nên dùng `each` hoặc `find_in_batches` nếu như bạn không cần duyệt qua từng phần tử trong danh sách:

```ruby
User.confirming.each do |user|
  user.update_columns(status_id: :confirmed)
end
```

```ruby
User.confirming.find_in_batches do |users|
  users.each {|user| user.update_columns(status_id: :confirmed)}
end
```

Thay vào đó hãy sử dụng `in_batches`:

```ruby
User.confirming.in_batches do |users|
  users.update_all(status_id: :confirmed)
end
```

* Query cache:

Từ phiên bản Rails 5.0, query cache được enable mặc định trong các background jobs. Nhiều trường hợp, việc sử dụng query cache sẽ làm tăng lượng bộ nhớ sử dụng. Tuy nhiên bạn cũng có thể disable tính năng này:

```ruby
ActiveRecord::Base.uncached do
  User.find_each {|user| user.confirmed!}
end
```

```ruby
User.find_in_batches do |users|
  users.each {|user| user.confirmed!}
  ActiveRecord::Base.connection.clear_query_cache
end
```

## Memory Fragmentation

Ngoài những nguyên nhân trực tiếp ở trên, việc chạy liên tục nhiều jobs trong thời gian dài có thể làm phân mảnh bộ nhớ. Tương tự như trên máy tính của bạn, đôi khi bạn sẽ thấy dung lượng mà ổ đĩa sử dụng cao hơn nhiều so với những gì nó thực sự lưu trữ.

Có nhiều nguyên nhân dẫn đến việc phân mảnh bộ nhớ trong các ứng dụng Ruby. Có thể kể đến như phần cứng, hệ điều hành, allocator và bản thân Ruby. `malloc` là một hàm trong glibc (thư viện C chuẩn) dùng để cấp phát bộ nhớ. Trong Ruby chỉ có khoảng 15% bộ nhớ được quản lý bởi GC, 85% còn lại do malloc.

Trong các ứng dụng multithreaded, để tránh việc xung đột khi cấp phát vùng nhớ, allocator sẽ có cơ chế lock, mỗi thread sẽ access đến vùng nhớ của nó thông qua các lock này. Cơ chế này làm tăng effort của allocator từ đó làm giảm hiệu suất của hệ thống.

Từ phiên bản glibc 2.10, đưa vào một khái niệm per-thread memory arena, nghĩa là mỗi thread sẽ tạo ra các memory arena riêng thay vì chỉ có một main arena như trước. Số lượng memory arena tối đa dành cho mỗi thread mặc định bằng:

```
malloc_arena_max = 8 * number_of_available_cores
```

Việc này làm tăng hiệu suất do mỗi thread có thể access trực tiếp vào các memory arena mà không cần thông qua cơ chế lock ở trên. Tuy nhiên điều này lại là nguyên nhân gây nên phân mảnh bộ nhớ. Khi có càng nhiều thread thì mức độ phân mảng càng cao.

Theo các tính toán, với giá trị malloc_arena_max mặc định ở trên giúp tăng 10% về hiệu suất nhưng mức tiêu thụ bộ nhớ cũng tăng thêm 75%. Heroku đã phát hiện ra điều này và có tiến hành test để đưa ra giá trị phù hợp cho malloc_arena_max. Lựa chọn giá trị nào sẽ dựa vào việc cân đối giữa hiệu năng và mức tiêu thụ bộ nhớ. Theo đó Heroku recommended sử dụng giá trị malloc_arena_max = 2.

## Conclusion

Vừa rồi chúng ta đã đi tìm hiểu về một số nguyên nhân và giải pháp xử lý vấn đề liên quan đến việc sử dụng bộ nhớ của Sidekiq trong các ứng dụng Rails. Nếu như chúng vẫn không giải quyết được triệt để vấn đề thì vẫn còn một giải pháp nữa đó là restart Sidekiq. Nghe có vẻ nguy hiểm nhưng đôi khi nó lại rất hiệu quả. Quy trình để kill Sidekiq mà không làm ảnh hưởng đến hệ thống bạn có thể xem ở bài viết **[Kill Sidekiq When It Reaches Memory Threshold](/kill-sidekiq-when-it-reaches-memory-threshold.html)**.

