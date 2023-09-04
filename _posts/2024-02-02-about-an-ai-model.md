---
layout: post
title: About an AI model
category: AI
tags: LLMs
excerpt_separator: <!--more-->
---
Trí tuệ nhân tạo hiện nay đang là một lĩnh vực rất phát triển và nhận được nhiều sự quan tâm. Sự ra đời của Chat-GPT cùng hàng loại các ứng dụng AI khác càng khiến nó được chú ý. Sử dụng AI đúng cách có thể giúp bạn nâng cao hiệu quả công việc trong hầu hết các lĩnh vực.
<!--more-->

![image](</media/about-an-ai-model/566bae69f8bfdb8764405eec8470bea3.png>)

## What is an AI model

AI model là một chương trình máy tính được thiết kế để mô phỏng trí thông minh con người. Nó là một tập hợp các thành phần quan trọng bao gồm kiến trúc, tham số và trọng số.

- **Tham số:** Các giá trị được điều chỉnh trong quá trình huấn luyện để tối ưu hóa hiệu suất của mô hình.
- **Kiến trúc:** Cấu trúc của mạng nơ-ron, xác định cách các tham số được kết nối với nhau.
- **Trọng số:** Giá trị của các kết nối giữa các nơ-ron.

Trải qua quá trình huấn luyện, model sau đó sẽ được lưu dưới dạng file với các định dạng thông dụng như `.gguf`, `.h5`, `.ckpt`, `.pb`, `.onnx`. Các format này sẽ phụ thuộc vào thư viện hay framework được chọn để thao tác với model.

## How It is trained?

Để huấn luyện model phải cần đến một tập dữ liệu lớn chứa đa dạng thông tin được phân loại, sàng lọc để phù hợp với mục tiêu ứng dụng. Quá trình này thường được thực hiện qua việc sử dụng các thuật toán tối ưu hóa để điều chỉnh trọng số của model.

Kích thước và chất lượng của tập dữ liệu quyết định độ chính xác của model. Mặt khác, kiến trúc sẽ yếu tố quan trọng nhất ảnh hưởng đến cách thức hoạt động và hiệu suất của model đó. Tuỳ vào mục đích sử dụng, mỗi loại model sẽ có một kiến trúc khác nhau.

- **ANN:** Là kiến trúc giản nhất, được sử dụng cho các nhiệm vụ phân loại và hồi quy.
- **CNN:** Được sử dụng cho các nhiệm vụ xử lý ảnh và video.
- **RNN:** Được sử dụng cho các nhiệm vụ xử lý ngôn ngữ tự nhiên.
- **Transformer:** Là kiến trúc mới nhất, được sử dụng cho nhiều nhiệm vụ khác nhau, bao gồm xử lý ngôn ngữ tự nhiên, dịch máy, và tạo văn bản. Thường thấy trong các mô hình ngôn ngữ LLM (Large Language Model).

Việc huấn luyện model đòi hỏi sức mạnh tính toán cao, thường sử dụng GPU hoặc TPU, được thực hiện trong một khoảng thời gian dài và tiêu tốn nhiều năng lượng. Chi phí cho việc xử lý tập dữ liệu cũng làm cho việc huấn luyện trở nên tốn kém. Vì vậy, nó thường được thực hiện bởi các công ty lớn như Meta, Google, OpenAI...

## How does It works?

Tuỳ thuộc vào kiến trúc, mỗi model sẽ có cách hoạt động khác nhau. Phổ biến nhất là các model LLM, chúng hoạt động bằng cách dựa vào số lượng kết nối khổng lồ trong mạng nơ-ron để đưa ra dự đoán từ nào sẽ xuất hiện tiếp theo với xác suất cao nhất trong một ngữ cảnh cụ thể. Tương tự như khi bạn gõ một từ nào đó trên thanh tìm kiếm, Google sẽ hiển gợi ý cho bạn từ tiếp theo dựa trên các thông tin đã nhập.

Các model CNN hướng tới việc xử lý dữ liệu dạng media (hình ảnh, video…) sẽ hoạt động bằng cách trích xuất các đặc trưng của đối tượng kết hợp với việc xử lý liên quan đến thời gian từ đó đưa ra dự đoán.

## Model parameters

Để tìm hiểu hay sử dụng một AI model, bạn sẽ cần biết đến các khái niệm cơ bản sau:

- **Token:** Là đơn vị nhỏ nhất đại diện cho dữ liệu ngôn ngữ. Thường là một từ hoặc một phần của một từ.
- **Prompt**: Là đầu vào cung cấp cho mô hình để tạo ra dự đoán. Có thể là một câu hoặc một đoạn văn. Prompt càng ngắn gọn rõ ràng, chứa đựng càng nhiều thông tin về ngữ cảnh sẽ càng tốt.
- **Context size:** Là số lượng token mà model có thể nhớ được. Hiểu đơn giản, đây là độ lớn của bộ nhớ tạm thời giúp model hiểu rõ hơn về ngữ cảnh. Thường được ký hiệu 4k, 8k… con số này càng lớn thì model sẽ dự đoán càng chính xác với ngữ cảnh hiện tại.
- **Model size:** Đây là kích thước của model, nó thể hiện số lượng tham số trong model. Thường được ký hiệu 3B, 7B, 70B… Một model có kích thước 70B nghĩa là nó có 70 tỷ tham số. Kích thước model càng lớn sẽ càng thông minh, có khả năng học được các đặc trưng phức tạp hơn, nhưng cũng đòi hỏi nhiều tài nguyên tính toán hơn.
- **Temperature:** Đây là thông số thường thấy trong các model LLM. Nó thể hiện sự ngẫu nhiên của quá trình sinh văn bản. Với giá trị càng lớn, model sẽ tạo ra văn bản ngẫu nhiên hơn có thể bao gồm cả những ý tưởng và từ ngữ đa dạng. Giá trị càng nhỏ thì văn bản tạo ra sẽ có tính chất đặc trưng và ít ngẫu nhiên hơn.

## Interact with model

Như đã nói ở trên, để tạo ra được một model sẽ đỏi hỏi một chi phí rất lớn. Nhưng may mắn là hiện nay có rất nhiều công ty, tổ chức cung cấp các nguồn tài nguyên đa dạng từ dữ liệu huấn luyện cho đến những model đã được huấn luyện sẵn. Bạn có thể tìm thấy nguồn tài nguyên này trên các kho lưu trữ phổ biến như Hugging Face, Model Hub hay TensorFlow Hub.

Để tương tác với một AI model, bạn sẽ cần đến các thư viện hoặc framework. Mỗi thời điểm bạn sẽ cần các thư viện khác nhau. Trong quá trình huấn luyện, các thư viện TensorFlow, PyTorch, và Keras được sử dụng phổ biến. Mặt khác, để sử dụng và khai thác sức mạnh của một model bạn sẽ cần đến các thư viện như Hugging Face Transformers, TensorFlow Serving, Llama.cpp… với các interface thuận tiện để tương tác với model.

## Conclusion

AI model chứa đựng rất nhiều công nghệ và kỹ thuật phức tạp. Dù không phải là chuyên gia trong lĩnh vực này, nhưng nếu bạn nắm được bản chất và các khải niệm cơ bản, bạn hoàn toàn có thể khai thác được sức mạnh của một AI model. Trong bài viết sau, chúng ta sẽ trực tiếp đi vào cài đặt và sử dụng một model LLM.
