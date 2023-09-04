---
layout: post
title: Custom Ransack Matcher
category: Rails
tags: ActiveRecord Ransack
excerpt_separator: <!--more-->
---

Ransack hay ActiveRecord sử dụng abstract syntax tree (AST) để compose query thay vì build query trực tiếp. AST sẽ bao gồm các node (`Arel::Nodes::Node`) chứa thông tin để tạo thành từng SQL fragment. Mỗi node được tạo nên bởi hai thành phần chính là `attribute` và `predicate`. Hiểu được điều này, chúng ta có thể chuyển hầu hết các case sử dụng query thuần sang AST thông qua việc định nghĩa các node tương ứng.
<!--more-->

## Ransack matcher

Để hiểu hơn về cách mà ransack hoạt động, chúng ta sẽ phân tích các thành phần trong một matcher thông qua ví dụ sau:

```ruby
User.ransack(first_name_cont_any: "Rya").result.to_sql

# SELECT "users".* FROM "users"  WHERE ("users"."first_name" LIKE '%Rya%')
```

Ở đây matcher là `first_name_cout_any` trong đó:

- `first_name`: là attribute, hay là column trong table
- `cont`: là predicate, xác định condition sẽ được sử dụng
- `any`: là biến thể của predicate. Phần này là optional, tuỳ thuộc predicate có hỗ trợ hay không.

Ransack sẽ parse matcher thành các phần như ở trên, sau đó sẽ tạo node tương ứng trong AST. Vì vậy, nếu muốn thêm một custom matcher, ta sẽ cần define đầy đủ các thành phần của nó.

## Custom ransacker

Thực tế, không phải lúc nào yêu cầu cũng chỉ là search theo một attribute như trong ví dụ trên. Trường hợp cần kết hợp nhiều attributes khác nhau trong một điều kiện search, đó sẽ là lúc ransacker được sử dụng. Hãy cùng xem ví dụ sau:

```ruby
User.where("CONCAT_WS('', first_name, last_name) LIKE '%Rya%'").to_sql

# SELECT "users".* FROM "users" WHERE (CONCAT_WS('', first_name, last_name) LIKE '%Rya%')
```

Nếu muốn sử dụng ransack trong trường hợp này, ta cần định nghĩa một `ransacker` trong model `User`:

```ruby
ransacker :full_name do
  Arel.sql("CONCAT_WS(' ', first_name, last_name)")
end
```

Sau đó, có thể kết hợp ransacker ở trên với các predicates mặc định để search như bình thường:

```ruby
User.ransack(full_name_cont: "Rya").result.to_sql

# SELECT "users".* FROM "users" WHERE (CONCAT_WS(' ', first_name, last_name) LIKE '%Rya%')
```

```ruby
User.ransack(full_name_matches: "Rya").result.to_sql

# SELECT "users".* FROM "users" WHERE (CONCAT_WS(' ', first_name, last_name) LIKE 'Rya')
```

Như vậy, ransacker ở đây chính là cách chúng ta định nghĩa `attrbiute` của một Ransack matcher.

## Custom predicate

Ở trên, chúng ta vừa sử dụng ransacker để định nghĩa thành phần attribute trong một Ransack matcher. Trong trường hợp muốn tạo một custom predicate, bạn cần phải thực hiện các bước sau:

### Thêm một predicate mới

Để thêm một predicate mới, ta có thể thêm method vào module `Arel::Predications`:

```ruby
module Arel
  module Predications
    def prefix_admin other
      self.eq("[admin] #{other}")
    end
  end
end
```

