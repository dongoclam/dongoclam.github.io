
# frozen_string_literal: true

class AutoExportData
  POST_ATTRS = %w(slug title excerpt)

  def initialize site
    @site = site
  end

  def perform
    @site.data["collections"] = {
      "categories": categories,
      "posts": posts,
      "tags": tags,
    }
  end

  private
  def posts
    @site.posts.docs.map do |post|
      post.data.slice(*POST_ATTRS).transform_values(&:to_s)
    end
  end

  def categories
    @site.categories.keys
  end

  def tags
    @site.tags.keys
  end
end

Jekyll::Hooks.register :site, :post_read do |site|
  AutoExportData.new(site).perform
end
