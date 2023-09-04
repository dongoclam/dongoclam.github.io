---
layout: post
title: Linux File System
category: Linux
tags: Linux
excerpt_separator: <!--more-->
---
Nếu là một lập trình viên backend chắc hẳn bạn cũng không còn xa lại gì với Linux. Đây là hệ điều hành phổ biến thuộc họ UNIX với nhiều biến thể khác nhau, nó cũng là nhân của Android. Nếu như trên Windows, chúng ta thường không để tâm đến các thư mục hệ thống, mọi thao tác đều có thể thực hiện bằng giao diện đồ hoạ. Trên Linux, mọi thứ sẽ không dễ dàng như vậy. Khi thao tác với các file hay muốn biết những gì đang diễn ra trong hệ thống bạn có thể sẽ phải làm việc trên command line và cần biết cách tổ chức cũng như mục đích của từng thư mục.
<!--more-->

## Everything Is A File

Điều đầu tiên bạn cần biết đó là: **Mọi thứ trong Linux đều là file**. Chúng được phân cấp theo tiêu chuẩn FHS (Filesystem Hierarchy Standard). Hãy cùng đi qua từng thư mục để xem mục đích của chúng là gì.
![alt text](/media/linux-file-system/b327bf0031008c5329b7370c63d68870.png)

### `boot`

Đây là nơi chứa tất cả các file cần thiết cho việc khởi động hệ điều hành. Nội dung của nó sẽ tuỳ thuộc vào loại boot loader được sử dụng (LILO hay GRUB). Với boot loader GRUB, bạn sẽ thấy xuất hiện thư mục `grub`:

```
ls /boot/grub/
```

```
default  fonts  gfxblacklist.txt  grub.cfg  grubenv  i386-pc  locale  menu.lst  menu.lst~  unicode.pf2
```

Đây là một thư mục quan trọng và bạn không nên đụng vào nó.

### `bin`

Chứa các tập tin binary cơ bản, các lệnh mà bạn hay dùng như `cd`, `ls`, `whoami`... thực chất cũng chỉ là file. Có rất nhiều file trong thư mục này, mỗi file sẽ tương ứng với một lệnh và bạn có thể sử dụng nó ở bất cứ đâu. Bây giờ hãy thử copy một file và đổi tên nó:

```
sudo cp /bin/ls /bin/copy-of-ls
```

Bạn đã vừa copy file `copy-of-ls` từ file `ls`, và có một điều thú vị là khi bạn gọi:

```
copy-of-ls
```

Bạn sẽ thấy nó hoạt động không khác gì so với khi bạn dùng `ls`.


### `sbin`

Tương tự như `/bin`, `/sbin` cũng chứa những file binary nhưng có một chút khác biệt là các file này thường liên quan đến hệ thống, một số file khác chỉ có thể truy cập bởi administrators.

```
ls /sbin/
```

Bạn sẽ thấy các file có tên giống với những lệnh quen thuộc:

```
ip    shutdown    ifconfig    reboot
```

### `lib`

Đây là nơi lưu trữ những thư viện dùng chung, phục vụ cho hệ thống và các chương trình mặc định trong `/bin` và `/sbin`. Với các chương trình người dùng cài đặt, các thư viện hỗ trợ sẽ được lưu ở thư mục `/usr/lib`.

### `usr`

Tập trung các tập tin, thư viện cho các chương trình của người dùng nhưng ở một cấp khác ít quan trọng hơn.

```
ls /usr
```

```
bin  games  include  lib  lib64  libexec  local  sbin  share  src  tmp
```

Đây giống như phần mở rộng của hệ thống. Nếu như bạn không tìm thấy một lệnh nào đó trong thư mục `/bin` thì bạn có thể sẽ thấy nó trong `/usr/bin`, điều này cũng tương tự với `/sbin`.

### `home`

Khi một user được tạo ra, một thư mục có cùng tên với user đó sẽ tạo được trong thư mục `/home`. Mỗi thư mục sẽ chứa dữ liệu cá nhân của user, có thể bao gồm cả hai thư mục là `bin` và `sbin`. Bạn có thể kiểm tra thư mục home của current user bằng lệnh:

```
ls ~
```

```
bin  sbin
```

Chức năng của những thư mục này cũng là lưu trữ các file binary, chỉ khác là các file này ít được sử dụng hơn các file trong `/bin` và `/sbin`.

### `root`

Đây là thư mục cá nhân của người dùng root, người dùng có quyền cao nhất trong hệ thống Linux. Vì thế mà nó cũng khá đặc biệt khi không nằm trong thư mục `/home` giống những user thông thường khác. Người dùng bình thường có thể lưu trữ các tệp tin ở đây, nhưng cần quyền root để truy cập.

### `dev`

Là thư mục chứa các tập tin đại diện cho các thiết bị phần cứng như màn hình, bàn phím, thiết bị mạng...
Ngoài ra nó còn chứa các tệp tin đặc biệt như `/dev/null`, `/dev/zero`.

Mọi dữ liệu được ghi vào `/dev/null` sẽ bị loại bỏ, vì vậy nó thường được sử dụng để chuyển hướng hoặc bỏ qua đầu ra của một lệnh. Ví dụ sau sẽ ngăn hiển thị lỗi trên mà hình khi `cat` một file không tồn tại:

