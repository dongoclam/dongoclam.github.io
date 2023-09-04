---
layout: post
title: IaC With AWS CDK
category: Infrastructure
tags: AWS
excerpt_separator: <!--more-->
---

Các hệ thống được xây dựng trên Cloud ngày càng trở nên phức tạp. Thường xuyên thay đổi, mở rộng hệ thống để đáp ứng với những yêu cầu mới. Xây dựng, sửa đổi cấu trúc hệ thống bằng cách thao tác trên màn hình dần trở nên không hiệu quả với những hệ thống lớn. Có thể kể đến như việc không tái sử dụng được config dẫn đến việc không apply thay đổi đồng loạt nhiều môi trường. Không thể overview trước những thay đổi hay kiểm soát trạng thái của hệ thống. Infrastructure as Code sinh ra để giải quyết những vấn đề trên.
<!--more-->

## What's IaC

Infrastructure as Code là một phương pháp sử mã lập trình để xây dựng, triển khai các tài nguyên hệ thống một cách tự động. Khắc phục nhược điểm của phương pháp xây dựng thủ công, tránh sai sót và dễ dàng tái sử dụng. Bên cạnh đó IaC cho phép bạn quản lý phiên bản, kiểm soát sự thay đổi trong hệ thống.

Với nhiều công cụ hỗ trợ, bạn có thể sử dụng IaC để làm việc với nhiều Cloud Provider khác nhau mà không cần thay đổi mã code. Đây cũng là cách giúp lập trình viên tiếp cận với Infrastructure dễ dàng hơn vì họ có thể xây dựng một hệ thống bằng chính ngôn ngữ lập trình mà mình đang sử dụng.

Các công cụ trong IaC hướng tới những mục đích khác nhau, cách tiếp cận vì vậy cũng sẽ khác nhau. Tuy nhiên, đôi khi ranh giới giữa chúng không quá rõ ràng, nghĩa là một công cụ có thể làm được nhiều việc của những công cụ khác.

### Provisioning

Cung cấp sẵn các thành phần cơ bản, hướng đến việc xây dựng nền tảng cho hệ thống. Tự động hoá việc tạo các tài nguyên như máy chủ, storage, networking...

![alt text](/media/iac-with-aws-cdk/089410df96eb31410a7e9bbab6052c85.png)

Các công cụ thường được sử dụng là **Terraform**, **AWS CloudFormation**. Các công cụ này sử dụng **Declarative** để mô tả hệ thống. Với phương pháp này, bạn chỉ cần khai báo trạng thái cuối cùng mong muốn mà không cần quan tâm đến các bước thực hiện hay những thay đổi diễn ra trước đó. Mã code sẽ phản ánh chính xác thông tin về hệ thống hiện tại.

Ví dụ dưới đây sẽ tạo 5 instances ec2 với Terraform. Khi muốn thay đổi số lượng instances, bạn chỉ cần thay đổi thuộc tính count bằng số instances mong muốn:

```tf
provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  count         = 5
}
```

### Configuration Management

Tập trung vào việc cấu hình trên các tài nguyên đã tạo, thường được thực hiện sau provisioning. Bao gồm các công việc như cài đặt các gói phần mềm, cấu hình dịch vụ trên các máy chủ...

![alt text](/media/iac-with-aws-cdk/461ef49cd3d00e542ce2e42603dfb94c.png)

Các công cụ được sử dụng phổ biến là **Ansible** và **Chef**. Các công cụ này sử dụng phương pháp **Procedural** để khai báo tường bước thực hiện. Trạng thái cuối cùng sẽ là sự kết hợp của tất cả các bước trước đó. Trong mã code sẽ bao gồm cả lịch sử sửa đổi vì vậy bạn sẽ rất khó để xác định được trạng thái cuối cùng.

Với Ansible bạn cũng có thể tạo instances giống như đã làm với Terraform ở trên. Khi muốn thay đổi số lượng instances, bạn sẽ phải tạo thêm một task để add thêm số lượng instances còn thiếu:

```yml
- hosts: localhost
  connection: local
  gather_facts: False
  tasks:
    - name: Create 2 instances
      ec2:
        image: ami-0c55b159cbfafe1f0
        instance_type: t2.micro
        count: 2
      register: ec2_instances
    - name: Add more 3 instances
      ec2:
        image: ami-0c55b159cbfafe1f0
        instance_type: t2.micro
        count: 3
```


Ví dụ cài đặt và khởi chạy nginx với Ansible:

```yml
- hosts: web_servers
  tasks:
    - name: Install Apache
      become: yes
      apt:
        name: apache2
        state: present

    - name: Start Apache service
      become: yes
      service:
        name: apache2
        state: started
        enabled: yes
```

