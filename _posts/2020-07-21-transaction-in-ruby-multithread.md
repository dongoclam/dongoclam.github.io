---
layout: post
title: Handling Transactions in Ruby Multithreading
category: Ruby
tags: Transaction Multithread
excerpt_separator: <!--more-->
---

Nếu như đã từng làm việc với **Nodejs**, chắc hẳn bạn sẽ thấy với những công việc mất nhiều thời gian, việc đưa chúng vào một promise rồi sau đó sử dụng `Promise.all` sẽ là một giải pháp thực sự hiệu quả. Nếu như bạn đang làm việc với **Ruby on Rails** và vẫn muốn sử dụng tính năng đó cho project của mình thì gem [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby) có thể là một lựa chọn dành cho bạn. Trong phần này mình không đi sâu vào cách sử dụng của `concurrent-ruby`, tuy nhiên việc sử dụng nó cũng rất đơn giản nên các bạn hoàn toàn có thể tự tìm hiểu trước khi chúng ta cùng tiếp tục nhé.
<!--more-->

## Problem

Điểm khác biệt cơ bản giữa **Javascript** và **Ruby** nằm ở chỗ, **Javascript** là một ngôn ngữ chạy đơn luồng (singlethread) trong khi **Ruby** thì có thể hỗ trợ chạy đa luồng (multithread). Như chúng ta đã biết, mỗi một promise trong `Promise.all` sẽ tương ứng với một microtask, chúng sẽ được chạy đồng thời, bất đồng bộ trên cùng một thread, kết quả sẽ được trả về khi toàn bộ các task đã thực hiện xong. Với `concurrent-ruby`, chúng ta cũng có thể chạy nhiều task đồng thời, tuy nhiên mỗi task sẽ được chạy trên từng thread riêng biệt:

```ruby
def delete_user user
  user.destroy!
end

def delete_user_setting user
  user.user_setting.destroy!
end
```

Khi sử dụng concurrent:

```ruby
user = User.find 69

promises = [
  Concurrent::Promise.execute do
    delete_user_setting user
  end,
  Concurrent::Promise.execute do
    delete_user user
  end
]

Concurrent::Promise.zip(*promises).value!
```

Như ví dụ bên trên, `delete_user` và `delete_user_setting` sẽ được chạy trong hai thread hoàn toàn khác nhau. Vấn đề đặt ra là, làm thế nào để đảm bảo được việc `delete_user_setting` và `delete_user` sẽ đồng thời thành công hoặc đồng thời thất bại ? Điều này làm chúng ta nghĩ đến ngay việc sử dụng `ActiveRecord::Base.transaction` để giải quyết vấn đề này. Tuy nhiên, như đã nói ở trên, hai tác vụ này nằm trên hai thread khác nhau nên nếu sử dụng `ActiveRecord::Base.transaction` trong trường hợp này, bạn sẽ không bao giờ có được kết quả như mình mong muốn.

## Solution

Dưới đây là một giải pháp cho vấn đề mà chúng ta đang gặp phải, có thể sẽ có những giải pháp tốt hơn tuy nhiên nếu chưa tìm ra được thì bạn cũng có thể xem nó như một tài liệu tham khảo nhé. Ý tưởng của việc này sẽ dựa trên những yêu cầu cụ thể như:
- Phải xác định được trạng thái của từng task: `pending`, `error`
- Khi một task được thực hiện xong, nó sẽ phải đợi cho đến khi task cuối cùng hoàn thành
- Khi tất cả các task đã thực hiện xong và không có task nào xảy ra lỗi thì sẽ thực hiện commit vào DB
- Khi bất kì task nào raise ra lỗi, toàn bộ những task còn lại phải được rollback

Chúng ta sẽ tạo một class implement những yêu cầu trên:

```ruby
class PromiseTransaction
  attr_accessor :tasks, :flags, :error

  def initialize
    @tasks = []
    @flags = {}
    @error = false
  end

  def perform
    promises.each(&:execute)
    Concurrent::Promise.zip(*promises).value!
  end

  def queue_task &task
    self.flags[task.object_id] = false
    self.tasks.push wrap_task_in_transaction(task)
  end

  private
  def promises
    @promises ||= tasks.map do |task|
      Concurrent::Promise.new {task.call}
    end
  end

  def wrap_task_in_transaction task
    Proc.new do
      ActiveRecord::Base.transaction do
        begin
          return if error

          result = task.call
          self.flags[task.object_id] = true

          pending_until_done!

          result
        rescue
          self.error = true
          raise ActiveRecord::Rollback
        end
      end
    end
  end

  def pending_until_done!
    while pending?
      raise ActiveRecord::Rollback if error
    end
  end

  def pending?
    flags.values.any?(&:blank?)
  end
end

```

Class `PromiseTransaction` sẽ có nhiệm vụ là nhận vào các task cần thực thi, chúng ta sẽ có một biến `@tasks` là một mảng các task sau khi đã được wrap vào từng transaction, biến `@flags` để quản lý trạng thái của từng task xem nó đã được thực thi xong hay chưa và một biến `@error` để kiểm tra xem có task nào đó đã gây ra lỗi hay không. Khi một task được xử lý xong nó sẽ phải đợi đến khi task cuối cùng cũng được xử lý xong hoặc khi task nào đó raise ra lỗi. Method `pending_until_done!` sẽ thực hiện rollback lại khi giá trị `@error` là `true`.
Để kiểm tra chúng ta sẽ thử chạy:

```ruby
user = User.find 69
promise_transaction = PromiseTransaction.new

promise_transaction.queue_task do
  delete_user_setting user
end

promise_transaction.queue_task do
  delete_user user
end

promise_transaction.queue_task do
  sleep 5
  raise Exception
end

promise_transaction.perform
```

Mọi thứ chạy đúng như những gì chúng ta mong muốn.

## Conclusion

Vừa rồi mình đã chia sẻ tới các bạn một giải pháp trong việc xử lý transaction khi sử dụng `concurrent-ruby`. Hi vọng nó sẽ hữu ích cho những ai đang tìm hướng xử lý cho vấn đề này.
