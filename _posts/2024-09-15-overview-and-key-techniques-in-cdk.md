---
layout: post
title: Overview And Key Techniques In CDK
category: Infrastructure
tags: AWS CDK
excerpt_separator: <!--more-->
---
AWS Cloud Development Kit (CDK) là một framework mạnh mẽ cho phép sử dụng ngôn ngữ lập trình thông dụng như TypeScript, Python, Go... để định nghĩa và triển khai hạ tầng trên AWS. CDK giúp chúng ta dễ dàng quản lý resources bằng cách chuyển đổi từ mã nguồn sang mô hình hạ tầng dưới dạng CloudFormation. Để tìm hiểu kỹ hơn về CDK bạn có thể đọc qua bài viết **[IaC With AWS CDK](/iac-with-aws-cdk.html){:target="_blank"}**. Dưới đây là tổng hợp các khía cạnh quan trọng khác mà bạn cần nắm vững để sử dụng CDK một cách hiệu quả.

## Phases

CDK hoạt động theo ba phase chính: `synth time`, `deploy time`, và `runtime`. Mỗi phase có vai trò khác nhau trong việc xây dựng và quản lý hạ tầng trên AWS.

**Synth Time**

Ở giai đoạn này, CDK tổng hợp (synthesize) mã nguồn của bạn thành một tập hợp các tệp JSON dưới dạng CloudFormation Template. Không có resource nào được tạo trong giai đoạn này, nó chỉ đơn thuần là việc tạo ra mô tả hạ tầng. Khi bạn chạy lệnh `cdk synth`, CDK sẽ tạo ra template CloudFormation mô tả toàn bộ hạ tầng của bạn.

**Deploy Time**

Đây là giai đoạn triển khai (deploy) thực sự. Các template CloudFormation được gửi lên AWS và triển khai resources theo mô tả trong template. Lệnh `cdk deploy` sẽ triển khai các thay đổi của bạn lên tài khoản AWS. Trong quá trình này, AWS sẽ tạo, cập nhật hoặc xóa resource.

**Runtime**

Đây là giai đoạn khi các resource của bạn đang hoạt động trên AWS sau khi đã được triển khai. Các dịch vụ như Lambda, EC2, S3 sẽ hoạt động theo logic đã định nghĩa và bạn có thể bắt đầu tương tác với chúng.

## Resources

Mỗi resource trong AWS được định nghĩa thông qua `Construct`. Tập hợp nhiều constructs tạo nên một `Stack`.

- Ví dụ về construct:

```js
new s3.Bucket(this, 's3-bucket', {
  versioned: false,
  autoDeleteObjects: true,
  removalPolicy: cdk.RemovalPolicy.RETAIN,
});
```

- Ví dụ về stack:

```js
import * as cdk from 'aws-cdk-lib';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as iam from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';

interface S3Props extends cdk.StackProps {
  allowPolicies: Array<iam.Policy>;
}

export class S3Stack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: S3Props) {
    super(scope, id, props);

    const bucket = new s3.Bucket(this, 's3-bucket', {
      versioned: false,
      autoDeleteObjects: true,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
    });

    props.allowPolicies.forEach((policy) => {
      bucket.grantReadWrite(policy);
    });
  }
}
```

Bất cứ resource nào trong CDK sẽ luôn được xác định dựa vào `scope` và `ID`. Trong một scope không được phép xuất hiện 2 resources có cùng ID. Khi thay đổi scope hoặc ID của một resource, CDK sẽ xoá resource cũ và replace nó bằng một resource mới. Vì vậy với những resource như S3, RDS, Elasticache... việc thay đổi trên có thể làm mất dữ liệu. Do đó bạn cần quản lý chúng thông qua `removalPolicy` một cách cẩn thận.

## Stack References

Trong một project CDK, bạn cần nhóm những resources có liên quan vào trong một stack, điều này giúp bạn quản lý resources tốt hơn. Lý tưởng nhất là khi các stacks hoạt động độc lập, sự thay đổi trong stack này không ảnh hưởng đến các stacks khác.

Việc có quá nhiều resources trong một stack sẽ phát sinh vấn đề khi deploy. Nếu có bất kỳ lỗi nào xảy ra trong quá trình này thì toàn bộ stack sẽ bị rollback. Đôi khi điều này sẽ làm tốn khá nhiều thời gian của bạn. Nhưng nếu thiết kế một stack có ít resources hơn thì bạn sẽ cần tạo ra nhiều stacks hơn, các stacks cũng sẽ ràng buộc với nhau phức tạp hơn.

Vì vậy việc thiết kế stack là rất quan trọng. Trong trường hợp không tránh khỏi việc ràng buộc giữa các stacks, bạn có thể sử dụng những cách dưới đây để truyền thông tin giữa chúng.

