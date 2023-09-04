---
layout: post
title: Chat With Documents
category: AI
tags: LangChain LLMs
excerpt_separator:
---
Khi cần tìm thông tin liên quan đến một tài liệu, bạn sẽ cần nhiều thời gian để đọc và hiểu nội dung của tài liệu đó. Sẽ thật tốt nếu như có một chatbot giúp bạn. Bạn chỉ cần đưa tài liệu cho chatbot, sau đó có thể hỏi nó bất kỳ điều gì. Điều này là hoàn có thể và bạn cũng không cần lo dữ liệu sẽ bị lộ ra bên ngoài vì chatbot sẽ chạy hoàn toàn dưới local. Và đặc biệt, bạn không cần phải code một dòng nào.
<!--more-->

## Ollama

Để thao tác với AI model, bạn cần cài đặt Ollama. Đây là một công cụ AI được thiết kế để giúp bạn chạy các model LLMs dưới local. Hỗ trợ đa nền tảng từ MacOS, Windows cho đến Linux. Nó cho phép bạn khai thác sức mạnh của AI mà không cần phụ thuộc vào các nhà cung cấp bên ngoài như OpenAI, Google...

![alt text](/media/chat-with-documents/0827de42a1aed9a1c3170da47ddaea93.png)

Ollama cung cấp APIs để bạn tương tác với LLMs một cách dễ dàng. Bạn có thể tải và cài đặt Ollama tại [đây](https://ollama.com/download). Ollama cũng có sẵn nhiều model miễn phí để bạn lựa chọn, phù hợp với từng mục đích. Bạn có thể tìm kiểm các model tại [đây](https://ollama.com/library). Với trải nghiệm thực tế, khi sử dụng model `mistral` hoặc `llama2` thông thường sẽ cho kết quả tốt hơn. Bây giờ bạn có thể chạy và tương tác với model như sau:

```
ollama run mistral
```

Ở lần chạy đầu tiên, Ollama sẽ cần tải model về máy tính của bạn, điều này có thể mất một chút thời gian. Sau khi tải thành công, bạn sẽ được chuyển tới cửa sổ dòng lệnh và có thể chat với model:

![alt text](/media/chat-with-documents/c69e43e4a0381c591773db3b77c3998b.png)

Vậy là bạn đã có riêng cho mình một chatbot chạy ngay dưới local. Nhưng với mục tiêu ban đầu là có thể chat với các tài liệu, bạn sẽ cần thêm một ứng dụng khác kết nối với APIs của Ollama đồng thời cung cấp chức năng lưu trữ và xử lý file. Có rất nhiều lựa chọn dành cho bạn, phổ biến nhất là [privateGPT](https://www.privategpt.io/), nhưng có một ứng dụng khác với nhiều tuỳ chọn hơn đó chính là [AnythingLLM](https://useanything.com/).

## AnythingLLM

AnythingLLM là một ứng dụng open source giúp bạn trò chuyện với bất kỳ tài liệu nào. Bạn có thể kết nối với model của các nhà cung cấp bên ngoài, hoặc có thể kết hợp với Ollama.

![alt text](/media/chat-with-documents/da662255376032c2d2f32344c7706449.png)

AnythingLLM sử dụng LangChain để xử lý documents. Trải qua nhiều bước, nội dung chính của documents sẽ được chuyển sang dạng vector và được lưu trong Vectorstore. Sau đó bạn có thể chat với documents thông qua Retrieval. Chi tiết về quá trình này bạn có thể xem ở [đây](/langchain.html#retrieval).

* Clone AnythingLLM về máy:

```
git clone https://github.com/Mintplex-Labs/anything-llm anything-llm
```

* Setup ứng dụng:

```
cd anything-llm

yarn setup
```

Đảm bảo rằng bạn đã cài đặt `yarn` trên máy của mình.

* Run back-end server:

```
yarn dev:server
```

* Run front-end server:

```
yarn dev:frontend
```

* Run collector:

```
yarn dev:collector
```

Sau các bước trên hãy vào trình duyệt và đi tới `http://localhost:3000`, nếu thấy giao diện của AnythingLLM thì bạn đã cài đặt thành công.

![alt text](/media/chat-with-documents/f7af78f1ea7ca5a8c4707cc5cb1f2012.png)

## Chat with documents

Sau khi cài đặt thành công Ollama và AnythingLLM, giờ là lúc kết hợp chúng lại với nhau. Trong ví dụ dưới đây, mình sẽ tạo file `my-profile.txt` chứa một số thông tin của bản thân như sau:

```
Hi, my name is Lam.
I am a web developer with 6 years of experience.
I am proficient in Ruby, PHP, and Javascript.
I started my programming career in late 2017.
Prior to that, I worked as a civil engineer for 2 years.
```

Sau đó sẽ cung cấp file này cho chatbot và hỏi nó một vài câu hỏi liên quan đến nội dung trên.

### Setup Model

Trên màn hình chính của AnythingLLM, bạn click vào button setting bên trái phía dưới màn hình. Sau đó chuyển đến tab **LLM Preference**, lựa chọn Ollama, nhập và lưu thông tin như dưới đây:

![alt text](/media/chat-with-documents/86fd7fb4ed224ffa156b222d22cfd63b.png)

Phần **Chat Model Selection** sẽ hiển thị những model mà Ollama đã tải về. Trong trường hợp này là model `mistral` vì chúng ta đã tải nó ở trên.

### Setup Embedding

Tiếp tục chuyển xuống tab **Embedding Preference** và lưu lại thông tin như bên dưới:

![alt text](/media/chat-with-documents/d89bf4407154f524febae68acc92e5e6.png)

### Create Chat

Quay về màn hình chính, click **New Workspace**, nhập tên cho workspace là **About Me**. Một cửa sổ chat sẽ hiện ra, click vào link **upload a document** để đi đến màn hình upload file:

![alt text](/media/chat-with-documents/5efc2298ac9a02c3252f0d73a437c504.png)

AnythingLLM hỗ trợ rất nhiều định dạng file khác nhau, bạn có thể sử dụng link trực tiếp từ các trang web. Sau khi upload file, ấn **Save and Embeded**. Và bây giờ là lúc xem thành quả:

![alt text](/media/chat-with-documents/ca6506d813a2c0864bc9a43538e12861.png)

Thật tuyệt, chatbot đã trả lời chính xác với nội dung mà mình cung cấp.

## Conclusion

Như vậy là chúng ta đã cùng nhau tạo được chatbot hỗ trợ chat với bất kỳ tài liệu nào mà không cần phụ thuộc vào các nhà cung cấp bên ngoài. Bạn có thể ứng dụng để xây dựng trợ lý ảo giúp giải đáp thắc mắc dựa trên những thông tin mà bạn cung cấp, cùng nhiều lợi ích khác nữa mà bạn có thể từ từ tìm hiểu và khai thác.
