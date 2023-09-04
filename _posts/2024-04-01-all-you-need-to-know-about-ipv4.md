---
layout: post
title: All You Need To Know About IPv4
category: Infrastructure
tags: NetWorking
excerpt_separator: <!--more-->
---

Khi muốn liên lạc với một người, bạn sẽ cần có địa chỉ của người đó, có thể là số điện thoại, email hay địa chỉ nhà. Nhưng dù là gì thì những địa chỉ đó luôn là duy nhất. Trên mạng internet cũng vậy, các máy tính muốn giao tiếp được với nhau sẽ cần có một địa chỉ IP. Vậy địa chỉ IP là gì, chúng ta sẽ cùng đi tìm hiểu nó trong bài viết này.
<!--more-->

## Structure

Địa chỉ IP là một chuỗi nhị phân 32 bit, được chia thành 4 phần bằng nhau gọi là các octet. Mỗi octet có 8 bit, cách nhau bởi dấu chấm. Việc biểu diễn số nhị phân thường không trực quan nên người ta chuyển mỗi octet thành một số thập phân, số này có giá trị từ 0 đến 255.

![alt text](/media/all-you-need-to-know-about-ipv4/a5137b22a86461f2b814c0dfd453d7b8.png)

Các máy tính kết nối mới nhau tạo thành một mạng riêng. Địa chỉ đại diện cho mạng gọi là network ID, địa chỉ của mỗi máy trong mạng gọi là host ID.

## IP Classes

Trong thực tế, để xác định một địa điểm trên thế giới bạn sẽ cần khoanh vùng và thu hẹp dần phạm vi cho đến khi tìm được chính xác vị trí của địa điểm đó. Địa chỉ IP cũng được chia thành các lớp để dễ dàng quản lý và định tuyến dữ liệu. Mỗi lớp IP sẽ cần tuân theo các quy tắc:

![alt text](/media/all-you-need-to-know-about-ipv4/9743e647affd44da20df97d9e2ac6949.png)

Dựa vào đây chúng ta sẽ có các lớp IP như sau:

|Class|From|To|Networks|Hosts/Network|
|------|------|------|------|------|
|A|1.0.0.0|127.255.255.255|126|16,777,214|
|B|128.0.0.0|191.255.255.255|16,382|65,534|
|C|192.0.0.0|223.255.255.255|2,097,150|254|

Riêng với các địa chỉ lớp A từ 127.0.0.0 đến 127.255.255.255 được dùng làm địa chỉ loopback sử dụng cho mục đích phát triển ứng dụng. Trên máy tính, bạn sẽ thấy địa chỉ của localhost thường là 127.0.0.1.

Ngoài ra còn có địa chỉ lớp D có phạm vi từ 244.0.0.0 đến 239.255.255.255 được dùng làm các địa chỉ multicast.
Địa chỉ lớp E từ 240.0.0.0 đến 255.255.255.255 được dùng trong nghiên cứu hay để dự phòng.

## Private IP

Các thiết bị muốn giao tiếp được trong mạng internet cần có một địa chỉ IP duy nhất và gọi đó là public IP. Được cấp bởi các nhà cung cấp dịch vụ internet (ISP), địa chỉ này tương tự như số điện thoại của bạn, là duy nhất trên toàn thế giới. Bất kỳ ai có nó cũng có thể gọi hay nhắn tin được cho bạn.

Tuy nhiên, tổng số lượng địa chỉ IPv4 có thể có là hơn 4 tỷ trong khi dân số thế giới đã là 8 tỷ người, chưa kể đến việc một người có thể sở hữu nhiều thiết bị khác nhau có kết nối internet. Vậy tại sao internet vẫn hoạt động khi không có đủ địa chỉ IP để cấp cho tất cả các thiết bị?

Đó là nhờ private IP. Thực tế, các thiết bị mạng trong nhà không nhất thiết phải có public IP mới có thể truy cập internet. Thứ duy nhất cần public IP là router.

![alt text](/media/all-you-need-to-know-about-ipv4/396ffdace1264cc67a8c5f65f6335288.png)

Các thiết bị kết nối tới router tạo thành một mạng nội bộ. Mỗi thiết bị sẽ được cấp một địa chỉ IP duy nhất trong phạm của vi mạng đó. Địa chỉ này gọi là private IP. Người ta dành ra một dải IP của từng class để làm private IP. Bạn sẽ không thể sử dụng IP này để giao tiếp với các thiết bị khác trên internet.

| Class | From | To |
| ------ | ------ | ------ |
|A|10.0.0.0|10.255.255.255|
|B|172.16.0.0|172.31.255.255|
|C|192.168.0.0|192.168.255.255|

Các thiết bị muốn truy cập internet sẽ cần đi qua router. Dựa vào NAT (Network Address Translation), router sẽ forward gói tin từ thiết bị ra ngoài internet và làm ngược lại trong trường hợp gói tin từ internet gửi về.

## Subnet mask

Khi số lượng host trong mạng lớn, thay vì tất cả đều connect đến một router thì việc chia mạng thành các mạng con nhỏ hơn mang lại nhiều lợi ích về mặt quản lý, làm giảm lưu lượng broadcast trên mạng. Giống như thay vì đánh số từ nhà đầu tiên đến nhà cuối cùng trong thành phố thì có thể chia ra đánh số cho từng nhà trong phạm vi nhỏ hơn theo phường, tên đường.

![alt text](/media/all-you-need-to-know-about-ipv4/d902acf02bf406fc12dbdbb6ca5c04f7.png)

Subnet mask dùng để chia một mạng thành các mạng nhỏ hơn. Là một số nhị phân 32 bit tương tự như địa chỉ IP, quy định các bit thuộc về phần địa chỉ mạng (có giá trị là 1) và các bit sẽ được dùng làm địa chỉ host (có giá trị là 0).

Ví dụ với mạng 192.168.1.0, bạn có thể mượn 2 bit của phần host để tạo thành 4 mạng con (2^2). Số lượng host mỗi mạng con là 62 (2^6 - 2) do mỗi mạng con cũng cần 1 địa chỉ mạng và một địa chỉ broadcast.

|Subnet|Host Address Range|Broadcast Address|
|------|------|------|
|192.168.1.0|192.168.1.1 - 192.168.1.62|192.168.1.63|
|192.168.1.64|192.168.1.65 - 192.168.1.126|192.168.1.127
192.168.1.128|192.168.1.129 - 192.168.1.190|192.168.1.191
192.168.1.192|192.168.1.193 - 192.168.1.254|192.168.1.255

Như vậy tổng số lượng host tối đa trong mạng là 248 (4 x 62). Số lượng mạng đã tăng nhưng tổng số lượng host giảm đi.

Để biểu diễn ta dùng kí hiệu 192.168.1.0/26. Nghĩa là mạng này có 26 bit đầu tiên thuộc về địa chỉ mạng, 6 bit còn lại sẽ được sử dụng làm địa chỉ host.

## Conclusion

Địa chỉ IP là một trong những kiến thức cơ bản mà bất cứ lập trình viên nào cũng nên nắm vững. Hiểu được cách địa chỉ IP và subnet mask hoạt động sẽ giúp bạn dễ dàng tiếp cận với những lĩnh vực khác liên quan đến Networking và Cloud Computing.
