---
layout: post
title: How ActiveRecord Builds Query
category: Rails
tags: ActiveRecord
excerpt_separator: <!--more-->
---

Nếu là một Rails developer, chắc hẳn bạn cũng đã từng làm việc với ActiveRecord và thấy được sức mạnh của nó. Nhưng đã bao giờ bạn tự hỏi, làm thế nào nó có thể tạo ra được những câu query phức tạp như vậy. Ngày hôm nay chúng ta sẽ đi tìm câu trả lời cho câu hỏi này.
<!--more-->

## Abstract Syntax Tree

Điều đầu tiên bạn cần biết là ActiveRecord không trực tiếp build các câu query bằng cách nối các đoạn string mà tất cả đều dựa trên Abstract Syntax Tree (AST). Mỗi một câu query là một AST bao gồm các node (`Arel::Nodes::Node`) chứa thông tin của từng query fragment. Sau khi kết hợp các node lại với nhau chúng ta sẽ được một câu query hoàn chỉnh. Và mọi thứ bắt đầu từ [đây](https://github.com/rails/rails/blob/main/activerecord/lib/active_record/relation/predicate_builder.rb), ActiveRecord sẽ parse params thành từng phần và tạo các node tương ứng.

Để biết cấu trúc của một node bao gồm những thành phần gì, chúng ta hãy cùng phân thích một query fragment đơn giản sau:

```sql
`users`.`id` = ?
```

![](</media/how-activerecord-builds-query/2b0e596025ed5dd603b743af3e094f63.png>)

Để tạo ra được query fragment trên, sẽ cần một subtree với 3 node. `left` là node chứa thông tin của column trong khi `right` đóng vai trò là query placeholder. Chúng tạo thành hai vế của một câu điều kiện. Câu điều kiện đó thuộc loại nào sẽ được xác định bởi node cha, ở đây là `Arel::Nodes::Equality` đại diện là dấu `=`. Các subtree cũng sẽ được kết hợp với nhau theo cách tương tự.

## Query structure

Bây giờ là lúc nhìn vào bức tranh tổng thể để biết cách một câu query hoàn chỉnh được tạo ra. Hãy cùng xem ví dụ sau:

```ruby
User.where(id: 1)
```
```sql
SELECT `users`.* FROM `users` WHERE `users`.`id` = 1
```

Và đây là AST tương ứng với câu query trên:

![Screen Shot 2023-08-19 at 16.34.10.png](</media/how-activerecord-builds-query/a2b68cce3fdf350adcd03ca827feb9e1.png>)

Tất cả các AST đều có cấu trúc tưng tự như trên và nó sẽ bao gồm hai phần chính:

- `Select`:  Là nơi chứa các thông tin liên quan đến select, joins, group, limit, having…
- `Where`: Bao gồm các `predicates`, chúng tạo thành các biểu thức điều kiện sau đó sẽ được kết hợp với các thông tin trong `binds` để inject values vào query placeholders.

Với các câu query phức tạp, AST cũng trở nên phức tạp hơn nhưng về cấu trúc, nó không có gì khác biệt. Chúng ta hãy cùng xem các ví dụ khác để có cái nhìn chi tiết hơn.

### Sử dụng điều kiện `or`

```ruby
User.where(id: 1).or(User.where(id: 2))
```
```sql
SELECT `users`.* FROM `users` WHERE (`users`.`id` = 1 OR `users`.`id` = 2)
```

![Screen_Shot_2023-08-19_at_17.14.43.png](</media/how-activerecord-builds-query/021034934bf0a6f35f21bb63274fde55.png>)

### Sử dụng `group`, `limit` và `having`

```ruby
User.where(id: 1).group(:name).having("sign_in_count > 100").limit(10)
```
```sql
SELECT  `users`.* FROM `users` WHERE `users`.`id` = 1 GROUP BY `users`.`name` HAVING (sign_in_count > 100) LIMIT 10
```

![](</media/how-activerecord-builds-query/2f2b7496be83476e42eb7fabc4baa125.png>)

### Sử dụng điều kiện trong `joins`

```ruby
UserCorporation.joins(:corporation).where(
  user_corporations: {
    id: 1
  },
  corporations: {
    id: 2
  }
)
```
```sql
SELECT `user_corporations`.* FROM `user_corporations` INNER JOIN `corporations` ON `corporations`.`id` = `user_corporations`.`corporation_id` WHERE `user_corporations`.`id` = 1 AND `corporations`.`id` = '2'
```

![](</media/how-activerecord-builds-query/5940cc6e7860978bb7ddc02faf0caa98.png>)

ActiveRecord sẽ duyệt tree theo chiều từ dưới lên trên cho đến khi có được một câu query hoàn chỉnh. Chi tiết về các node các bạn có thể tham khảo thêm ở [đây](https://github.com/rails/rails/tree/main/activerecord/lib/arel/nodes).

## Conclusion

Vừa rồi chúng ta đã cùng nhau đi tìm hiểu cấu trúc của một AST và cách mà ActiveRecord tạo nên các câu query. Hi vọng nó sẽ mang đến cho bạn cái nhìn chi tiết để từ đó giúp bạn viết và tối ưu query sử dụng ActiveRecord tốt hơn.
