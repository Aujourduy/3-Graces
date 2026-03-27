# Architecture Scraping — Stop & Dance

## Modèle de données

### Relations

```
ScrapedUrl (Source externe)
  ├─ has_many :professors (through :professor_scraped_urls)
  ├─ has_many :events
  └─ has_many :change_logs

Professor (Professeur de danse)
  ├─ has_many :scraped_urls (through :professor_scraped_urls)
  └─ has_many :events

Event (Atelier/Stage)
  ├─ belongs_to :professor
  ├─ belongs_to :scraped_url (optional)
  └─ has_many :event_sources (sources additionnelles)

ProfessorScrapedUrl (Join table)
  ├─ belongs_to :professor
  └─ belongs_to :scraped_url

EventSource (Multi-sourcing)
  ├─ belongs_to :event
  └─ belongs_to :scraped_url

ChangeLog (Historique modifications)
  └─ belongs_to :scraped_url
```

### Schéma textuel

```
┌─────────────────────────┐         ┌────────────────────────┐
│  ScrapedUrl             │────┬───→│  Professor             │
│                         │    │    │                        │
│ - url (unique)          │    │    │ - nom                  │
│ - nom (label UX)        │    │    │ - nom_normalise* (idx) │
│ - notes_correctrices    │    │    │ - status (auto/verified)│
│ - derniere_version_html │    │    │ - email                │
│ - statut_scraping       │    │    │ - bio                  │
│ - erreurs_consecutives  │    │    │ - site_web             │
└─────────────────────────┘    │    │ - avatar_url           │
         │                     │    │ - consultations_count  │
         │                     │    │ - clics_sortants_count │
         │                     │    └────────────────────────┘
         │    ┌────────────────┴──────────┐
         │    │ ProfessorScrapedUrl       │
         │    │  (join table extensible)  │
         │    └───────────────────────────┘
         │                                 │
         ↓                                 ↓
┌─────────────────────────┐         ┌────────────────────────┐
│     Event               │←────────│   EventSource          │
│                         │         │  (multi-sourcing)      │
│ - titre                 │         │ - event_id             │
│ - date_debut            │         │ - scraped_url_id       │
│ - date_fin              │         │ - primary_source       │
│ - tags[] (array)        │         └────────────────────────┘
│ - prix_normal           │
│ - prix_reduit           │
│ - gratuit (bool)        │
│ - en_ligne (bool)       │
│ - en_presentiel (bool)  │
│ - type_event (enum)     │
│ - slug (unique)         │
│ - professor_id (FK)     │
│ - scraped_url_id (FK)   │
└─────────────────────────┘

         ┌─────────────────────────┐
         │     ChangeLog           │
         │  (historique détaillé)  │
         │ - scraped_url_id (FK)   │
         │ - diff_html (text)      │
         │ - changements_detectes  │
         │   (jsonb)               │
         │ - created_at            │
         └─────────────────────────┘
```

---

## Déduplication des professeurs

### Problème

Sans déduplication, ces profs créeraient des doublons :
- `"Marie Dupont"` (scraped_url A)
- `"marie dupont"` (scraped_url B)
- `"  Marie  Dupont  "` (scraped_url C)
- `"Stéphane Lefèvre"` vs `"Stephane Lefevre"`

### Solution : Nom normalisé

**Champ** : `professors.nom_normalise` (string, unique index)

**Normalisation** :
1. `downcase` : "Marie" → "marie"
2. `transliterate` : "Stéphane" → "stephane" (strip accents)
3. `squeeze(' ')` : "  marie  dupont  " → " marie dupont "
4. `strip` : " marie dupont " → "marie dupont"

**Exemples** :

| Nom original | nom_normalise |
|--------------|---------------|
| "Marie Dupont" | `"marie dupont"` |
| "  MARIE   DUPONT  " | `"marie dupont"` |
| "Stéphane Lefèvre" | `"stephane lefevre"` |
| "José-María García" | `"jose-maria garcia"` |

### Utilisation dans le scraping