**Sử dụng Properties**

Đây là cách đơn giản nhất, bạn chỉ cần truyền properties từ stack này sang stack kia thông qua stack props:

```js
const vpcStack = new VpcStack(scope, 'vpc-stack', {
  env: props.env
});

const webStack = new WebStack(scope, 'web-stack', {
  env: props.env,
  vpc: vpcStack.vpc,
});

new S3Stack(scope, 's3-stack', {
  env: props.env,
  allowPolicies: [webStack.policy]
});
```

Trong ví dụ trên `web-stack` nhận vào `vpc` được tạo từ `vpc-stack`. Policy được tạo ra trong `web-stack` sau đó được truyền vào `s3-stack` để thực hiện grant bucket cho policy này.

**cdk.CfnOutput và cdk.Fn.importValue**

Bạn có thể sử dụng `cdk.CfnOutput` để export thông tin trong một stack. Các stack khác có thể sử dụng `cdk.Fn.importValue` để import những thông tin cần thiết. Quay lại ví dụ trên, ở `vpc-stack` sẽ thực hiện export `vpcId` :

```js
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import { Construct } from 'constructs';

export class VpcStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: cdk.StackProps) {
    super(scope, id, props);

    const vpc = new ec2.Vpc(this, 'main-vpc');

    new cdk.CfnOutput(this, 'mainVpcId', {
      value: vpc.vpcId,
      exportName: 'mainVpcId',
    });
  }
}
```

`web-stack` sẽ import giá trị này vào để sử dụng:

```js
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import { Construct } from 'constructs';

export class WebStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: cdk.StackProps) {
    super(scope, id, props);

    const vpcId = cdk.Fn.importValue('mainVpcId');

    const vpc = ec2.Vpc.fromVpcAttributes(this, 'vpc', {
      availabilityZones: ['ap-northeast-1a', 'ap-northeast-1c'],
      vpcId: vpcId,
    });
  }
}
```

Với cách này, việc chia sẻ thông tin giữa các stack trở nên linh hoạt hơn, bạn không cần phải truyền trực tiếp thông tin từ stack này sang stack kia. Tuy nhiên nó không giải quyết được vấn đề ràng buộc giữa các stack. Nếu không quản lý tốt, bạn có thể gặp phải tình huống hai stacks bị phụ thuộc vào tham số export từ stack còn lại dẫn đến việc lock lẫn nhau. Bạn sẽ không thể thực hiện update hay delete một trong hai stack.

**Sử dụng SSM Parameter Store**

SSM Parameter Store được sử dụng để lưu trữ các tham số, như các thông tin cấu hình, secret key. Chúng có thể được truy xuất bằng API hoặc SDK từ các dịch vụ AWS hay các ứng dụng khác. Bạn cũng có thể dùng nó để chia sẻ thông tin giữa các stack nằm trong các dự án cdk khác nhau. Với SSM chúng ta sẽ viết lại `vpc-stack` như sau:

```js
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ssm from 'aws-cdk-lib/aws-ssm';
import { Construct } from 'constructs';

export class VpcStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: cdk.StackProps) {
    super(scope, id, props);

    const vpc = new ec2.Vpc(this, 'main-vpc');

    new ssm.StringParameter(this, 'main-vpc-id', {
      parameterName: '/main-vpc/id',
      stringValue: vpc.vpcId,
    });
  }
}
```

Tương tự, `web-stack` sẽ lockup parameter `main-vpc-id` để sử dụng:

```js
import * as cdk from 'aws-cdk-lib';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ssm from 'aws-cdk-lib/aws-ssm';
import { Construct } from 'constructs';

export class WebStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: cdk.StackProps) {
    super(scope, id, props);

    const vpcId = ssm.StringParameter.valueFromLookup(this, '/main-vpc/id');
    const vpc = ec2.Vpc.fromLookup(this, 'vpc', { vpcId });
  }
}
```

Như vậy `web-stack` không còn phụ thuộc vào `vpc-stack` nữa, nó sẽ chỉ phụ thuộc vào parameter store. Cách làm này thích hợp khi có nhiều dự án cùng sử dụng chung một resource ví dụ như RDS, ALB… Lúc này bạn có thể lưu thông tin như ID, ARN của các resources này lên store, dự án khác muốn dùng chỉ cần lookup các thông tin cần thiết để import vào.

## Conclusion

Sử dụng AWS CDK đòi hỏi sự hiểu biết về các phase hoạt động cũng như cách quản lý resource thông qua stack và chia sẻ thông tin giữa các stack với nhau. Bằng cách nắm vững các kỹ thuật này bạn sẽ có thể xây dựng và quản lý hạ tầng trên AWS một cách hiệu quả và tối ưu hơn.
