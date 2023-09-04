---
layout: post
title: Some Patterns You Should Know
category: Clean Code
tag: DesignPattern
excerpt_separator: <!--more-->
---
Khi xây dựng một ứng dụng web, bạn sẽ thường sử dụng framework hay libraries hỗ trợ. Mặc dù bản thân chúng đã có cấu trúc và các rules rõ ràng nhưng trong nhiều bạn vẫn không biết nên viết code ở đâu để có thể tái sử dụng hay để dễ dàng maintain sau này. Vì vậy, dưới đây sẽ là một số design patterns phổ biến mà bạn nên biết.
<!--more-->

![image](</media/some-patterns-you-should-know/6f91032091d3af4dcf9ef6e8422bf826.png>)

## Service Object

Trong mô hình MVC, controller là trung gian giao tiếp giữa model và view. Vì vậy bản thân nó sẽ chứa nhiều logic, tuy nhiên chúng ta chỉ nên để controller chỉ nên làm đúng nhiệm vụ của nó là giao tiếp còn những logic khác nên được tách ra một service:

```ruby
class UsersController
  def create
    user = User.new(user_params)

    if user.save
      UserMailer.verify_email(user)

      render json: {
        status: :success,
        user: user.as_json,
      }
    else
      render json: {
        status: :error,
        errors: user.error.messages
      }
    end
  end
end
```

Khi sử dụng service:

```ruby
class CreateUserService
  def initialize user_params
    @user = User.new(user_params)
  end

  def execute
    if user.save
      send_verify_email

      {
        status: :success,
        user: user.as_json,
      }
    else
      {
        status: :error,
        errors: user.errors.messages,
      }
    end
  end

  private

  attr_reader :user

  def send_verify_email
    UserMailer.verify_email(user)
  end
end
```

```ruby
class UsersController
  def create
    render json: CreateUserService.new(user_params).execute
  end
end
```

## ServiceResponse

Trong một dự án có thể sẽ có rất nhiều service, mỗi service lại trả về các kết quả với những format khác nhau. Đó là lúc bạn nên sử dụng `ServiceResponse` để thống nhất dữ liệu trả về của các service. Viết lại ví dụ ở trên với service response:

```ruby
class ServiceResponse
  def self.success(message: nil, payload: {})
    {
      status: :success,
      message: message,
      payload: payload,
    }
  end

  def self.error(message: nil, payload: {})
    {
      status: :error,
      message: message,
      payload: payload,
    }
  end
end
```

```ruby
class CreateUserService
  def initialize user_params
    @user = User.new(user_params)
  end

  def execute
    return error_creating unlees user.save

    send_verify_email
    success
  end

  private

  attr_reader :user

  def success
    ServiceResponse.success(payload: user.as_json}
  end

  def error_creating
    ServiceResponse.error(payload: user.errors.messages}
  end

  def send_verify_email
    UserMailer.verify_email(user)
  end
end
```

## Finder

Là nơi thao tác trực tiếp với ORM. Nó bao gồm các logic liên quan đến tìm kiếm, filter dữ liệu. Sử dụng finders là một giải pháp giúp hạn chế fat model, và dễ dàng tái sử dụng.

```ruby
class EmployeesController < ApplicationController
  def index
    @employess = current_user.employees
    @employess = @employees.in_in(params[:id]) if params[:id].present?
  end
end

class Admin::EmployeesController < Admin::BaseController
  def index
    @employess = current_admin.employees
    @employees = @employees.by_name(params[:name]) if params[:name].present?
    @employees = @employees.where(is_blocked: true) if params[:blocked].present?
  end
end
```

Khi sử dụng finder:

```ruby
class EmployeesFinder
  def initialize(manager, params)
    @manager = manager
    @params = params
  end

  def execute
    employees = manager.employees
    employees = filter_by_id(employees)
    employees = filter_by_name(employees)
    employees = filter_by_blocked(employees)
    order(employees)
  end

  private

  attr_reader :manager, :params

  def filter_by_id(employees)
    return employees if params[:id].blank?

    employees.ransack(id_in: params[:id]).result
  end

  def filter_by_name(employees)
    return employees if params[:name].blank?

    employees.ransack(name_cont: params[:name]).result
  end

  def filter_by_blocked(employees)
    return employees unless params[:blocked]

    employees.where(is_blocked: true)
  end

  def order(employees)
    return employees unless params[:sort]

    employees.ransack(sort: params[:sort]).result
  end
end
```

```ruby
class EmployeesController < ApplicationController
  def index
    @employess = EmployeesFinder.new(current_user, params).execute
  end
end

class Admin::EmployeesController < Admin::BaseController
  def index
    @employess = EmployeesFinder.new(current_admin, params).execute
  end
end
```

## Decorator

Khi muốn hiển thị các thông tin khác của một record, hoặc đơn giản là một format khác của một thông tin có sẵn ví dụ như các trường date time, bạn hoàn toàn có thể thêm một method vào trong model tương ứng. Tuy nhiên, điều này sẽ làm model của bạn ngày một phình to. Đây là lúc bạn nên sử dụng decorator.