Ở trên, chúng ta vừa thêm predicate `prefix_admin` có chức năng tự động thêm `[admin]` vào phía trước search value (`other`). Nghĩa là, nếu bạn nhập `Rya` thì search value thực tế sẽ là `[admin] Rya`. Mỗi một predicate sẽ cần phải trả về một `Arel::Nodes::Node`, chi tiết các node và cách sử dụng bạn có thể xem ở [đây](https://github.com/rails/rails/tree/main/activerecord/lib/arel/nodes).

### Khai báo predicate với Ransack

Trước khi có thể sử dụng, predicate cần phải được khai báo với Ransack. Tại đây bạn cũng có thể thêm các config khác liên quan đến format hay validate:

```ruby
Ransack.configure do |config|
  config.add_predicate("perfix_admin",
    arel_predicate: "perfix_admin",
    formatter: proc {|v| v.titleize},
    validator: proc {|v| v.present?},
    compounds: false
  )
end
```

Trường hợp muốn sử dụng các predicates mặc định, bạn chỉ cần khai báo với Ransack predicate cần dùng:

```ruby
Ransack.configure do |config|
  config.add_predicate("upcase",
    arel_predicate: "matches",
    formatter: proc {|v| v.upcase},
    validator: proc {|v| v.present?}
  )
end
```

Chi tiết các predicates mặc định bạn có thể tham khảo ở [đây](https://github.com/rails/rails/blob/main/activerecord/lib/arel/predications.rb).

### Sử dụng custom predicate

Bây giờ ta có thể sử dụng predicate vừa tạo kết hợp với các attributes mặc định hoặc với ransacker vừa định nghĩa ở trên:

```ruby
User.ransack(first_name_prefix_admin: "Rya").result.to_sql

# SELECT "users".* FROM "users" WHERE "users"."first_name" = '[admin] Rya'
```

```ruby
User.ransack(full_name_prefix_admin: "Rya").result.to_sql

# SELECT "users".* FROM "users" WHERE (CONCAT_WS(' ', first_name, last_name) = '[admin] Rya')
```

```ruby
User.ransack(first_name_upcase: "rya").result.to_sql

# SELECT "users".* FROM "users" WHERE "users"."first_name" LIKE 'RYA'
```

## Custom predicate compouds

Mặc định option `compounds` khi định nghĩa predicate là `true`. Nghĩa là bạn có thể sử dụng predicate kết hợp với biến thể như `all`, `any`. Việc cần làm là thêm predicate của các biến thể tương ứng. Dưới đây là ví dụ:

```ruby
module Arel
  module Predications
    def concat others
      self.in(others.flatten)
    end

    def concat_any others
      self.in_any(others.flatten)
    end

    def concat_all others
      self.in_all(others.flatten)
    end
  end
end
```

Ở trên chúng ta thêm predicate `concat` và các biến thể `concat_any`, `concat_all` của nó.

Tiếp theo chúng ta sẽ khai báo predicate này với Ransack.

```ruby
Ransack.configure do |config|
  config.add_predicate("concat",
    arel_predicate: "concat",
    formatter: proc {|v| v.split(",").map(&:strip)},
    validator: proc {|v| v.present?},
    compounds: true,
    type: :string
  )
end
```

Ở phần `formatter` ta biến đổi search value từ một chuỗi thành một mảng. Và bây giờ ta có thể search theo các cách sau:

```ruby
User.ransack(id_concat: "1,2").result.to_sql

# SELECT "users".* FROM "users" WHERE "users"."id" IN (1, 2)
```

```ruby
User.ransack(id_concat_any: "1,2").result.to_sql

# SELECT "users".* FROM "users" WHERE ("users"."id" IN (1) OR "users"."id" IN (2))
```

```ruby
User.ransack(id_concat_all: "1,2").result.to_sql

# SELECT "users".* FROM "users" WHERE ("users"."id" IN (1) AND "users"."id" IN (2))
```

## Conclusion

Vừa rồi chúng ta đã cùng nhau tìm hiểu về cách màn Ransack hoạt động cũng như việc custom các thành phần của nó. Hi vọng bài viết sẽ hữu ích và có thể giúp bạn phần nào trong việc giải quyết các vấn đề lên quan đến chức năng search hay query trong Rails.
