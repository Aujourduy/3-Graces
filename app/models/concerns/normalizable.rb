module Normalizable
  extend ActiveSupport::Concern

  included do
    before_validation :set_nom_normalise
  end

  class_methods do
    # Normalise un nom : downcase, strip accents, squeeze espaces
    # Exemples :
    #   "Marie Dupont" => "marie dupont"
    #   "Stéphane" => "stephane"
    #   "  MARIE   DUPONT  " => "marie dupont"
    def normaliser_nom(nom)
      return nil if nom.blank?

      nom.downcase
         .then { |s| ActiveSupport::Inflector.transliterate(s) }
         .squeeze(" ")
         .strip
    end

    # Trouve ou crée un professeur par nom normalisé (déduplication)
    # Retourne le professeur existant si le nom normalisé existe déjà
    # Crée un nouveau professeur sinon
    #
    # Exemples :
    #   Professor.find_or_create_from_scrape(nom: "Marie Dupont")
    #   Professor.find_or_create_from_scrape(nom: "Jean", email: "jean@example.com", bio: "...")
    def find_or_create_from_scrape(nom:, **attrs)
      nom_normalise = normaliser_nom(nom)

      find_or_create_by!(nom_normalise: nom_normalise) do |professor|
        professor.nom = nom
        professor.status = "auto"
        professor.assign_attributes(attrs)
      end
    rescue ActiveRecord::RecordNotUnique
      # Race condition : un autre process a créé le prof entre-temps
      retry
    end
  end

  private

  def set_nom_normalise
    self.nom_normalise = self.class.normaliser_nom(nom)
  end
end