```ruby
class User < ApplicationRecord
  def formatted_created_at
    created_at.strftime("YYYY/MM/DD")
  end
end
```

```erb
<div class="user">
  <p class="user-name"><%= @user.name %></p>
  <span class="user-created-at"><%= @user.formatted_created_at %></span>
</div>
```

Sau khi sử dụng decorator:

```ruby
class UserDecorator
  def formatted_created_at
    created_at.strftime("YYYY/MM/DD")
  end
end
```

```erb
<div class="user">
  <p class="user-name"><%= @user.name %></p>
  <span class="user-created-at"><%= @user.decorate.formatted_created_at %></span>
</div>
```

## Presenter

Khác với decorator, presenter được sử dụng để hạn chế logic trong controller hoặc ở ngoài view. Hãy cùng xem qua ví dụ sau đây:

```ruby
class PostsController < ApplicationController
  before_action :load_post, only: :show

  def show
    @related_posts = Post.related_posts_for(@post)
    @latest_comments = @post.comments.latest.limit(10)
  end

  def load_post
    @post = Post.find params[:id]
  end
end
```

Ở ngoài view:

```erb
<h1><%= @post.title %></h1>
<% if current_user == @post.author %>
  <button>Edit</button>
<% end %>
<p class="post-content"><%= @post.content %></p>
<div class="comments"><%= render @latest_comments %></div>
<%= render @related_posts %>
```

Với những controller chứa nhiều logic phức tạp, số lượng các biến instance variable được tạo ra sẽ càng nhiều. Nếu sử dụng chúng ở ngoài view lâu dần sẽ khó quản lý và phát triển sau này. Đó cũng là lúc bạn nên dụng presenter:

```ruby
class PostPresenter
  attr_reader :post, :current_user

  def initialize current_user, post
    @current_user = current_user
    @post = post
  end

  def related_posts
    Post.related_posts_for(post)
  end

  def latest_comments
    post.comments.latest.limit(10)
  end

  def can_edit?
    current_user == post.author
  end
end
```

```ruby
class PostsController < ApplicationController
  before_action :load_post, only: :show

  def show
    @presenter = PostPresenter.new(current_user, post)
  end

  def load_post
    @post = Post.find params[:id]
  end
end
```

```erb
<h1><%= @presenter.post.title %></h1>
<%= content_tag :button, "Edit" if @presenter.can_edit? %>
<p class="post-content"><%= @presenter.post.content %></p>
<div class="comments"><%= render @presenter.latest_comments %></div>
<%= render @presenter.related_posts %>
```

Như bạn thấy, số lượng instance variable đã giảm, logic ở controller và view cũng đã rõ ràng hơn rất nhiều.

## Serializer

Khác với presenter, serializer thường được sử dụng để build response cho API. Hãy cùng xem ví dụ sau để hiểu hơn về nó:

```ruby
class Api::PostsController < Api::BaseController
  before_action :load_post, only: :show

  def show
    render json: {
      posts: @post.as_json(
        only: [:id, :title, :content],
        include: {
          author: {
            only: [:id, :name],
            methods: [:age]
          },
          comments: {
            only: [:id, :content],
            author: {
              only: [:id, :name],
              methods: [:age]
            }
          }
        }
      )
    }
  end

  def load_post
    @post = Post.find params[:id]
  end
end
```

Các thư viện hỗ trợ serializer có thể kể đến như [jsonapi-serializer](https://github.com/jsonapi-serializer/jsonapi-serializer) và [active_model_serializers](https://github.com/rails-api/active_model_serializers). Mỗi thư viện đều có ưu và nhược điểm riêng, tuy hiên cách dùng không quá khác biệt. Ví dụ dưới đây sử dụng Active Model Serializer:

```ruby
class UserSerializer < ActiveModel::Serializer
  attributes :id, :name

  attribute :age do
    Time.zone.year - object.birthday.year
  end
end
```

```ruby
class CommentSerializer < ActiveModel::Serializer
  attributes :id, :content

  belongs_to :author, serializer: UserSerializer
end
```

```ruby
class PostSerializer < ActiveModel::Serializer
  attributes :id, :title, :content

  belongs_to :author, serializer: UserSerializer

  has_many :comments
end
```

```ruby
class Api::PostsController < Api::BaseController
  before_action :load_post, only: :show

  def show
    render json: @post, serializer: PostSerializer
  end

  def load_post
    @post = Post.find params[:id]
  end
end
```

Như bạn có thể thấy, sử dụng serializer giúp cho code trở nên rõ ràng hơn, tăng khả năng tái sử dụng và dễ dàng mở rộng.

## Conclusion

Vừa rồi là một số pattern thường được sử dụng trong lập trình web, lựa chọn đúng pattern giúp cho source code bạn rõ ràng thống nhất cũng như dễ dàng maintain và mở rộng sau này.
