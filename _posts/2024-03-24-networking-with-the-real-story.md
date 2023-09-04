---
layout: post
title: Networking With The Real Story
category: Infrastructure
tags: NetWorking
excerpt_separator: <!--more-->
---

Chúng ta sử dụng internet hàng ngày và thường không để ý đến các thiết bị mạng trong nhà trừ khi chúng gặp sự cố khiến bạn không truy cập internet được nữa. Hệ thống mạng thoạt nhìn có vẻ phức tạp nhưng nếu thay đổi góc nhìn, bạn sẽ thấy nó cũng rất gần gũi với cuộc sống hàng ngày.
<!--more-->

## Real story

Hãy tưởng tượng bạn đang crush hai cô gái mới quen trên mạng. Nhân dịp kỷ niệm hai tuần quen nhau, bạn muốn gửi tới mỗi crush một món quà như để thể hiện tấm chân tình của mình. Nhà Linh chỉ cách mấy bước chân, buổi tối bạn có thể tự mình mang quà đến tận nơi tặng Linh. Trang lại ở nước ngoài, vì vậy bạn cần gói ghém món quà cẩn thận trước khi gửi gắm tấm lòng mình cho đơn vị vận chuyển. Tại đây, nhân viên sẽ chuyển tiếp đơn hàng của bạn đến bưu cục trung tâm để làm thủ tục thông quan. Về phía Trang, mọi thứ cũng diễn ra tương tự nhưng theo chiều ngược lại. Đây chính là hình ảnh về cách một gói tin được truyền đi trên mạng internet.

### IP Address

Để món quà đến được tay Linh và Trang, bạn cần đảm bảo địa chỉ của mỗi người là chính xác. Các máy tính trên mạng internet cũng vậy, chúng sẽ cần có một định danh IP duy nhất nếu muốn giao tiếp được với nhau.

![alt text](</media/networking-with-the-real-story/eb1977b2fc604951ae1ee55f9788f7fc.png>)

Các thiết bị kết nối phía sau router sẽ tạo thành một mạng nội bộ và chúng có thể giao tiếp với nhau bằng private IP. Nhưng khi muốn ra ngoài internet, các máy tính sẽ cần sử dụng tới public IP của router.

Giống với trường hợp của Linh, dù chỉ biết số nhà, bạn vẫn có thể xác định được Linh ở đâu để mang quà đến. Số nhà lúc này đóng vai trò như private IP. Đối với Trang, mọi thứ sẽ khác. Bạn cần biết thêm tên quốc gia, tên thành phố và tên đường mới có thể xác định được vị trí của Trang. Địa chỉ của Trang lúc này giống như một public IP.

### Protocol

Tuỳ vào địa chỉ của mỗi crush, bạn sẽ cần lựa chọn một phương thức vận chuyển phù hợp để món quà đến tay crush sớm nhất.

![alt text](</media/networking-with-the-real-story/67208cb889bcf673bf56c29745ca32dc.png>)

Vận chuyển một gói tin trên mạng internet cũng vậy, tuỳ thuộc vào tính chất của gói tin mà sẽ có những hình thức vận chuyển khác nhau. Với các tài nguyên web thông thường sẽ sử dụng giao thức HTTP, trong khi FTP được sử dụng để truyền tải file, SMPT dùng để gửi mail...

### Router

Đóng vai trò như bưu cục trung tâm trong ví dụ trên. Router là một thiết bị mạng dùng để định tuyến các gói dữ liệu đến các thiết bị đầu cuối, đồng thời giúp các thiết bị này giao tiếp với internet. Trong router có tích hợp bảng định tuyến thiết lập để điều hướng dữ liệu. Tương tự như cách nhân viên phân loại đơn của bạn trước khi gửi.

![alt text](</media/networking-with-the-real-story/e5f0cf9b5a80be02b7b4bb62918a7535.png>)

Giả sử bạn muốn gửi một gói dữ liệu đến máy tính có địa chỉ IP `101.25.67.20`. Do máy tính này không nằm trên cùng một mạng với máy của bạn nên gói tin sẽ được chuyển tới router. Router kiểm tra bộ định tuyến và biết nó cần chuyển tiếp gói dữ liệu này đến địa chỉ IP `10.0.0.2`.

### Switch

Nếu có quá nhiều thiết bị kết nối tới router sẽ làm cho việc định tuyến trở nên khó khăn và không hiệu quả vì vậy cần tách mạng thành những mạng con nhỏ hơn. Điều này cũng giống như việc đơn vị vận chuyển thường có nhiều bưu cục đặt ở địa phương thay vì chỉ có một bưu cục trung tâm.

![alt text](</media/networking-with-the-real-story/21e783e99b1ea1a3b8d45fbac34e5fea.png>)

Switch cũng có bảng định tuyến nhưng không giống với router, switch không thể trực tiếp giao tiếp với internet.

### Firewall

Trước khi được đóng gói để chuyển đến Trang, món quà của bạn sẽ được kiểm tra để đảm bảo rằng nó không chứa chất cấm hay các thành phần dễ cháy nổ khác. Ngược lại, đây cũng là cách đơn vị vận chuyển bảo vệ bạn trong trường hợp bạn là người nhận.

![alt text](</media/networking-with-the-real-story/6496fba60f2c02426b4bbf33d68590c9.png>)

Firewall cũng có chức năng tương tự. Nó thiết lập các quy tắc để bảo vệ mạng nội bộ, bảo mật thông tin, ngăn chặn các cuộc tấn công từ bên ngoài. Firewall cũng hạn chế bạn truy cập vào những trang web không an toàn để bạn có thể yên tâm lướt web.

## Conclusion

Như vậy là trải qua rất nhiều bước, cuối cùng món quà của bạn cũng đến được với Linh và Trang. Thông qua câu truyện vừa rồi, hi vọng bạn sẽ phần nào hiểu rõ hơn về những thành phần cơ bản nhất trong internet và cách mà chúng hoạt động.


