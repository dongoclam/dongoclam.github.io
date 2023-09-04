---
layout: post
title: Creating Mail System with Mailgun
category: Rails
tags: Mailgun
excerpt_separator: <!--more-->
---

Mailgun là một hệ thống các API mạnh mẽ, hỗ trợ việc gửi, nhận và quản lý các email từ hệ thống của bạn cho tới các email được gửi từ các dịch vụ email khác. Trong bài viết này, chúng ta sẽ xây dựng một thệ thống email nội bộ dựa trên một số tính năng mà Mailgun cung cấp.
<!--more-->

![](</media/creating-mail-system-with-mailgun/1908c862802adbd60300deefb60d413e.webp>)

## Tạo tài khoản và cấu hình Mailgun
Chúng ta vào địa chỉ của mailgun và đi đến đường dẫn [này](https://signup.mailgun.com/new/signup) để tạo cho mình một tài khoản. Sau khi điền đầy đủ các thông tin cần thiết, Mailgun sẽ gửi một email xác nhận. Việc tiếp theo tất nhiên sẽ là kiểm tra email và làm theo hướng dẫn để kích hoạt tài khoản Mailgun.

Sau khi đã kích hoạt tài khoản và đăng nhập thành công, chúng ta sẽ được chuyển đến trang quản trị của Mailgun. Mặc định Mailgun cung cấp cho chúng ta một domain để hỗ trợ cho việc test trong quá trình phát triển.  Nếu như đã có một server SMTP riêng, chúng ta hoàn toàn có thể tạo mới hoặc thay thế domain mặc định đó.

![](</media/creating-mail-system-with-mailgun/64ff3f4254a2e022246b4f924a27290d.webp>)

Hệ thống mail sẽ được xây dựng dựa trên ý tưởng lưu lại toàn bộ những email gửi đi cũng như các email từ các hệ thống khác gửi về. Việc lưu các email gửi đi từ hệ thống đơn giản chỉ là việc tạo mới một bản ghi trong bảng email.  Vậy còn chiều ngược lại, khi có một email từ bên ngoài gửi về, làm cách nào chúng ta có thể lưu nó lại trong hệ thống của mình? Với [Routes](https://app.mailgun.com/app/routes) của Mailgun, chúng ta đã có giải pháp cho vấn đề đó. Mỗi một route sẽ giống như một bộ lọc, chức năng chính của nó là chuyển tiếp (Forward) các email mà nó nhận được (Catch All) đến một địa chỉ email hay một url nào đó hoặc đơn giản là chẳng làm gì cả nếu như bạn coi đó là một email rác.

![](</media/creating-mail-system-with-mailgun/a3118275ff40a20f9245c5a94fb12a13.webp>)

Chúng ta vào đường dẫn [này](https://app.mailgun.com/app/routes/new) để tạo mới một route. Trong màn hình tạo mới route có 3 trường quan trọng nhất mà chúng ta cần lưu ý:
* **Expression Type:** Là bộ lọc xác định một email là hợp lệ hay không.
* **Actions:** Hành động sẽ được thực hiện khi một email gửi đến là phù hợp với bộ lọc ở trên. Mặc định, email sẽ được chuyển tiếp vào url mà chúng ta chỉ định trong trường Forward.
* **Priority:** Trong trường hợp chúng ta có nhiều route và một email có thể là hợp lệ với nhiều route trong số đó thì đây là thuộc tính để xác định xem email đó sẽ được ưu tiên xử lý ở route nào trước.

Như vậy chúng ta đã hoàn thành xong việc cấu hình Mailgun, việc còn lại là xây dựng hệ thống email của riêng mình
## Xây dựng hệ thống email

Trong phần này, chúng ta sẽ sử dụng framework `Ruby on Rails` để minh họa cho việc thực hiện.

#### 1. Lưu trữ email

Tạo bảng email có các trường `to`, `cc`, `bcc`, `subject`...Các trường của bảng này là tùy thuộc vào mục đích của hệ thống hướng đến nhưng phải luôn đảm bảo được tính bảo mật và dễ dàng xác định được người gửi, người nhận vào loại email tương ứng.

Người dùng trong hệ thống sẽ có một email riêng có dạng abc@yourdomain.com. Phải chắc chắn là chúng ta đã đăng ký domain của mình trong phần [Domain](https://app.mailgun.com/app/domains) trên Maingun.

#### 2. Gửi mail qua Mailgun
Mặc định `ActionMailer` của `Rails` sử dụng `deliver_method` là `:smpt`, để sử dụng với Mailgun, chúng ta cần sửa lại config như sau:

```ruby
config.action_mailer.delivery_method = :mailgun
config.action_mailer.mailgun_settings = {
  api_key: ENV["MAILGUN_API_KEY"],
  domain: ENV["MAILGUN_DOMAIN"],
}
```
Để thuận lợi cho việc gửi và lưu lại email, chúng ta tạo ra một `class` để thực hiện công việc này:

```ruby
class UserMailer < ActionMailer::Base
  def send_mail email
     mail to: email.to, subject: email.subject
     email.save
  end
end
```

Chúng ta tạo ra một object email tương ứng với các thông tin mà người dùng mong muốn, email này sẽ được tự động lưu lại ngay sau khi nó được gửi đi.

#### 3. Nhận mail về hệ thống
Khi có một email nào đó gửi đến một địa chỉ có dạng abc@yourdomain.com, Mailgun sẽ bắt được nó thông qua bộ lọc mà chúng ta đã thiết lập, sau đó nó sẽ lựa chọn các action tương ứng. Trong trường hợp này, email sẽ được forward về một url trỏ đến một `controller` mà chúng ta đã xác định từ trước. Tại đây email sẽ được xử lý và lưu vào database.

Để có thể test được trong quá trình phát triển, chúng ta sẽ phải sử dụng [ngrok](https://ngrok.com/) để public địa chỉ local ra bên ngoài, địa chỉ đó thường có dạng http://872f67bd.ngrok.io. Cùng với đó chúng ta sẽ sử dụng domain mặc định mà Mailgun đã tạo ra sau khi đăng ký tài khoản. Domain này thường có dạng sandbox123xyz.mailgun.org. Đến đây, chúng ta đã có thể dùng email cá nhân để gửi một email vào địa chỉ bất kỳ, giải sử đó là abc@sandbox123xyz.mailgun.org

Sau khi nhận được email, Mailgun sẽ tạo một request với method là `POST` tới url mà chúng ta đã định nghĩa.

![](</media/creating-mail-system-with-mailgun/77ecc638c4713cafea4069aadd3b8c5c.webp>)

Trong trường hợp này chúng ta muốn Mailgun gửi request về cho `EmailsController` thì trong phần fowards địa chỉ url sẽ là http://872f67bd.ngrok.io/emails

```ruby
class EmailsController < ApplicationController
  def create
    ReceiveEmailFromMailgun.new(params).perform
  end
end
```

Service `ReceiveEmailFromMailgun` sẽ có nhiệm vụ nhận xử lý params được gửi tử Mailgun và lưu email vào trong hệ thống.

```ruby
class ReceiveEmailFromMailgun
  def initialize params
    @params = params
  end

  def perform
    ActiveRecord::Base.transaction do
      users.each { |user| clone_email user }
    end
    true
  rescue
    false
  end

  private
  attr_reader :params

  def clone_email user
    email = user.emails.build email_params(user)
    if email.valid?
      email.update_attribute :attachments, email_attachments
    else
      raise ActiveRecord::Invalid
    end
  end

  def users
    @users ||= User.where email: email_to
  end

  def email_to
    params[:recipient].split(",").map(&:strip)
  end

  def email_cc
    return unless params[:Cc].present?
    params[:Cc].split(",").map { |email| email.scan(/<(.+)>/) }.flatten
  end

  def email_attachments
    params.values_at *params.keys.select{ |key| key.match /attachment-[0-9]/ }
  end

  def email_params user
    {
      to: [user.email],
      cc: email_cc,
      from: params[:sender],
      subject: params[:subject],
      info: params[:"body-plain"],
      created_at: params[:Date]
    }
  end
end
```

Các trường có trong `params` mà Mailgun gửi về, chúng ta có thể tìm hiểu thêm tại [đây](https://documentation.mailgun.com/en/latest/user_manual.html#routes). Dựa vào đây chúng ta có thể lấy ra những thông tin cần thiết. Nói qua một chút về chức năng của service `ReceiveEmailFromMailgun`, method `email_to`, `email_cc`, `email_attachments` tương ứng sẽ lấy ra một mảng địa chỉ `to`, `cc` và `attachments`. Từ địa chỉ `to` và `cc` chúng ta có thể xác định được email này đang muốn gửi tới cho user nào. Tới đây chúng ta thực hiện lưu lại email tương ứng với từng user được tìm thấy.

## Conclusion
Như vậy chúng ta đã cùng nhau đi tìm hiểu về cách sử dụng Mailgun để xây dựng hệ thống gửi nhận mail cho riêng mình. Tùy vào chức năng và yêu cầu của từng hệ thống mà cấu trúc cũng như các phương pháp được sử dụng có thể sẽ khác nhau. Bài viết giới thiệu một số trong rất nhiều các chức năng mạnh mẽ mà Mailgun cung cấp. Hi vọng nó sẽ hữu ích khi bạn cần xây dựng một hệ thống email mà bạn có thể chủ động trong việc quản lý nó.
