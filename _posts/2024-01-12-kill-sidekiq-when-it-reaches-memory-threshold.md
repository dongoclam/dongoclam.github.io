---
layout: post
title: Kill Sidekiq When It Reaches Memory Threshold
category: Rails
tag: Sidekiq
excerpt_separator: <!--more-->
---
Như đã nói ở bài viết **[Sidekiq Memory Problem](/sidekiq-memory-problem.html)**, nếu như tất cả các giải pháp mà bạn sử dụng không thể giải quyết triệt để được vấn đề memory của Sidekiq thì việc restart lại Sidekiq có thể sẽ là phương án bạn nên thử. Thông thường, nếu sử dụng cloud services, hệ thống của bạn sẽ có cơ chế healthcheck, nó sẽ tự động kiểm tra và restart lại những instance đang gặp vấn đề. Vì vậy, trong bài viết này chúng ta sẽ tập trung vào việc xử lý kill Sidekiq.
<!--more-->

## Prerequisites

Điều kiện đầu tiên là hệ thống của bạn nên có từ 2 Sidekiq instances  trở lên, điều này để tránh gián đoạn trong quá trình sử dụng của người dùng. Tiếp theo, một instance chỉ được kill khi thoả mãn tất cả các điều kiện dưới đây:

* Lượng memory sử dụng đã vượt quá con số cho phép

* Còn ít nhất một instance Sidekiq khác khả dụng

* Không còn remaining jobs


Các bước sẽ được thực hiện theo chu trình này:

![image](</media/kill-sidekiq-when-it-reaches-memory-threshold/9c932a3f98cde05ced2eb0ada9e5f524.png>)

## Implement

Chúng ta cần tạo một middleware với nhiệm vụ kiểm tra trạng thái memory của instance và thực hiện tiến trình kill Sidekiq.


```ruby
require "sidekiq"
require "sidekiq/api"
require "sidekiq/util"

module SidekiqMiddlewares
  class ProcessKiller
    include Sidekiq::Util

    MAX_RSS = 2000
    MUTEX = Mutex.new
    SHUTDOWN_WAIT = 30
    KILL_SIGNAL = "SIGKILL"

    def call worker, _, _
      yield
      return if already_request_shutdown?

      GC.start(full_mark: true, immediate_sweep: true)
      return unless over_memory_limit?

      warn("current RSS #{current_rss}MB is over limit #{MAX_RSS}MB")
      return warn("no other process available!") unless other_process_available?

      request_shutdown
    end

    private

    def request_shutdown
      Thread.new do
        shutdown if MUTEX.try_lock
      end
    end

    def shutdown
      quiet_process
      mark_for_shutdown
      wait_for_remaining_jobs
      stop_process
      force_kill_process!
    end

    def quiet_process
      warn "sending quiet"
      sidekiq_process.quiet!
      sleep(5)
    end

    def mark_for_shutdown
      redis_key = request_shutdown_key(identity)
      redis{|conn| conn.set(redis_key, true, ttl: 1.hour)}
    end

    def wait_for_remaining_jobs
      warn "waiting for remaining jobs..."
      sleep(1) until remaining_jobs_finished?
      warn "all remaining jobs finished"
    end

    def stop_process
      warn "stopping..."
      sidekiq_process.stop!
    end

    def force_kill_process!
      sleep(SHUTDOWN_WAIT)
      warn "sending #{KILL_SIGNAL}"
      ::Process.kill(KILL_SIGNAL, ::Process.pid)
    end

    def already_request_shutdown?
      request_shutdown?(sidekiq_process)
    end

    def over_memory_limit?
      current_rss > MAX_RSS
    end

    def other_process_available?
      Sidekiq::ProcessSet.new.any? do |process|
        !current_process?(process) && !request_shutdown?(process)
      end
    end

    def remaining_jobs_finished?
      sidekiq_process.stopping? && sidekiq_process["busy"] == 0
    end

    def current_rss
      OS.rss_bytes / 1.megabytes
    end

    def sidekiq_process
      find_current_process || raise("No process with identity #{identity} found")
    end

    def find_current_process
      Sidekiq::ProcessSet.new.find{|process| current_process?(process)}
    end

    def request_shutdown? process
      redis{|conn| conn.get(request_shutdown_key(process.identity))}
    end

    def long_job_processing? worker, job
      long_worker?(job) && !current_job?(worker, job)
    end

    def long_worker? job
      job.dig("payload", "class").in?(LONG_WORKERS)
    end

    def current_job? worker, job
      job.dig("payload", "jid").eql?(worker.jid)
    end

    def current_process? process
      (process.is_a?(String) ? process : process.identity).eql?(identity)
    end

    def request_shutdown_key identity
      "shutting_down_#{identity}"
    end

    def warn message
      Sidekiq.logger.warn("#{identity}: #{message}")
    end
  end
end
```

Sau đó bạn cần đăng ký middleware này với Sidekiq:

```ruby
Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add(SidekiqMiddlewares::ProcessKiller)
  end
end
```

Với cách làm trên, mỗi khi kết thúc một job, quá trình kiểm tra Sidekiq memory sẽ được thực hiện. Bạn cũng có thể tạo một cron job kiểm tra định kỳ (vài phút một lần) thay vì sử dụng middleware. Cách làm đó có ưu điểm là không can thiệp vào tiến trình chạy job, tuy nhiên quá trình xử lý sẽ phức tạp hơn vì bạn cần lấy được thông tin memory của các instances Sidekiq khi đang ở server chạy cron job.

## Conclusion

Kill Sidekiq process là giải pháp cuối cùng để giải quyết vấn đề liên quan đến memory của Sidekiq. Trên đây là một ví dụ bạn có thể tham khảo, logic xử lý có thể sẽ thay đổi tuỳ thuộc vào mục đích cụ thể của bạn.
