namespace :professors do
  desc "Backfill nom_normalise for existing professors"
  task backfill_nom_normalise: :environment do
    puts "🔄 Backfilling nom_normalise for existing professors..."

    # Compter les profs sans nom
    invalides = Professor.where(nom: nil).count
    puts "⚠️  #{invalides} professors without nom (will be skipped)" if invalides > 0

    # Backfill uniquement ceux avec nom présent
    count = 0
    errors = 0

    Professor.where.not(nom: nil).find_each do |professor|
      normalized = Professor.normaliser_nom(professor.nom)

      if normalized.present?
        begin
          professor.update!(nom_normalise: normalized)
          count += 1
          print "." if (count % 10).zero?
        rescue ActiveRecord::RecordInvalid => e
          puts "\n⚠️  Error updating professor ID #{professor.id} (#{professor.nom}): #{e.message}"
          errors += 1
        end
      else
        puts "\n⚠️  Skipping professor ID #{professor.id} (nom empty after normalization)"
        errors += 1
      end
    end

    puts "\n"
    puts "✓ Backfilled nom_normalise for #{count} professors"
    puts "⚠️  #{errors} professors skipped due to errors" if errors > 0
  end
end
