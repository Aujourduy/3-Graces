class AddTimestampsToScrapedUrls < ActiveRecord::Migration[8.1]
  def change
    add_column :scraped_urls, :derniere_version_html_at, :datetime
    add_column :scraped_urls, :derniere_version_markdown_at, :datetime
    add_column :scraped_urls, :dernier_parsing_claude_at, :datetime
  end
end
