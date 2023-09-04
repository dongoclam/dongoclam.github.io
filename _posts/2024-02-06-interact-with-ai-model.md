---
layout: post
title: Interact With LLMs
category: AI
tags: LLMs
excerpt_separator: <!--more-->
---
Với một người dùng bình thường, sẽ rất đơn giản để sử dụng AI của các bên thứ 3 như Chat-GPT, Google Gemini... nhưng đồng thời bạn sẽ phải cung cấp những thông tin quan trọng, đôi khi là nhạy cảm cho các ứng dụng đó. Lúc này hãy nghĩ đến việc tự xây dựng cho riêng mình một ứng dụng chat sử dụng AI. Để thực hiện điều này, bạn cần học cách sử dụng những model LLMs và đó cũng là nội dung chính ngày hôm nay chúng ta sẽ tìm hiểu.
<!--more-->

![image](</media/interact-with-ai-model/c842557b87652dc2f26016d3c0ef5246.png>)

## What you need?

Đầu tiên, LLM là viết tắt của **Large Language Model**, đây là một loại mô hình trí tuệ nhân tạo (AI) được đào tạo trên một lượng dữ liệu khổng lồ gồm văn bản và mã code. Nó có thể thực hiện nhiều tác vụ liên quan đến ngôn ngữ tự nhiên. Về cơ bản, để xây dựng được một ứng dụng chat sử dụng AI bạn chỉ cần một LLM model và các thư viện để thao tác với model đó.

### Models

Hugging Face là một trang web cung cấp các dịch vụ lưu trữ và thư viện hỗ trợ liên quan đến LLMs. Bạn có thể tìm kiếm model phù hợp với mục đích sử dụng của mình tại [đây](https://huggingface.co/models).

Có rất nhiều model miễn phí mà bạn có thể lựa chọn. Tuy nhiên, một trong những model phổ biến liên quan đến LLM chính là LLaMa-2. Đây là một open source model được pretrained bởi Meta nên bạn hoàn toàn có thể yên tâm về độ tin cậy cũng nhưng cộng đồng hỗ trợ nó.

### Libraries

Để thao tác với một model, bạn sẽ cần một thư viện phù hợp. Với HuggingFace model bạn có thể sử dụng [Transformers](https://github.com/huggingface/transformers). Đây là một thư viện open source hỗ trợ các model với format dạng `bin` hay `safetensors`.

Khác với Transformers, [**llama.cpp**](https://github.com/ggerganov/llama.cpp) là thư viện dành riêng cho các model LLaMA. Nó hỗ trợ các model có format dạng `GGML` và `GGUF`. Đây là định dạng với kỹ thuật tối ưu hoá model giúp giảm dung lượng và tăng tốc độ tính toán. Bạn cũng có thể sử dụng [**llama-cpp-python**](https://github.com/abetlen/llama-cpp-python) nếu không phải là người thành thạo C++.

## Setting up Python

Trong bài viết này chúng ta sẽ sử dụng Python trên MacOS, vì vậy cách cài đặt ở các hệ điều hành khác có thể sẽ khác biệt nhưng bạn cũng có thể dễ dàng cài đặt theo hướng dẫn ở [đây](https://www.python.org/downloads/).

- Cài đặt pyenv

```bash
brew install pyenv
```

- Cài đặt python qua pyenv

```bash
pyenv install python 3.8
```

- Set version python mặc định

```bash
pyenv global 3.8
```

- Cài đặt pip

```bash
python -m pip install --upgrade pip
```

## Interact with model

Bạn có thể tìm kiếm và download model từ Hugging Face:

![image](</media/interact-with-ai-model/bdd984e39ed853b4268782c96e2aebc1.png>)

Nếu để ý, bạn sẽ thấy sau tên của mỗi model sẽ thường đi cùng các thông số 3b, 7b hay 70b. Đây chính là kích thước hay số lượng tham số của model đó. Hiểu đơn giản, một model có số lượng tham số càng lớn sẽ càng thông minh nhưng đổi lại dung lượng của nó sẽ càng lớn. Với máy tính cá nhân, bạn nên lựa chọn các model với 7b hoặc 13b tham số.

Tại thư mục gốc, bạn tạo folders `ai/models/` để lưu những models đã được download:

```bash
mkdir -p ai/models
```

Setup môi trường:

```bash
cd ai/

python -m venv .env

source .env/bin/activate
```

Sau đó bạn có thể download model như sau:

```bash
git lfs install

git clone git@hf.co:bigcode/starcoderbase-3b
```

### Transfomers

Với những HuggingFace models, bạn cần cài đặt Transformers cùng các thư viện liên quan khác:

```bash
pip install transformers

pip install tensorflow

pip install torch
```

Bây giờ bạn có thể sử dụng Transformers theo hướng dẫn:

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

tokenizer = AutoTokenizer.from_pretrained("models/starcoderbase-3b", local_files_only=True)
model = AutoModelForCausalLM.from_pretrained("models/starcoderbase-3b", local_files_only=True)

inputs = tokenizer.encode("Today is: ", return_tensors="pt")
outputs = model.generate(inputs)

print(tokenizer.decode(outputs[0]))
```

### llama.cpp

Khi sử dụng các model với các định dạng được hỗ trợ bởi Transformers thường khá nặng, máy tính của bạn dễ có thể bị treo trong quá trình xử lý. Nếu bạn không có GPU đủ mạnh và dung lượng RAM dưới 16G, thì bạn nên sử dụng các model có định dạng `.gguf`. Bạn có thể tải model Llama-2 với định dạng này tại [đây](https://huggingface.co/TheBloke/Llama-2-7B-Chat-GGUF/blob/main/llama-2-7b-chat.Q2_K.gguf).
Để thao tác với model, bạn cần cài đặt `llama-cpp-python`:

```bash
pip install llama-cpp-python
```

Sau đó bạn có thể trải nghiệm:

```python
from llama_cpp import Llama

output = llm("Q: Name the planets in the solar system? A: ", max_tokens=32, stop=["Q:", "\n"], echo=True)

print(output['choices'][0]['text'])
```

Bạn sẽ nhận được kết quả:

```python
Q: Name the planets in the solar system? A: 1. styczni 2019, 16:54 utc, rys. The inner Solar System includes Mercury, Ven
```

## Conclusion

Như vậy là chúng ta đã có thể thao tác được với một LLM model. Đến đây, nếu biết lập trình, bạn hoàn toàn có thể dựng một server và tạo các APIs để xây dụng một chat bot hoàn chỉnh. Nhưng nếu bạn không phải là dân IT thì điều đó cũng không thành vấn đề vấn đề. Hiện nay đã có rất nhiều framework hỗ trợ bạn thực hiện viêc đó mà thậm chí bạn không cần phải viết một dòng code nào.
