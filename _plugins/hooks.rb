# frozen_string_literal: true

Jekyll::Hooks.register :site, :post_write do |site|
  post_tags = site.tags.keys.uniq.each_with_object({}) do |tag, result|
    result[tag] = tag.downcase.gsub(" ", " ")
  end

  existing_tags = Dir["_tags/*.html"].map do |filename|
    File.basename(filename, ".html")
  end

  post_tags.each do |tag, filename|
    next if existing_tags.include?(filename)

    File.open("_tags/#{filename}.html", "wb") do |file|
      file << "---\nlayout: tag\ntag_name: #{tag}\n---\n"
    end
  end

  (existing_tags - post_tags.values).each do |tag|
    File.delete("_tags/#{tag}.html")
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  posts = site.posts.docs.map do |post|
    post.data.slice("slug", "title", "excerpt").transform_values(&:to_s)
  end

  categories = site.categories.keys
  tags = site.tags.keys

  site.data["collections"] = {
    "categories": categories,
    "posts": posts,
    "tags": tags,
  }
end
