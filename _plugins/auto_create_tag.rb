# frozen_string_literal: true

class AutoCreateTag
  def initialize site
    @post_tags = get_post_tags(site)
    @existing_tags = get_existing_tags
  end

  def perform
    create_new_tags
    remove_unused_tags
  end

  private
  def create_new_tags
    @post_tags.each do |tag, filename|
      next if @existing_tags.include?(filename)

      File.open("_tags/#{filename}.html", "wb") do |file|
        file << "---\nlayout: tag\ntag_name: #{tag}\n---\n"
      end
    end
  end

  def remove_unused_tags
    (@existing_tags - @post_tags.values).each do |tag|
      File.delete("_tags/#{tag}.html")
    end
  end

  def get_post_tags site
    site.tags.keys.uniq.each_with_object({}) do |tag, result|
      result[tag] = tag.downcase.gsub(" ", " ")
    end
  end

  def get_existing_tags
    Dir["_tags/*.html"].map do |filename|
      File.basename(filename, ".html")
    end
  end
end

Jekyll::Hooks.register :site, :post_write do |site|
  AutoCreateTag.new(site).perform
end
