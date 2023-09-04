---
layout: post
title: Inside Ruby Class
category: Ruby
tags: RubyClass
excerpt_separator: <!--more-->
---

Trong chủ đề lần này chúng ta sẽ đi sâu vào tìm hiểu về hai khái niệm rất quen thuộc trong ruby đó là class và object. Hàng ngày chúng ta bắt gặp và làm việc với chúng nhưng không giống như trong những ngôn ngữ lập trình khác, class và object trong Ruby thực sự rất thú vị.
<!--more-->

## Class Structure
Ruby được tạo ra từ C nên chúng ta hãy cùng xem đoạn code dưới đây để có một cái nhìn rõ hơn về class trong Ruby

![](</media/inside-ruby-class/b3a8cb030a1749f7dbb1c81c3022e599.png>)

Những thành phần chính trong một class Ruby là các table chứa `methods`, `instance variables` và `constants`, chúng lần lượt có tên là `m_tbl`, `iv_tbl` và `const_tbl`. Một điều đặc biệt đó là class hay bất cứ đối tượng nào của Ruby đều có một cấu trúc có tên là `RBasic`. Cấu trúc này rất đơn giản

![](</media/inside-ruby-class/54398b423c11fa1fb44e51659bc4f9ce.png>)

Thuộc tính `flags` dùng để lưu những trạng thái hiện tại, dễ thấy nhất là khi ta sử dụng hàm `freeze` thì một flag nào đó sẽ xuất hiện ở đây.
Thuộc tính thứ hai là `klass`, nó dùng để trỏ đến class mà object hiện tại đang thuộc về. Đấy là lý do tại sao khi ta gọi `User.class` thì sẽ nhận được kết quả trả về là `Class`.

## Objects Have No Methods

Trong Ruby một object bản thân nó không chứa một method nào cả. Tất cả những gì có trong một object là `RBasic` và một table chứa các `instance variable`

![](</media/inside-ruby-class/9fc745d26a9cae36d84bbb55197e57f1.png>)

Object sẽ lấy ra các `methods` và các `constants` hay trỏ đến `supperclass` từ class đã tạo ra nó. Có thể hiểu đơn giản object là các đối tượng chứa dữ liệu còn class là một đối tượng đặc biệt khi nó cung cấp các phương thức để xử lý các dữ liệu cho các object reference đến nó.

## Singleton Methods

Singleton method là một method chỉ của riêng một object. Tuy nhiên nó lại không nằm trong object ấy cũng không nằm trong class đã tạo ra nó. Vậy object lấy ra những method đó từ đâu?

```ruby
me  = User.new
you = User.new

def me.age
  25
end

me.age   # => 25
you.age  # => NomethodError
```

Có một điều là khi một object được tạo ra, ngoài việc reference đến class tạo ra nó, nó còn reference đến một class nữa gọi là `SingletonClass`. Như vậy khi một `singleton method` được định nghĩa thì thực chất là nó sẽ được lưu trong `table methods` của class này:

![](</media/inside-ruby-class/210219b79ed98b21924054bfd4c781fc.png>)

Khi một method được gọi, đầu tiên nó sẽ được tìm kiếm trong `table methods` của `SingletonClass` trước sau đó mới đến class đã tạo ra nó.

## Class Methods

Bản chất class trong Ruby cũng là một object nên `class method` sẽ là `singleton method` của chính class đó

```ruby
class User
  def self.plural_name
    "users"
  end
end

user  = User.new

user.plural_name  # => NomethodError
User.plural_name  # => users
```

Khi định nghĩa mới một `class method` giống như ví dụ trên hoặc bằng method `instance_eval` của `Object` thì bản chất chúng ta đang mở `SingletonClass` của object hiện tại ra và đưa method đó vào.

![](</media/inside-ruby-class/25dbde8465f5e2a13eb2dbcd12ab8835.png>)

## Conclusion

Như vậy chúng ta đã vừa tìm hiểu về `class` và `object` trong Ruby, hai khái niệm cơ bản nhưng cũng là quan trọng nhất của OOP. Hi vọng bài viết sẽ giúp các bạn hiểu rõ hơn hoặc có một cái nhìn khác về hai khái niệm này.
