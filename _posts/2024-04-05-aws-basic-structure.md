---
layout: post
title: AWS Basic Structure
category: Infrastructure
tags: AWS
excerpt_separator: <!--more-->
---

AWS là nhà cung cấp dịch vụ cloud phổ biến nhất hiện nay. Tất cả những gì bạn cần ở một ứng dụng web bạn đều có thể tìm thấy trên AWS. Thay vì phải xây dựng hệ thống máy chủ vật lý phức tạp, AWS có thể cung cấp mọi tài nguyên mà bạn cần trên cloud. Tài nguyên trên AWS được ảo hoá nhưng chúng vẫn tuân theo kiến trúc của các hệ thống vật lý thông thường.
<!--more-->

![alt text](/media/aws-basic-structure/e4060a031cba22f50b75fa9bb4ec9826.png)

## Region

Region trong là một khu vực địa lý cụ thể, bao gồm nhiều Availability Zone (AZ). Mỗi Region có cơ sở hạ tầng riêng biệt, bao gồm các trung tâm dữ liệu, nguồn điện, mạng và hệ thống kết nối. Region được thiết kế để hoạt động độc lập, giảm độ trễ khi truy cập mạng trong cùng region. Tuân thủ các quy định về bảo mật dữ liệu khác nhau.

## Availability Zone

Nằm trong một region, mỗi AZ bao gồm một hoặc nhiều trung dữ liệu được kết nối với nhau.

![alt text](/media/aws-basic-structure/212316fd424bc0daf3a318fbb5e2fd1e.jpeg)

Một hệ thống nên được đặt trên nhiều AZ khác nhau để luôn đảm bảo tính sẵn sàng. Khi có thiên tai làm ảnh hưởng đến một AZ thì dữ liệu nằm ở AZ khác sẽ không bị ảnh hưởng.

## VPC

Viết tắt của Virtual Private Cloud, là một mạng riêng ảo riêng biệt trên aws. VPC có thể cross nhiều AZ hoặc region khác nhau.

![alt text](/media/aws-basic-structure/a2359f916507ef280fd1505fce4040cc.jpeg)

VPC giúp cô lập tất cả các tài nguyên trong hệ thống với internet, kiểm soát toàn bộ môi trường trong mạng từ dải địa chỉ IP, truy cập ra vào mạng...

## IGW

Internet Gateway là một thành phần của VPC hoạt động giống như một router, kết nối VPC với internet. Một VPC chỉ có một IGW và một IGW cũng chỉ được attach vào một VPC.

## Subnet

VPC có thể kiểm soát truy cập ra vào mạng nhưng không thể quản lý truy cập diễn ra trong nội bộ mạng. Khi có nhiều resources trong mạng, việc cần làm là nhóm các thành phần có tính chất tương tự ra một mạng riêng.

Giống như trong một công ty, các nhân viên thuộc cùng một phòng ban sẽ thường ngồi cùng một khu. Mỗi phòng ban sẽ có những quy định, nội duy riêng.

![alt text](/media/aws-basic-structure/4c6c24383b2fad80f26b787131a58fa8.jpeg)

Subnet trong AWS cũng vậy, nó được sử dụng để chia VPC thành các mạng nhỏ hơn. Từ đó dễ dàng kiểm soát truy cập, áp dụng các biện pháp bảo mật phù hợp với từng mạng. Các resource trong một subnet phải cùng nằm trong một AZ. Có hai loại subnet là **Public subnet** và **Private subnet**. Public subnet là subnet có có route table trỏ đến IGW.

## Route table

Là một danh sách các rule để kiểm soát truy cập ra vào của một mạng. Nó xác định đường đi cho một gói tin, giữa các subnet trong cùng một VPC, giữa các VPC khác nhau, hoặc giữa VPC và các nguồn tài nguyên bên ngoài như Internet.

![alt text](/media/aws-basic-structure/3636bbcd4285c9eb767dcd683de8c86a.png)

## NAT

Viết tắt của Network Address Translation. Cho phép các resources bên trong private subnet có thể truy cập internet bằng việc dịch private IP sang public IP.

![alt text](/media/aws-basic-structure/562da13e813ca680f63193fe01c70abd.png)

Có hai loại NAT:

- NAT Instance: Là một EC2 trong một public subnet, được attached Elastic IP.
- NAT Gateway: Là một thành phần của VPC, được AWS quản lý.

## NACL

Là viết tắt của Network Access Controller List, làm việc ở tầng subnet. Đóng vai trò như một firewall, kiểm soát truy cập thông qua các rule xác định giao thức, port, địa chỉ IP được phép hay không được phép ra vào subnet.

![alt text](/media/aws-basic-structure/2b6a8271f01695d158f36d4774565175.jpeg)

## Security Group

Có chức năng tương tự như NACL nhưng hoạt động ở tầng instance. Security Group kiểm soát truy cập ra vào instance nên có tính bảo mật cao hơn.

![alt text](/media/aws-basic-structure/9270cc31c506e9e92e88125ef07e46d4.png)

Security Group có thể kiểm soát một nhóm instance thuộc các subnet khác nhau.

![alt text](/media/aws-basic-structure/82056d31f434f817191149b9b23473d9.jpg)

## Load Balancer

Trong AWS, Load Balancer được sử dụng để cân bằng lưu lượng truy cập đến các ứng dụng.

![alt text](/media/aws-basic-structure/de679c3d714bd10c28633c259e6b6efe.jpg)

Dựa vào phạm vi hoạt động, người ta chia Load Balancer thành các loại:

- Network Load Balancer (NLB): Dùng để chuyển hướng request dựa theo IP address với độ trễ thấp.
- Application Load Balancer (ALB): Dùng để chuyển hướng request đến từng cụm target. Thích hợp với ứng dụng microservice.
- Gateway Load Balancer: Cân bằng tải lưu lượng truy cập đến các thiết bị ảo của bên thứ ba.

## Auto Scale Group

Đây là một dịch vụ quản lý tài nguyên của AWS, đảm bảo ứng dụng luôn sẵn sàng. Nó cho phép bạn định nghĩa các điều kiện để tăng hoặc giảm số lượng resources trong một group. Dựa các yếu tố như lưu lượng truy cập, phần trăm RAM, GPU sử dụng...

![alt text](/media/aws-basic-structure/b9e2e8063c375fbe278922d0768dfa13.jpeg)

Ngoài ra, ASG còn giúp tiết kiệm tài nguyên, tối hoá ưu chi phí.

## Conclusion

Trên đây là các thành phần cơ bản của một VPC. Nắm được bức tranh tổng quan, hiểu được vị trí của các thành phần trong mạng sẽ giúp bạn dễ dàng hơn trong việc đi sâu tìm hiểu thêm những services khác trong AWS.

