---
layout: post
title: Sleep and Mutex in Ruby
category: Ruby
tags: Async
excerpt_separator: <!--more-->
---

Giống như những ngôn ngữ lập trình bậc cao khác, Ruby hoạt động trên kiến trúc multi-threaded. Để xử lý các tác vụ khác nhau tại một thời điểm, chúng ta phải tạo ra các threads tương ứng với mỗi tác vụ đó. Điều này là khác so với cách mà một ngôn ngữ single-threaded như JavaScript làm. Tuy nhiên, ở một vài khía cạnh chúng vẫn có những điểm tương đồng.
<!--more-->

## Sleep

Nếu đã từng làm việc với Javascript, chắc bạn cũng hiểu cách hoạt động của `setTimeout`. Chức năng của nó là hẹn giờ để thực thi một khối lệnh nào đó sau một khoảng thời gian xác định. Trong Ruby, chúng ta cũng có cách để thực hiện yêu cầu trên, hãy cùng xem qua ví dụ sau:

```ruby
Thread.new do
  puts "I'll run first!"
end

Thread.new do
  sleep 3
  puts "I had slept for 3 seconds!"
end
```

Các câu lệnh chạy tuần tự và đúng như những gì bạn nghĩ, các message sẽ lần lượt xuất hiện:

```
I'll run first!
I had slept for 3 seconds!
```

Có vẻ như khi dùng `sleep`, mọi thứ sẽ dừng lại cho đến khi timer count down về 0. Đó là lý do mà sau 3s chúng ta mới nhận được message thứ hai. Bây giờ, hãy đổi thứ tự của các khối lệnh trên:

```ruby
Thread.new do
  sleep 3
  puts "I had slept for 3 seconds!"
end

Thread.new do
  puts "I'll run first!"
end
```

Đến đây, bạn hãy dừng lại một chút và thử đoán xem kết quả sẽ là gì. Như giải thích bên trên, có lẽ chúng ta sẽ thấy hai message xuất hiện đồng thời sau 3s. Nhưng thực tế bạn sẽ thấy mọi thứ không có gì thay đổi như ví dụ trước đó. Hai message sẽ vẫn xuất hiện theo thứ tự sau:

```
I'll run first!
I had slept for 3 seconds!
```

Tại sao lại như vậy? Mọi thứ không giống như những gì chúng ta nghĩ. Nhưng nếu để ý bạn sẽ thấy ở cả hai ví dụ, các threads chúng ta tạo ra đều chạy trên cùng một process. Mỗi khi gặp lệnh `sleep`, Ruby sẽ không hoàn toàn dừng mọi thứ lại, nó chỉ chuyển hướng sang xử lý ở các thread khác.

Điều này cũng tương tự như khi server xử lý các tác vụ I/O (Input/Output) bao gồm đọc, ghi dữ liệu vào ổ cứng hay gửi và nhận dữ liệu qua mạng. CPU có thể không cần phải hoạt động mạnh mẽ trong suốt quá trình này mà thường sẽ chuyển sang chế độ chờ (idle) hoặc xử lý các tác vụ khác. Điều này giúp server có thể đồng thời xử lý nhiều tác vụ và tối ưu hóa hiệu suất hệ thống.

## Mutex

Mutex là viết tắt của `Mutual Exclusion`. Trong Ruby, nó cung cấp một cơ chế đơn giản đảm bảo rằng chỉ một process hay một thread được phép truy cập vào một tài nguyên tại một thời điểm.

Vậy bạn có thể dùng Mutex trong các trường hợp nào? Hãy cùng xem ví dụ sau:

```ruby
number = 0

Thread.new do
  sleep 3
  number = number + 5
end

Thread.new do
  number = number * 2
end

Thread.new do
  sleep 5
  puts "Final number: #{number}"
end
```

Chúng ta mong muốn cuối cùng `number` sẽ có giá trị là 10 nhưng không phải như vậy:

```
Final number: 5
```

Giá trị cuối cùng của `number` chỉ là 5, nguyên nhân là gì chắc bạn cũng đã nhận ra. Trong thực tế, với một ứng dụng lớn có rất nhiều threads chạy đồng thời, nếu không cẩn thận, chúng ta cũng sẽ bắt gặp những tình huống tương tự. Đó có thể là lúc bạn nên nghĩ tới và sử dụng Mutex. Hãy cùng viết lại ví dụ trên với Mutex:

```ruby
number = 0
mutex = Mutex.new

Thread.new do
  mutex.synchronize do
    sleep 3
    number = number + 5
  end
end

Thread.new do
  mutex.synchronize do
    number = number * 2
  end
end

Thread.new do
  mutex.synchronize do
    sleep 5
    puts "Final number: #{number}"
  end
end
```

Bây giờ mọi thứ đã hoạt động như những gì bạn mong muốn:

```ruby
Final number: 10
```

Như vậy trong phạm vi của một mutex, `sleep` đã thực ngủ theo đúng nghĩa của nó.

Nói cách khác, Mutex đã tạo ra một không gian và đảm bảo những gì bên trong đó sẽ được sử lý một cách tuần tự.

Mutex hoạt động trên nguyên lý `lock/unlock`. Khi khoá Mutex được bật, tất cả các threads khác muốn truy cập vào một tài nguyên đang bị `lock` sẽ phải đợi cho đến khi tài nguyên đó được `unlock`. Như bạn đã thấy, method `synchronize` chính là implementation của cơ chế trên.

## Conclusion

Các threads hoạt động độc lập nhưng vẫn có thể truy xuất vào các tài nguyên chung trong cùng một process. Điều này có thể là nguyên nhân dẫn đến xung đột giữa các threads hay vấn đề race conditions. Vì vậy việc hiểu rõ cách hoạt động của thread sẽ có thể giúp bạn sử dụng nó một hiểu quả và an toàn.