```ruby
# ❌ Avant (risque doublon)
Professor.create!(nom: "Marie Dupont", email: "...")

# ✅ Après (déduplication auto)
Professor.find_or_create_from_scrape(
  nom: "Marie Dupont",
  email: "marie@example.com",
  bio: "..."
)
# → Retourne prof existant si "marie dupont" existe déjà
# → Crée nouveau sinon avec status: "auto"
```

### Lifecycle professeur

```
┌─────────────────────────────────────────┐
│  1. Création auto via scraping          │
│     - nom: "Marie Dupont"               │
│     - nom_normalise: "marie dupont"     │
│     - status: "auto"                    │
│     (callback remplit nom_normalise)    │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│  2. Détection doublon (même source      │
│     ou source différente)               │
│     find_or_create_from_scrape cherche  │
│     par nom_normalise → trouve existant │
│     → N'en crée PAS de nouveau          │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│  3. Vérification manuelle admin         │
│     - Admin complète bio, vérifie email │
│     - Change status: "verified"         │
│     - Badge "Profil vérifié" sur page   │
└─────────────────────────────────────────┘
                   ↓
┌─────────────────────────────────────────┐
│  4. Merge manuel (si doublon détecté    │
│     malgré tout)                        │
│     - Réassocier events du doublon      │
│       → prof principal                  │
│     - Supprimer doublon                 │
└─────────────────────────────────────────┘
```

---

## Règles de scraping

### Détection changements HTML

```ruby
# 1. Fetch HTML de scraped_url.url
html = Scrapers::HtmlScraper.fetch(scraped_url.url)

# 2. Comparer avec derniere_version_html via HtmlDiffer
diff_result = HtmlDiffer.compare(
  scraped_url.derniere_version_html,
  html[:html]
)

# 3a. Si changé
if diff_result[:changed]
  # Créer ChangeLog avec diff visible
  ChangeLog.create!(
    scraped_url: scraped_url,
    diff_html: diff_result[:diff],
    changements_detectes: diff_result[:changements_detectes]
  )

  # Enqueue EventUpdateJob (parsing Claude CLI)
  EventUpdateJob.perform_later(scraped_url.id)
end

# 3b. Si inchangé
# → Skip parsing (économie appels Claude)
# → Update derniere_version_html quand même
```

### Création/update events via Claude CLI

```ruby
# 1. Claude CLI parse HTML → JSON events
result = ClaudeCliIntegration.parse_and_generate(
  scraped_url,
  html,
  scraped_url.notes_correctrices
)

# 2. Pour chaque event parsé
result[:events].each do |event_json|
  # Déduplication professeur
  prof = Professor.find_or_create_from_scrape(
    nom: event_json[:professeur_nom]
  )

  # Créer event
  Event.create!(
    titre: event_json[:titre],
    date_debut: event_json[:date_debut],
    date_fin: event_json[:date_fin],
    professor: prof,
    scraped_url: scraped_url,
    tags: event_json[:tags],
    prix_normal: event_json[:prix_normal],
    # ...
  )
end
```

### Gestion erreurs

```
┌─────────────────────────────┐
│  Scraping échoue            │
│  (HTTP error, timeout, etc.)│
└─────────────────────────────┘
              ↓
┌─────────────────────────────┐
│  erreurs_consecutives += 1  │
│  Log erreur (SCRAPING_LOGGER)│
└─────────────────────────────┘
              ↓
┌─────────────────────────────┐
│  Si erreurs_consecutives ≥ 3│
│  → Alerte email admin        │
│  (AlertEmailJob)            │
└─────────────────────────────┘
              ↓
┌─────────────────────────────┐
│  Prochain scraping réussit  │
│  → erreurs_consecutives = 0  │
│  (reset compteur)           │
└─────────────────────────────┘
```

---

## Types de sources

### Source solo (1 professeur)

**Exemple** : Site personnel d'un prof

```ruby
ScrapedUrl.create!(
  url: "https://example.com/marie-dupont",
  nom: "Site de Marie Dupont",
  notes_correctrices: "Site personnel - scraping actif"
)

# Associé à 1 seul professeur
scraped_url.professors.count # => 1
```

### Source multi (plusieurs professeurs)

