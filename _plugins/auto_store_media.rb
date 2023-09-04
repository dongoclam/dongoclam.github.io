# frozen_string_literal: true

require "open-uri"

class AutoStoreMedia
  MEDIA_FOLDER = "media"
  CONTENT_TYPE_REGEX = /\/([\w]+)/
  MEDIA_URL_REGEX = /\(<?\/?([^>]+)>?\)/
  MEDIA_MARKDOWN_REGEX = /!\[[^\[^\]]*\]\([^\(^\)]+\)/

  def initialize site
    @posts = site.posts.docs
  end

  def perform
    @posts.each do |post|
      content = File.read(post.path)
      save_post_media(post, content)
      remove_unused_media(post, content)
    end
  end

  private
  def save_post_media post, content
    content.scan(MEDIA_MARKDOWN_REGEX).each do |media_link|
      replace_media_url(media_link, post, content)
    end
  end

  def remove_unused_media post, content
    folder_path = post_media_path(post)

    Dir["#{folder_path}/*.*"].each do |media_path|
      File.delete(media_path) unless content.match?(media_path)
    end
  end

  def replace_media_url media_link, post, content
    media_url = media_link.scan(MEDIA_URL_REGEX).flatten.first
    return if File.exist?(media_url)

    markdown_media_path = save_media(media_url, post)
    content.gsub!(media_url, markdown_media_path)
    File.write(post.path, content)
  end

  def save_media media_url, post
    folder_path = post_media_path(post)

    if online_source?(media_url)
      media_path = save_online_media(media_url, folder_path)
      return "</#{media_path}>"
    end

    media_path = save_local_media(media_url, folder_path, post.path)
    "/#{media_path}"
  end

  def save_online_media media_url, folder_path
    temp_file = open(media_url)
    file_content = temp_file.read

    extension = temp_file.content_type.scan(CONTENT_TYPE_REGEX).flatten.first
    md5 = Digest::MD5.hexdigest(file_content)
    saved_path = [folder_path, "#{md5}.#{extension}"].join("/")

    FileUtils.mkdir_p(folder_path)
    File.write(saved_path, file_content)
    saved_path
  end

  def save_local_media media_url, folder_path, post_path
    current_path = [File.dirname(post_path), media_url].join("/")
    temp_file = File.open(current_path)

    extension = File.extname(current_path)
    md5 = Digest::MD5.file(temp_file).hexdigest
    saved_path = [folder_path, "#{md5}#{extension}"].join("/")

    FileUtils.mkdir_p(folder_path)
    FileUtils.mv(current_path, saved_path)
    saved_path
  end

  def post_media_path post
    [MEDIA_FOLDER, post.id].join
  end

  def online_source? media_url
    media_url.start_with?("http")
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  AutoStoreMedia.new(site).perform
end