```
cat file_not_found 2>/dev/null
```

Trong khi đó, `/dev/zero` cung cấp nguồn dữ liệu vô hạn các byte có giá trị 0, nên nó được dùng để ghi đè, tạo file hoặc khởi tạo một vùng nhớ trên ổ cứng. Ví dụ sau sẽ tạo một tập tin có tên là myfile với kích thước 1GB:

```
dd if=/dev/zero of=myfile bs=1M count=1024
```

### `media và mnt`

Đây là hai thư mục chức các điểm kết nối cho các thiết bị lưu trữ di động như USB, CD/DVD...
Khi bạn cắm thiết bị lưu trữ di động vào máy tính, hệ thống sẽ tự động gắn kết thiết bị vào một thư mục con trong `/media`. Trong khi đó, việc sử dụng thư mục `/mnt` sẽ cho phép bạn gắn kết các hệ thống tập tin từ các thiết bị khác nhau, chẳng hạn như ổ cứng ngoài, ổ mạng NAS, v.v.

### `opt`

Thư mục này chứa các chương trình đã được đóng gói. Ví dụ khi cài đặt powershell, bạn sẽ thấy thư mục `microsoft/powershell/` trong thư mục `/opt`.

### `etc`

Là nơi lưu trữ các file cấu hình của hệ thống và các chương trình người dùng cài đặt. Ví dụ:

* `/etc/passwd`: Chứa thông tin về người dùng
* `/etc/shadow`: Chứa mật khẩu được mã hóa
* `/etc/init.d`: Chứa các tập tin khởi động cho các dịch vụ

Khi muốn thay đổi cấu hình của một chương trình nào đó, bạn cũng nên tìm đến thư mục này:

```
ls /etc/mysql/
```

```
conf.d  my.cnf  my.cnf.fallback
```

### `proc`

Chứa các tập tin ảo cung cấp thông tin về các tiến trình đang chạy, thông tin hệ thống như phiên bản kernel, thời gian hoạt động. Nó cũng cho biết các thông tin khác về phần cứng như RAM, ROM, CPU...Bạn có thể lấy các thông tin này bằng việc `cat` các file tương ứng:

* Lấy thời gian hoạt động

```
cat /proc/uptime
```
```
119820867.67 119161855.02
```

* Lấy version hệ thống:

```
cat /proc/version
```
```
Linux version 6.1.66-91.160.amzn2023.x86_64 (mockbuild@ip-10-0-60-142)
```

### `snap`

Chứa các gói phần mềm snap được cài đặt trên hệ thống. Đây là các gói snap là các gói phần mềm được đóng gói sẵn và có thể cập nhật độc lập. Nói qua về snap, đây là một hệ thống đóng gói và phân phối do Ubuntu Canonical phát triển. Bạn có thể xem thông tin của thư mục này bằng lệnh sau:

```
cat /snap/README
```

### `srv`

Dùng để lưu trữ dữ liệu được chia sẻ bởi các dịch vụ mạng, thường thấy trên các máy chủ Linux.
Ví dụ, dữ liệu web được chia sẻ bởi máy chủ web Apache có thể được lưu trữ trong thư mục `/srv/www/htdocs`.

### `sys`

Đây là thư mục hệ thống, cung cấp giao diện cho phép truy cập và quản lý các thiết bị phần cứng thông qua các tập tin và thư mục. Cũng giống như `/proc`, các tập tin này thường không được ghi trực tiếp vào ổ đĩa. Ví dụ bạn có thể kiểm tra image size như sau:

```
cat /sys/power/image_size
```

```
1023934464
```

### `var`

Lưu trữ các tập tin ghi lại trạng thái của hệ thống hoặc của ứng dụng. Đó có thể là các file log, email hay các file cơ sở dữ liệu... Chúng có thể tồn tại lâu dài mà không bị xoá sau khi reboot.

```
ls /var/
```
```
backups  cache  crash  lib  local  lock  log  mail  opt  run  snap  spool  tmp  www
```

### `run`

Là một hệ thống những tập tin tồn tại trên RAM (tempfs file), dùng để lưu trữ thông tin mô tả về hệ thống được tạo ra trong runtime. Mọi thứ sau đó sẽ bị xóa khi shutdown hoặc reboot hệ thống. Nó có thể chứa các tập tin PID (Process identifier) với quy ước đặt tên <program-name>.pid.

### `tmp`

Là thư mục lưu trữ tệp tin tạm thời được tạo bởi các ứng dụng để sử dụng trong một phiên làm việc. Các tập tin này thường được xoá sau khi hệ thống khởi động lại, chúng cũng có thể được xoá bất cứ lúc nào.

## Conclusion

Hiểu rõ hệ thống file Linux không chỉ giúp bạn dễ dàng tương tác với hệ điều hành, nó còn là bước đi đầu tiên giúp bạn nhanh chóng tìm được cách xử lý cho những vấn đề gặp phải. Hi vọng bài viết có thể giúp bạn tự tin và sử dụng Linux theo cách hiệu quả nhất.
