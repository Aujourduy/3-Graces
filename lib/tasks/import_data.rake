# frozen_string_literal: true

require "csv"

namespace :import do
  desc "Import professors and scraped_urls from CSV files"
  task mass: :environment do
    teachers_file = "/home/dang/Aujourduy/tmp/teachers.csv"
    urls_file = "/home/dang/Aujourduy/tmp/teacher_urls.csv"

    unless File.exist?(teachers_file) && File.exist?(urls_file)
      puts "❌ Fichiers CSV introuvables :"
      puts "  - #{teachers_file}" unless File.exist?(teachers_file)
      puts "  - #{urls_file}" unless File.exist?(urls_file)
      exit 1
    end

    puts "🚀 Import en masse - Professors & ScrapedUrls"
    puts "=" * 60

    # Mapping Aujourduy ID -> Stop&Dance Professor
    professor_mapping = {}
    professors_created = 0
    professors_skipped = 0

    # Import professors
    puts "\n📚 Import professors depuis #{teachers_file}..."
    CSV.foreach(teachers_file, headers: true) do |row|
      aujourduy_id = row["id"]
      prenom = row["first_name"]&.strip
      nom = row["last_name"]&.strip
      email = row["contact_email"]&.strip

      # Skip si données manquantes
      if prenom.blank? || nom.blank?
        puts "  ⚠️  Skip #{row["id"]} - prenom/nom manquant"
        professors_skipped += 1
        next
      end

      # Normaliser pour recherche
      nom_complet = "#{prenom} #{nom}"
      nom_normalise = Professor.normaliser_nom(nom_complet)

      # Chercher professor existant (par nom_normalise)
      professor = Professor.find_by(nom_normalise: nom_normalise)

      if professor
        puts "  ✓ Exists: #{prenom} #{nom} (#{nom_normalise})"
        professors_skipped += 1
      else
        professor = Professor.create!(
          prenom: prenom,
          nom: nom,
          email: email.presence,
          status: "auto" # Import auto, review requis
        )
        puts "  ✅ Created: #{prenom} #{nom} (#{nom_normalise})"
        professors_created += 1
      end

      professor_mapping[aujourduy_id] = professor
    end

    puts "\n📊 Professors import:"
    puts "  ✅ Créés: #{professors_created}"
    puts "  ⚠️  Skipped (exists ou invalid): #{professors_skipped}"

    # Import scraped_urls
    puts "\n🌐 Import scraped_urls depuis #{urls_file}..."
    urls_created = 0
    urls_skipped = 0

    CSV.foreach(urls_file, headers: true) do |row|
      url = row["url"]&.strip
      teacher_id = row["teacher_id"]
      teacher_name = row["teacher_name"]&.strip
      site_type = row["site_type"]&.strip
      requires_js = row["requires_js"]&.strip

      # Skip si URL manquante
      if url.blank?
        puts "  ⚠️  Skip - URL manquante"
        urls_skipped += 1
        next
      end

      # Trouver professor correspondant
      professor = professor_mapping[teacher_id]
      unless professor
        puts "  ⚠️  Skip #{url} - professor #{teacher_name} introuvable"
        urls_skipped += 1
        next
      end

      # Chercher scraped_url existant
      scraped_url = ScrapedUrl.find_by(url: url)

      if scraped_url
        # Associer professor si pas déjà fait
        unless scraped_url.professors.include?(professor)
          scraped_url.professors << professor
          puts "  ✓ Associated: #{url} -> #{professor.prenom} #{professor.nom}"
        else
          puts "  ✓ Exists: #{url} (already linked)"
        end
        urls_skipped += 1
      else
        # Déterminer use_browser selon site_type/requires_js
        use_browser = (requires_js.present? && requires_js.downcase != "false") ||
                      (site_type.present? && site_type.include?("wix"))

        scraped_url = ScrapedUrl.create!(
          url: url,
          nom: teacher_name,
          use_browser: use_browser,
          statut_scraping: "en_attente",
          commentaire: "Import auto depuis Aujourduy (#{site_type})"
        )

        # Associer professor
        scraped_url.professors << professor

        marker = use_browser ? "🎭" : "🌐"
        puts "  ✅ #{marker} Created: #{url} -> #{professor.prenom} #{professor.nom}"
        urls_created += 1
      end
    end

    puts "\n📊 ScrapedUrls import:"
    puts "  ✅ Créées: #{urls_created}"
    puts "  ⚠️  Skipped (exists ou invalid): #{urls_skipped}"

    # Statistiques finales
    puts "\n" + "=" * 60
    puts "✅ Import terminé !"
    puts "\n📊 Base de données Stop & Dance :"
    puts "  - Professors: #{Professor.count} total (#{Professor.where(status: 'auto').count} à vérifier)"
    puts "  - ScrapedUrls: #{ScrapedUrl.count} total"
    puts "  - Associations: #{ProfessorScrapedUrl.count} total"
    puts "\n🔗 Prochaine étape :"
    puts "  - Admin review: http://localhost:3002/admin/professors"
    puts "  - Lancer scraping: http://localhost:3002/admin/scraped_urls"
  end
end
