---
layout: post
title: Permission in Linux
category: Linux
tags: Linux
excerpt_separator: <!--more-->
---
Trong quá trình làm việc, Linux luôn đóng vai trò là môi trường chính để mình phát triển các dự án. Tuy đã làm việc với Linux trong một thời gian khá lâu nhưng nhiều khi mình vẫn thấy bối rối khi không thể chỉnh sửa hay chạy một file nào đó. Lỗi đơn giản chỉ là không có quyền thực hiện các tác vụ đó. Những lúc như thế mình thường thêm sudo vào đằng trước câu lệnh vừa nãy hay cục xúc hơn là sử dụng chmod 777 mà không cần biết tại sao. Dù hơi muộn nhưng vẫn hơn không, ngày hôm nay mình sẽ dành ra một buổi tối để tìm hiểu về vấn đề này.
<!--more-->

## Classes

Chúng ta đều biết permission là việc phân chia các quyền được phép thực hiện trên một tài nguyên hệ thống tương ứng với từng loại user. Vì vậy trước khi đi vào chủ đề chính, việc đầu tiên chúng ta cần biết là trong Linux tồn tại những lớp đối tượng nào có khả năng tác động đến các tài nguyên hệ thống.

### root

Trong các hệ điều hành họ Linux đều tồn tại một người dùng đặc biệt là root. Đây là người dùng có mọi quyền hạn liên quan đến việc quản lý tài nguyên trên hệ thống.

### user

Đây là những user bình thường, bao gồm cả user đang đăng nhập trong hệ thống. Bạn có thể kiểm tra user mà mình đang đăng nhập thông qua dòng lệnh:

```
whoami
```

Trong hệ thống có thể sẽ có nhiều user khác nhau nên bạn cũng có thể switch sang các user khác bằng lệnh:

```
su – otheruser
```

Khi không truyền tên user thì mặc định bạn sẽ được switch sang user root.

### group

Khi có nhiều user cùng tồn tại trên hệ thống, việc quan trọng bạn cần làm để có thể quản lý được quyền hạn của chúng là nhóm chúng vào trong các group. Mỗi user trong group sẽ có quyền tương ứng với group đó và một user có thể ở trong nhiều group khác nhau. Bạn có thể tạo mới một group như sau:

```
sudo groupadd docker
```

Bạn cũng có thể thêm một user vào trong một group:

```
sudo usermod -a -G docker lam
```

### owner

Với bất kỳ tài nguyên nào trên hệ thống, khi xét về tính sở hữu đối với tài nguyên, chúng ta có thể liệt kê ra những loại sau:

* **Owner**: Là user sở hữu tài nguyên
* **Group**: Là group sở hữu tài nguyên
* **Other**: Là những user, group còn lại, không sở hữu tài nguyên đó

Vậy làm thế nào để thay đổi chủ sở hữu cho một tài nguyên nào đó? Để dễ hình dung, chúng ta sẽ coi file `hello.example` là tài nguyên mà chúng ta cần thao tác.

Để đổi người sở hữu, chúng ta sử dụng:

```
chown [username] hello.example
```

Tương tự, nếu bạn muốn đổi group sở hữu:

```
chown :[groupname] hello.example
```

Trong trường hợp bạn muốn đổi cả owner và group thì sẽ chạy câu lệnh sau:

```
chown [username]:[groupname] hello.example
```

## Permission

Bây giờ bạn hãy vào thư mục chứa file `hello.example`, mở terminal lên và gõ lệnh sau:

```
ls -l
```

Trên máy của bạn có thể sẽ cho ra một kết quả khác nhưng trên máy của mình thì là:

```
-rwxrw-r-x  1 lam root       0 Th09 22 21:40 hello.example
```

Trong đó `lam` thể hiện user đang sở hữu file `hello.example`, còn `root` sẽ tương ứng với group đang sở hữu. Để dễ hiểu chúng ta sẽ phần tách chuỗi `-rwxrw-r--` ra như sau:

```
-       rwx        rw-        r-x
        u(owner)   g(group)   o(other)
```

Kí tự đầu tiên trong chuỗi biểu thị loại của tài nguyên. Nó cho ta biết đó là một file, một folder hay là một link. Mỗi 3 ký tự tiếp theo sẽ tương ứng với những permission đang được áp dụng cho owner, group và other. Cụ thể ý nghĩa của nó như sau:

![alt text](/media/permission-in-linux/d2efd578ca70531ca6a669e19d781f4b.jpeg)

Dựa vào đây chúng ta có thể thay đổi quyền thao tác lên bất cứ một tài nguyên nào chúng ta muốn.

### chmod

Đến thời điểm này, kết hợp tất cả những gì đã biết, bạn hoàn toàn có thể thay đổi quyền của từng nhóm người dùng chỉ trong một câu lệnh. Cú pháp chung sẽ là:

```
chmod [target][condition][permission] [filename]
```

Trong đó:

* **target** - đối tượng thay đổi quyền: `u` (owner), `g` (group), `o` (other), `a` (all).
* **condition** - điều kiện thay đổi: `+` (thêm vào), `-` (thu hồi).
* **permission** - các quyền được phép: `r` (read), `w` (write), `x` (execute).
* **filename**: Đối tượng chịu tác động.

Trở lại với ví dụ bên trên, bây giờ hãy thử thêm quyền execute file `hello.example` cho group `root` và `other`:

```
chmod go+x hello.example
```

Tương tự, nếu bạn muốn bỏ quyền execute của `owner` thì chỉ cần chạy lệnh dưới đây:

```
chmod u-x hello.example
```

Cú pháp trên rất thuận tiện và thích hợp khi bạn muốn thêm hoặc thu hồi quyền đối với một đối tượng nào đó. Tuy nhiên, nó có một hạn chế là bạn không thể thêm và thu hồi quyền một cách đồng thời. Rất may mắn là `chmod` cũng cung cấp cho chúng ta một cách khác để thực hiện điều đó. Mỗi permission sẽ tương ứng với một lũy thừa của 2, tổng các quyền sẽ tương ứng với tổng các giá trị của từng permission. File `hello.example` đang có trạng thái như sau:

![alt text](/media/permission-in-linux/dd34a7116626f16aee0ebbc7aeb0c34b.jpeg)

Khi biểu diễn bằng số, các quyền của nó sẽ là: `765` . Đến đây chắc các bạn cũng đã nhận ra, đôi khi chúng ta `chmod 777` là vì điều gì rồi đúng không.

## Conclusion

Vừa rồi là một số chia sẻ của mình về phân quyền trong Linux. Về cơ bản, chỉ cần nắm được kiến thức bên trên bạn đã có thể tự tin thao tác với những tài nguyên trên máy. Bạn có thể sẽ chưa thấy nó hữu ích nhưng đến một lúc nào đó, khi phải thao tác nhiều trên server, bạn chắc chắn sẽ cần đến những kiến thức này.
