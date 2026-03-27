class AddCommentaireToScrapedUrls < ActiveRecord::Migration[8.1]
  def change
    add_column :scraped_urls, :commentaire, :text
  end
end