**Exemple** : Planning d'un studio collectif

```ruby
ScrapedUrl.create!(
  url: "https://studio-collectif.com/agenda",
  nom: "Studio Collectif Paris",
  notes_correctrices: "Planning mensuel - plusieurs professeurs"
)

# Associé à plusieurs professeurs
scraped_url.professors.count # => 3 (ex: Sophie, Marie, Camille)
```

**Seeds test** : Sophie Marchand apparaît dans 2 sources différentes
- `scraped_urls[0]` : Son site personnel
- `scraped_urls[5]` : Studio Collectif Paris

```ruby
sophie = Professor.find_by(email: "sophie.marchand@example.com")
sophie.scraped_urls.count # => 2
```

---

## Multi-sourcing events

Un même événement peut apparaître sur plusieurs sites (ex: site du prof + site du studio hôte).

**Table `event_sources`** :
- `event_id` : L'événement
- `scraped_url_id` : Une source qui mentionne cet événement
- `primary_source` : true pour la source principale (site du prof), false pour les secondaires

**Exemple** :

```ruby
event = Event.find_by(titre: "Atelier CI Paris")

# Source principale
event.scraped_url # => ScrapedUrl("sophie-marchand")

# Sources additionnelles
event.event_sources # => [
#   EventSource(scraped_url: "studio-collectif", primary_source: false)
# ]
```

---

## Commandes utiles

### Scraping manuel

```bash
# Scraper une URL spécifique
bin/rails scraping:run[1]  # ID de la ScrapedUrl

# Dry-run (test parsing sans sauvegarder)
bin/rails scraping:test[1]

# Scraper toutes les URLs actives
bin/rails scraping:run_all
```

### Backfill nom_normalise

```bash
# Remplir nom_normalise pour les profs existants (une seule fois après migration)
bin/rails professors:backfill_nom_normalise
```

### Console Rails

```ruby
# Tester normalisation
Professor.normaliser_nom("Stéphane Lefèvre")
# => "stephane lefevre"

# Tester déduplication
prof = Professor.find_or_create_from_scrape(nom: "Marie Dupont")
# → Retourne existant ou crée nouveau

# Vérifier multi-sources
sophie = Professor.find_by(email: "sophie.marchand@example.com")
sophie.scraped_urls.pluck(:nom)
# => ["Site de Sophie Marchand", "Studio Collectif Paris"]
```

---

## Architecture fichiers

```
app/
├─ models/
│  ├─ concerns/
│  │  └─ normalizable.rb         # Concern déduplication
│  ├─ professor.rb               # Include Normalizable
│  ├─ scraped_url.rb
│  ├─ event.rb
│  └─ change_log.rb
├─ jobs/
│  ├─ scraping_job.rb            # Job principal scraping
│  └─ scraping_dispatch_job.rb   # Orchestration 24h

lib/
├─ scraping_engine.rb            # Logique centrale scraping
├─ html_differ.rb                # Détection changements HTML
├─ claude_cli_integration.rb     # Parsing LLM headless
└─ scrapers/
   └─ html_scraper.rb            # Fetch HTTP/HTTPS

db/
├─ migrate/
│  └─ YYYYMMDD_add_deduplication_fields_to_professors_and_scraped_urls.rb
└─ seeds.rb                      # Seeds avec prof multi-sources

test/
└─ models/
   └─ professor_test.rb          # Tests déduplication
```

---

## Évolutions futures

### Phase 1 (MVP actuel)
- ✅ Déduplication professeurs par nom normalisé
- ✅ Multi-sourcing (professeur dans plusieurs sources)
- ✅ Historique détaillé (ChangeLog avec diff HTML)
- ✅ Status auto/verified

### Phase 2 (Post-MVP)
- 🔲 Détection automatique doublons existants (fuzzy matching)
- 🔲 Interface admin merge professeurs
- 🔲 Notifications email aux profs (nouveaux events détectés)
- 🔲 API publique REST pour récupérer events par prof
- 🔲 Scraping spécialisé par plateforme (Google Calendar, HelloAsso)

---

**Dernière mise à jour** : 2026-03-27
