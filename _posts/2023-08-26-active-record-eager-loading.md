---
layout: post
title: Exploring ActiveRecord Eager Loading
category: Rails
tags: ActiveRecord
excerpt_separator: <!--more-->
---

Khi sử dụng ActiveRecord để load dữ liệu, đôi lúc chúng ta sẽ bắt gặp những trường hợp mọi thứ không hoạt động như những gì ta mong muốn. Đó là do tuỳ vào từng điều kiện, ActiveRecord sẽ lựa chọn hoặc kết hợp các phương thức eager load lại với nhau để thực thi truy vấn một cách hiệu quả, nhưng đó không phải lúc nào cũng là phương án tốt nhất. Vì vậy, việc hiểu rõ cách hoạt động của các phương thức eager load trong ActiveRecord sẽ giúp bạn tìm được phương án tối ưu nhất cho từng bài toán thực tế.
<!--more-->

## preload

Phương thức đầu tiên mà chúng ta nhắc đến là `preload`, hãy cùng tìm hiểu nó qua ví dụ sau:

```ruby
User.preload(posts: :comments)
```

```sql
SELECT `users`.* FROM `users`
SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` IN (1, 21, 31, 91, 111, 119, 129)
SELECT `comments`.* FROM `comments` WHERE `comments`.`post_id` IN (1, 11, 21, 31, 41, 51, 61, 71, 81, 91, 101, 111, 121, 131, 141, 151, 161, 171, 181, 191, 201, 211, 231, 241, 251, 261, 271, 281, 291, 311, 331, 341, 351, 361, 371, 401, 411, 431, 439, 449)
```

Với `preload`, ActiveRecord sẽ load dữ liệu thông qua các câu query riêng lẻ:

- Câu query đầu tiên để lấy ra `users`
- Câu query thứ 2 lấy ra `posts` của các `users` tương ứng
- Câu query cuối cùng sẽ lấy tất cả `comments` trong từng `posts`

## includes

 Cũng với ví dụ trên nhưng chúng ta sẽ dùng `includes`:

```ruby
User.includes(posts: :comments)
```

```sql
SELECT `users`.* FROM `users`
SELECT `posts`.* FROM `posts` WHERE `posts`.`user_id` IN (1, 21, 31, 91, 111, 119, 129)
SELECT `comments`.* FROM `comments` WHERE `comments`.`post_id` IN (1, 11, 21, 31, 41, 51, 61, 71, 81, 91, 101, 111, 121, 131, 141, 151, 161, 171, 181, 191, 201, 211, 231, 241, 251, 261, 271, 281, 291, 311, 331, 341, 351, 361, 371, 401, 411, 431, 439, 449)
```

Có vẻ như không gì khác so với khi dùng `preload`, vậy tại sao ActiveRecord lại tạo ra 2 methods này? Hãy cùng xem ví dụ dưới đây để thấy được sự khác biệt:

```ruby
User.includes(posts: :comments).where(posts: {id: 1})
```

```sql
SELECT `users`.`id` AS t0_r0, `users`.`name` AS t0_r1, `users`.`avatar` AS t0_r2, `users`.`email` AS t0_r3, `users`.`encrypted_password` AS t0_r4, `users`.`address` AS t0_r5, `users`.`phone` AS t0_r6, `users`.`memo` AS t0_r7, `posts`.`id` AS t1_r0, `posts`.`title` AS t1_r1, `posts`.`content` AS t1_r2, `posts`.`thumbnail` AS t1_r3, `posts`.`views` AS t1_r4, `posts`.`point` AS t1_r5, `posts`.`user_id` AS t1_r6, `posts`.`serial_id` AS t1_r7, `posts`.`created_at` AS t1_r8, `posts`.`updated_at` AS t1_r9, `posts`.`status` AS t1_r10, `posts`.`description` AS t1_r11, `posts`.`slug` AS t1_r12, `comments`.`id` AS t2_r0, `comments`.`content` AS t2_r1, `comments`.`user_id` AS t2_r2, `comments`.`post_id` AS t2_r3, `comments`.`created_at` AS t2_r4, `comments`.`updated_at` AS t2_r5 FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` LEFT OUTER JOIN `comments` ON `comments`.`post_id` = `posts`.`id` WHERE `posts`.`id` = 1
```

