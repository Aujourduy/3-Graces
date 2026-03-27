class AddDeduplicationFieldsToProfessorsAndScrapedUrls < ActiveRecord::Migration[8.1]
  def change
    # Professor: nom_normalise pour déduplication
    add_column :professors, :nom_normalise, :string
    add_index :professors, :nom_normalise, unique: true

    # Professor: status (auto vs verified)
    add_column :professors, :status, :string, default: "auto", null: false

    # ScrapedUrl: nom lisible pour admin UX
    add_column :scraped_urls, :nom, :string
  end
end
