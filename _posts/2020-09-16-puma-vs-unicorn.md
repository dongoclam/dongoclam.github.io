---
layout: post
title: Puma vs Unicorn, Which is Better?
category: Ruby
tags: Multithread
excerpt_separator: <!--more-->
---

Trong các app server được sử dụng cho ứng dụng Rails thì có lẽ **Puma**, **Unicorn** và **Passenger** là những cái tên được nhắc đến nhiều nhất. Tuy nhiên do Passenger là một app server có tính phí nên ngày hôm nay chúng ta sẽ chỉ nói về Puma và Unicorn, cùng với đó, chúng ta sẽ đi tìm câu trả lời cho câu hỏi đâu mới là app server mạnh mẽ hơn.
<!--more-->

![](</media/puma-vs-unicorn/6164c01c68dec88472f70e6ebaf6e8c4.webp>)

## Process, Thread

Trước khi đi vào chủ đề chính, mình sẽ nhắc lại một số khái niệm cơ bản cho những ai chưa biết hoặc đã quên. Nếu như bạn đã hiểu rõ về process và thread thì có thể bỏ qua phần này và chuyển đến phần tiếp theo nhé.

### Process

Mỗi khi mở máy tính lên, việc đầu tiên các bạn làm là gì ? Với mình thì là bật Google Chrome lên. Nhưng có những hôm, do vội quá nên mình đã click vào Chrome tới 2 lần. Kết quả là đã có 2 cửa sổ Chrome được mở ra. Mỗi cửa sổ Chrome như vậy chính là một process đang chạy trong máy tính của mình.

Như vậy có thể hiểu một process là một tiến trình đang chạy trong hệ thống. Cùng một thời điểm có thể có một hay nhiều tiến trình chạy song song, tuy nhiên chúng độc lập với nhau và không chia sẻ bộ nhớ với nhau.

### Thread

Trở lại ví dụ khi bạn mở Chrome lên, bây giờ trên một cửa sổ trình duyệt, bạn bật thêm các tab mới. Một tab xem Youtube còn tab kia để lướt Facebook. Mỗi tab lúc này sẽ chính là một thread. Vậy có thể nói rằng, một thread luôn nằm trong một process nào đó. Trong một process có thể có nhiều thread chạy cùng nhau, chúng có thể chia sẻ bộ nhớ với nhau. Điều này có thể hiểu đơn giản là khi bạn có một ứng dụng chạy nhiều thread, trong ứng dụng đó bạn lưu một biến global, lúc này ở tất cả các thread, bạn đều có thể chỉnh sửa biến global này mà không gặp bất cứ khó khăn nào cả.

## Unicorn
Được xây dựng dựa trên kiến trúc `multi-process` và `single-thread`. Với mỗi request đến, Unicorn sẽ xử lý nó trên một thread trong một process duy nhất. Khi ứng dụng của chúng ta được khởi tạo, nó sẽ đồng thời được fork ra nhiều process khác nhau. Vậy điều gì sẽ xảy ra nếu như có request thứ 7 đến trong khi chúng ta chỉ có 6 process và tất cả trong số chúng đều đang bận? Câu trả lời là request thứ 7 đó sẽ phải đợi, đúng hơn là nó sẽ được đẩy vào queue cho đến khi một process nào đó đã xử lý công việc của nó. Nếu như hết thời gian đợi mà vẫn không có process nào tiếp nhận, request đó sẽ bị timeout - điều mà chúng ta cũng thường hay gặp.

## Puma
Khác với Unicorn, Puma hỗ trợ `multi-process` và `multi-thread`. Điều này có nghĩa là mỗi một request sẽ được xử lý trên một thread và trên một process có thể có nhiều thread chạy cùng nhau. Nghe xong điều này liệu chúng ta có thể nói rằng Puma có khả năng xử lý được nhiều request hơn Unicorn trong cùng một khoảng thời hay không? Điều này là không thể chắc chắn được. Puma hỗ trợ multi-thread, tuy nhiên trong quá trình làm việc, nó không hoàn toàn được chạy multi-thread. Lý do là vì hiện nay **MRI** đang là trình thông dịch phổ biến nhất của Ruby. Nó dựa trên cơ chế **Global Virtual Machine Lock** (tên gọi cũ là Global Interpreter Lock/GLI), theo đó, tại một thời điểm chỉ cho phép chạy một thread, trong khi một process chỉ được thực thi trên một CPU duy nhất (mỗi một process chỉ được xử lý trên một core).

Nếu như vậy thì Puma có khác gì so với Unicron đâu? Tất nhiên là có khác, nhưng trước hết có một vài thứ mà chúng ta cần phải làm rõ. Đó là trong một request, server cần phải thực hiện 2 nhiệm vụ đó là: Hoạt động liên quan đến I/O (read/write file, database queries, api call...) và các tác vụ khác do CPU xử lý. Trong đó thời gian giành cho I/O chiếm phần lớn thời gian của một request. Mặc dù **MRI** chỉ cho phép chạy một thread trên một core tại một thời điểm do, nhưng trong thời gian thực hiện các tác vụ I/O tốn thời gian, nó có thể switch sang các thread khác để xử lý trước những tác vụ cần đến CPU. Chính vì điều này mà Puma vượt qua Unicorn trong hầu hết các bài kiểm tra Benchmark. Chi tiết hơn về các bài kiểm tra này, các bạn có thể xem thêm tại [đây](https://tommaso.pavese.me/2016/12/21/unicorn-vs-puma-rails-server-benchmarks/) và [đây](https://deliveroo.engineering/2016/12/21/unicorn-vs-puma-rails-server-benchmarks.html) nữa.

Hiện nay, với các trình thông dịch mới như **jRuby** hay **Rubinius**, chúng có thể cho phép chạy nhiều thread đồng thời, điều này sẽ giúp cho Ruby có thể chạy multi-thread một cách đúng nghĩa, khi đó hiệu quả mà Puma mang lại sẽ được thể hiện nhiều hơn nữa.

## Conclusion

Vừa rồi là một số tìm hiểu của mình về Puma và Unicorn, nó cũng phần nêu lên được một số ưu điểm của Puma để khiến nó trở thành app server mặc định cho Rails. Tuy vậy việc lựa chọn app server nào còn tùy thuộc vào mục đích cũng như cấu hình máy chủ. Không phải cứ chạy nhiều process và nhiều thread là tốt vì nếu không sử dụng đúng, nó còn có thể gây lãng phí tài nguyên hệ thống. Một số điều mà chúng ta cần lưu ý khi lựa chọn sẽ có bao nhiêu process và bao nhiêu thread được chạy trên máy chủ của mình là:

* Mỗi một process sẽ cần một lượng RAM nhất định (với Rails app là từ 300 - 400 MB), do đó phải đảm bảo là server có đủ RAM.
* Quyết định có bao nhiêu thread sẽ được chạy trong một process phải dựa vào CPU, CPU phải đủ mạnh để chạy ứng dụng và phải đủ để xử lý các tác vụ khác nữa.

Nếu như bạn đang phân vân về việc lựa chọn app server nào cho ứng dụng của mình thì hi vọng bài viết này sẽ phần nào giúp bạn có được câu trả lời cho riêng mình.