Ở trên chúng ta sử dụng `includes` kết hợp với điều kiện ở bảng quan hệ (`posts`). Mọi thứ hoạt động bình thường nhưng câu query không còn như trước. Thay vì load dữ liệu ở từng bảng, ActiveRecord đã sử dụng `LEFT JOIN` để lấy tất cả dữ liệu bằng một câu query duy nhất.

Bây giờ hãy viết lại ví dụ trên nhưng sử dụng `preload`:

```ruby
User.preload(posts: :comments).where(posts: {id: 1}).load
```

```sql
User Load (0.9ms)  SELECT `users`.* FROM `users` WHERE `posts`.`id` = 1
ActiveRecord::StatementInvalid: Mysql2::Error: Unknown column 'posts.id' in 'where clause'
```

Mọi thứ không hoạt động và chúng ta sẽ nhận được lỗi như trên. Nguyên nhân là với `preload`, ActiveRecord sẽ luôn luôn chạy từng câu query riêng để lấy dữ liệu trên từng bảng. Nghĩa là bạn sẽ không thể kết hợp `preload` với điều kiện khác trên các bảng quan hệ.

## eager_load

Bây giờ hãy cùng xem cách mà `eager_load` làm việc:

```ruby
User.eager_load(posts: :comments)
```

```sql
SELECT `users`.`id` AS t0_r0, `users`.`name` AS t0_r1, `users`.`avatar` AS t0_r2, `users`.`email` AS t0_r3, `users`.`encrypted_password` AS t0_r4, `users`.`address` AS t0_r5, `users`.`phone` AS t0_r6, `users`.`memo` AS t0_r7, `posts`.`id` AS t1_r0, `posts`.`title` AS t1_r1, `posts`.`content` AS t1_r2, `posts`.`thumbnail` AS t1_r3, `posts`.`views` AS t1_r4, `posts`.`point` AS t1_r5, `posts`.`user_id` AS t1_r6, `posts`.`serial_id` AS t1_r7, `posts`.`created_at` AS t1_r8, `posts`.`updated_at` AS t1_r9, `posts`.`status` AS t1_r10, `posts`.`description` AS t1_r11, `posts`.`slug` AS t1_r12, `comments`.`id` AS t2_r0, `comments`.`content` AS t2_r1, `comments`.`user_id` AS t2_r2, `comments`.`post_id` AS t2_r3, `comments`.`created_at` AS t2_r4, `comments`.`updated_at` AS t2_r5 FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` LEFT OUTER JOIN `comments` ON `comments`.`post_id` = `posts`.`id`
```

Bạn có thể thấy, `eager_load` sẽ chỉ dùng một câu query duy nhất để lấy tất cả dữ liệu, bất kể là có điều kiện trên các bảng quan hệ hay không:

```sql
User.eager_load(posts: :comments).where(posts: {id: 1})
```

```sql
SELECT `users`.`id` AS t0_r0, `users`.`name` AS t0_r1, `users`.`avatar` AS t0_r2, `users`.`email` AS t0_r3, `users`.`encrypted_password` AS t0_r4, `users`.`address` AS t0_r5, `users`.`phone` AS t0_r6, `users`.`memo` AS t0_r7, `posts`.`id` AS t1_r0, `posts`.`title` AS t1_r1, `posts`.`content` AS t1_r2, `posts`.`thumbnail` AS t1_r3, `posts`.`views` AS t1_r4, `posts`.`point` AS t1_r5, `posts`.`user_id` AS t1_r6, `posts`.`serial_id` AS t1_r7, `posts`.`created_at` AS t1_r8, `posts`.`updated_at` AS t1_r9, `posts`.`status` AS t1_r10, `posts`.`description` AS t1_r11, `posts`.`slug` AS t1_r12, `comments`.`id` AS t2_r0, `comments`.`content` AS t2_r1, `comments`.`user_id` AS t2_r2, `comments`.`post_id` AS t2_r3, `comments`.`created_at` AS t2_r4, `comments`.`updated_at` AS t2_r5 FROM `users` LEFT OUTER JOIN `posts` ON `posts`.`user_id` = `users`.`id` LEFT OUTER JOIN `comments` ON `comments`.`post_id` = `posts`.`id` WHERE `posts`.`id` = 1
```

Câu query lúc này giống hoàn toàn so với trường hợp sử dụng `includes` trong ví dụ ở trên. Như vậy có thể khẳng định, `eager_load` chính là `includes` khi kết hợp thêm điều kiện trên các bảng quan hệ. Nhưng chúng vẫn có một chút khác biệt, hãy xem qua ví dụ sau:

```sql
User.eager_load(posts: :comments).where("`posts`.`id` = 1")
```

Mọi thứ hoạt động bình thường, câu query không có gì thay đổi, tuy nhiên với `includes`:

```sql
User.includes(posts: :comments).where("`posts`.`id` = 1")
```

Chúng ta sẽ chỉ nhận được lỗi tương tự như trường hợp sử dụng `preload` ở trên:

```sql
User Load (12.2ms)  SELECT `users`.* FROM `users` WHERE (`posts`.`id` = 1)
ActiveRecord::StatementInvalid: Mysql2::Error: Unknown column 'posts.id' in 'where clause'
```

Nguyên nhân là với các điều kiện được viết bằng raw query, ActiveRecord sẽ không thể biết được sẽ phải join đến bảng nào để lấy dữ liệu. Lúc này chúng ta phải chỉ định rõ thông qua `references`:

```sql
User.includes(posts: :comments).references(:posts).where("`posts`.`id` = 1")
```

Bây giờ mọi thứ sẽ lại hoạt động bình thường và `includes` lại biến thành `eager_load`

## Use cases

Với `preload`, ActiveRecord sẽ luôn sử dụng các câu query riêng biệt để lấy dữ liệu trên từng bảng, do đó nó phù hợp khi dữ liệu trên các bảng đều lớn. Query trên từng bảng lúc này sẽ nhanh và hiệu quả hơn.

Ngược lại với `preload`, `eager_load` sẽ join các bảng lại với nhau để lấy dữ liệu trong một câu query duy nhất. Điều này làm giảm số lượng và thời gian connect đến database nhưng nó cũng có một nhược điểm đã được cảnh báo ở [đây](https://github.com/rails/rails/blob/20af938f397454c809cd60f37de35c242c271290/activerecord/lib/active_record/relation/query_methods.rb#L265-L266):

> NOTE: Loading the associations in a join can result in many rows that
contain redundant data and it performs poorly at scale.
>

Với `eager_load` dữ liệu lấy ra có thể bị lặp lại, điều này gây lãng phí bộ nhớ và cũng làm tăng thời gian mapping từ data sang objects model. Hãy cùng làm rõ điều này qua ví dụ sau:

Giả sử ta cần load ra thông tin của 10 `users`, mỗi user có 10 `posts`, mỗi post có 10 `comments`.

- Với `preload`, tổng số lượng objects cần phải load ra là:

```sql
10(users) + 100(posts) + 1000(comments) = 1100(objects)
```

- Với `eager_load`, ta có tổng số row là 1000, mỗi row sẽ chứa thông tin bao gồm của user, post và comment. Như vậy ta có số lượng objects là:

```sql
1000(users) + 1000(posts) + 1000(comments) = 3000(objects)
```

Vì vậy, chỉ nên sử dụng `eager_load` khi lấy cần lấy ra ít dữ liệu và việc join các bảng lại với nhau không gặp vấn đề gì.

`includes` sẽ linh hoạt hơn, nó thường được sử dụng trong các trường hợp ở giữa `preload` và `eager_load`. Tuy nhiên, bạn cũng nên thận trọng vì bình thường, nó sẽ hoạt động giống như `preload`, nhưng đôi lúc nó cũng có thể biến thành `eager_load`. Trong một vài trường hợp, điều này lại là nguyên nhân chính dẫn đến slow query khi mà tất cả các bảng liên quan bị join lại với nhau mà ta không kiểm soát được.

## Conclusion

Qua các ví dụ bên trên, chắc hẳn bạn cũng đã phần nào hiểu được cách hoạt động cũng như điểm giống và khác nhau giữa các phương thức eager loading trong ActiveRecord. Hi vọng đây sẽ là kiến thức cần thiết giúp bạn có thể lựa chọn phương thức eager loading nào là thích hợp nhất cho các bài toán thực tế.
