---
layout: post
title: Ruby Comparison Operators
category: Ruby
tags: Comparison
excerpt_separator: <!--more-->
---

Trong quá trình tìm hiểu về Ruby chắc hẳn chúng ta đã sử dụng hoặc nhiều lần bắt gặp các Equity method. Trong một số trường hợp chúng cho các kết quả giống nhau điều này đặt ra một câu hỏi là tại sao Ruby lại hỗ trợ nhiều method phục vụ cho việc so sánh như vậy? Để hiểu rõ hơn vấn đề này, chúng ta sẽ cùng nhau đi tìm hiểu từng method để biết chúng được sử dụng trong những trường hợp nào và sự khác nhau giữa chúng là gì.
<!--more-->

## Value comparision `==`

Ruby sử dụng method `:==` để so sánh giá trị giữa hai object

```ruby
1 == 1.0              # => true
{a: 1} == {a: 1.0}    # => true
```

## Case comparision `===`

Method `:===` được sử dụng trong cấu trúc `case/when`

```ruby
case object
when /pattern/
  # The regex matches
when 2..4
  # Some_object is in the range 2..4
when lambda {|x| some_crazy_custom_predicate }
  # The lambda returned true
end
```

Như có thể thấy ở ví dụ bên trên, để xác định xem khối lệnh nào sẽ được thực thi, Ruby sử dụng method `:===` để so sánh giá trị của `object` với từng trường hợp tương ứng. Hãy cùng xem ví dụ sao đây để hiểu rõ hơn:

```ruby
Range === (1..2)      # => true
Array === [1, 2, 3]   # => true
Integer === 2         # => true

(1..4) === 3          # => true
(1..4) === 2.345      # => true
(1..4) === 6          # => false

("a".."d") === "c"    # => true
("a".."d") === "e"    # => false
```

## Hash-key comparison `eql?`

Method `:eql?` được sử dụng để kiểm tra giá trị `key` của các phần tử trong một `Hash`. Chúng ta hãy cùng xem qua ví dụ sau:

```ruby
class Equ
  attr_accessor :val
  alias_method  :initialize, :val=

  def hash()
    self.val % 2
  end

  def eql?(other)
    self.hash == other.hash
  end
end
```

Chúng ta có một class `Equ`, giá trị truyền vào khi khởi tạo sẽ được gán cho cho biến `@val`. Tiếp theo chúng ta thực hiện override method `:eql?`. Method này trả về `true` nếu như hai object có `@val` cùng chẵn hoặc cùng lẻ

```ruby
h = {Equ.new(3) => 3, Equ.new(8) => 8, Equ.new(15) => 15} #3 entries, but 2 are :eql?
h.size            # => 2
h[Equ.new(27)]    # => 15
```

Chúng ta khởi tạo một `Hash` với tất cả 3 cặp `key => value`, tuy nhiên khi kiểm tra lại thì ta nhận được một kết quả khá thú vị. Lý do là `Equ.new(3).eql? Equ.new(15) == true` nên `Equ.new(15) => 15` sẽ ghi đè giá trị đã được gán cho key `Equ.new(3)` trước đó. Vì vậy `h[Equ.new(27)] == h[Equ.new(15)] == h[Equ.new(3)] == 15`. Qua ví dụ trên ta có thể khẳng định, `Hash` đã sử dụng `:eql?` để duyệt qua các key

## Object identity comparison `equal?`

Method `equal?` trả về true nếu như hai object cùng trỏ đến một object

```ruby
obj = obj2 = "something"
obj.equal? obj2         # => true
obj.equal? obj.dup      # => false
obj.equal? obj.clone    # => true
```

Khác với các method trên, `:equal?` không thể override được.