Và đây là bức tranh về cách Provisioning và Configuration Management hoạt động cùng nhau:

![alt text](/media/iac-with-aws-cdk/f66b171c95934b4fa2ff2d5c09155ce8.png)

## AWS CDK

AWS Cloud Development Kit là một công cụ cho phép bạn sử dụng các ngôn ngữ lập trình phổ biến như TypeScript, Python, Java để xây dựng và triển khai các tài nguyên AWS.

![alt text](/media/iac-with-aws-cdk/b3fa43af8e70066a2c7948972ec2cef9.png)

Được xây dụng trên AWS CloudFormation, CDK đã khắc phục những nhược điểm mà công cụ này gặp phải như cú pháp dài dòng, không tái sử dụng được code. CDK giúp bạn tận dụng những tính năng có sẵn trong ngôn ngữ lập trình, tăng tốc độ phát triển, cải thiện khả năng bảo trì, triển khai hệ thống một cách tự động và nhất quán.

CDK hoạt động bằng cách chuyển đổi mã code thành AWS CloudFormation template. Do đó, có thể coi đây là một công cụ nằm ở high level so với AWS CloudFormation.

### Concepts

Cấu trúc của CDK sẽ bao gồm các thành phần chính:

![alt text](/media/iac-with-aws-cdk/3f2c9645de658c09216a2ac12fd4dfdc.png)

#### Construct

Là cấu trúc cơ bản nhất, chứa một hoặc nhiều tài nguyên AWS. Construct đại diện cho một tài nguyên cụ thể hoặc một nhóm tài nguyên có tính chất tương tự nhau như construct cho EC2 instances, Lambda functions... Đây cũng là thành phần quan trọng nhất trong CDK và bạn sẽ làm việc nhiều với nó.

```ts
import { Construct } from 'constructs';
import * as s3 from 'aws-cdk-lib/aws-s3';

export class Bucket extends Construct {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    new s3.Bucket(this, 'bucket-1');
  }
}
```

#### Stack

Là tập hợp của nhiều constructs có liên quan đến nhau. Mỗi stack thường đại diện cho một phần của ứng dụng hoặc môi trường cụ thể trên AWS.

```ts
import * as cdk from 'aws-cdk-lib';

export class StorageStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    new Bucket(this, 'my-bucket');
  }
}
```

#### App

Đây là cấu trúc chính đại diện cho ứng dụng AWS của bạn. Chứa toàn bộ stacks và constructs, xác định cách tổ chức của các thành phần trong ứng dụng.

```ts
import * as cdk from 'aws-cdk-lib';

const app = new cdk.App();
new StorageStack(app, 'storage-stack');
```

### Construct Levels

Như bạn đã biết, construct là thành phần cơ bản và quan trong nhất trong CDK. Bạn có thể tự tạo construct phù hợp với từng mục đích dựa trên những constructs mà CDK cung cấp.

![alt text](/media/iac-with-aws-cdk/91566407fed73056ac26f6a3a8d97c9c.png)

Mỗi layer có mức độ đóng gói khác nhau. Mức độ đóng gói càng cao thì khả năng tuỳ biến sẽ càng thấp. Do vậy, trong thực tế, L2 Construct thường được sử dụng nhiều hơn.

#### L1 Construct

Đây chính xác là những tài nguyên được xác định bởi CloudFormation. Vì vậy cấu trúc L1 sẽ bao gồm các thành phần cơ bản nhất, tất cả các thông đều phải cài đặt thủ công. Hiểu đơn giản, đây chính là CloudFormation nhưng được viết bằng ngôn ngữ lập trình.

#### L2 Construct

Layer này sẽ đóng gói cấu trúc L1 với những cài đặt mặc định dựa trên best practice về bảo mật, tối ưu hoá tài nguyên. Cấu trúc L2 giúp bạn tạo tài nguyên một cách nhanh gọn, an toàn mà không cần biết nhiều về chúng trên AWS.Với những ưu điểm trên, L2 thường được sử dụng nhiều hơn trong thực tế.

#### L3 Construct

Đây là layer với mức độ đóng gói cao nhất, hay còn gọi là các patterns. L3 được thiết kế để giải quyết một bài toán cụ thể liên quan đến nhiều loại tài nguyên.

## Conclusion

Bài viết cung cấp cho bạn những kiến thức cơ bản về IaC. Đây là một cách tiếp cận mới khắc phục được những nhược điểm của các phương pháp thủ công thông thường. AWS CDK là một trong số những công cụ giúp bạn triển khai IaC một cách nhanh chóng và đáng tin cậy. Làm chủ được CDK sẽ là tiền để để bạn xây dựng thành công những hệ thống lớn và phức tạp hơn.
