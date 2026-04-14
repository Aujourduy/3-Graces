# Scraping URLs — Dry-run et rapport

## Tâche `scraping:dry_run`

Itère sur toutes les `ScrapedUrl` avec `statut_scraping: "actif"`, exécute le pipeline de scraping **sans écrire en base de données**, et affiche un rapport ✅/❌ par URL.

### Lancer la tâche

```bash
bin/rails scraping:dry_run
```

**Note importante :** Le modèle dans ce projet est `ScrapedUrl` (pas `UrlSource`). Le flag `use_browser` détermine si Playwright ou HTTParty est utilisé pour le fetch.

## Pipeline exécuté

1. **Fetch HTML** — via `Scrapers::PlaywrightScraper` si `use_browser=true`, sinon `Scrapers::HtmlScraper`
2. **Nettoyage + conversion Markdown** — via `HtmlCleaner.clean_and_convert`
3. **Validation** — Markdown doit faire au moins 100 bytes (sinon JS-only détecté)

⚠️ Le dry-run **ne fait PAS** d'appel Claude CLI (trop lent pour un rapport batch). Il s'arrête après la conversion Markdown.

## Aucune écriture en DB

- Pas de création/mise à jour d'`Event`
- Pas de touche aux colonnes `derniere_version_html`, `derniere_version_markdown`, `data_attributes`, `html_hash`
- Les `Professor` ne sont pas modifiés non plus

Les tests vérifient explicitement ces invariants (`test "run_one does not create events"`, `test "run_one does not touch scraped_url html fields"`).

## Format du rapport

### En-tête

```
======================================================================
SCRAPING DRY RUN REPORT
======================================================================
Total URLs: 26
✅ Success: 18
❌ Failed:  8
======================================================================
```

### Lignes par URL

**Succès :**
```
✅ #7 site de Marc Silvestre
   html=419532B md=5421B
```

**Échec :**
```
❌ #53 Peter Wilberforce - Body Voice Being
   ERROR: Fetch failed: Connection timeout
```

### Champs retournés par `ScrapingDryRun.run_one(scraped_url)`

```ruby
{
  url_id: 7,                              # ID de la ScrapedUrl
  url: "https://www.example.com/agenda",  # URL source
  nom: "site de Marc Silvestre",          # Label descriptif
  success: true,                          # true si pipeline OK
  error: nil,                             # Message d'erreur si échec
  html_size: 419532,                      # Bytes HTML fetché
  markdown_size: 5421                     # Bytes Markdown après nettoyage
}
```

## Types d'erreurs possibles

| Erreur | Cause | Exemple |
|--------|-------|---------|
| `Fetch failed: <message>` | Erreur HTTP (timeout, 404, robots.txt) | `Fetch failed: Connection refused` |
| `Empty markdown after cleaning` | Contenu JS-only (React SPA, Wix sans fallback) | `Empty markdown after cleaning (42 bytes)` |
| `Exception: <class>: <message>` | Exception Ruby non gérée | `Exception: StandardError: Network down` |

## Tests Minitest

**Fichier :** `test/tasks/scraping_dry_run_test.rb`

**Fixtures HTML** (`test/fixtures/files/scraping/`) :
- `static_site.html` — site HTML statique classique avec `<article>` et événements
- `wix_site.html` — site Wix avec contenu dans le body (non-JS-only)
- `react_empty.html` — SPA React avec `<div id="root">` vide et `<noscript>`

**Couverture :**
- ✅ Succès sur site statique (11 tests au total)
- ✅ Succès sur Wix avec contenu
- ❌ Échec sur React SPA (markdown vide)
- ❌ Capture erreur fetch
- ❌ Capture exception Ruby
- ✅ Utilise Playwright si `use_browser=true`
- ✅ Utilise HtmlScraper si `use_browser=false`
- ✅ `run_all` retourne les résultats de toutes les URLs actives (ignore `pause`)
- ✅ Pas de création d'`Event`
- ✅ Pas de modification des champs HTML de `ScrapedUrl`
- ✅ `print_report` affiche en-tête + lignes ✅/❌ + message d'erreur

**Lancer les tests :**

```bash
bin/rails test test/tasks/scraping_dry_run_test.rb
```

## Cas d'usage

- **Audit régulier** : vérifier qu'aucune URL n'est cassée (changement de site, timeout)
- **Avant un déploiement** : s'assurer que le pipeline fonctionne end-to-end sur toutes les sources
- **Debug** : identifier rapidement les URLs qui nécessitent Playwright (JS-only) vs HTTParty

---

## Tâche `scraping:verify`

Compare visuellement les events en DB avec ce qui est affiché sur le site source. Utilise Claude CLI pour analyser des screenshots Playwright.

### Lancer

```bash
bin/rails scraping:verify
```

### Pipeline

1. Screenshot Playwright full-page de chaque URL active (exclut example.com, localhost)
2. Récupère les events futurs en DB pour cette URL
3. Envoie screenshot + events JSON à Claude CLI (`claude -p`)
4. Claude compare et retourne `match` / `partial` / `mismatch` avec issues

### Rapport

Généré dans `tmp/scraping_verify_report.md`.

**Status possibles :**

| Status | Signification |
|--------|---------------|
| ✅ match | Events DB correspondent au screenshot |
| ⚠️ partial | Correspondance partielle (résolution screenshot, noms différents) |
| ❌ mismatch | Events DB ne correspondent pas au site |
| 💀 error | Screenshot échoué ou erreur Claude |
| ⏭️ skip | URL sans events futurs en DB |

### Limites

- ~15-20s par URL (screenshot + appel Claude)
- La résolution du screenshot peut limiter la vérification détaillée
- Claude peut retourner "partial" quand les events sont corrects mais difficilement lisibles

---

## Tâche `scraping:missing`

Détecte les events **visibles sur le site mais absents de la DB**. L'inverse de `scraping:verify`.

### Lancer

```bash
bin/rails scraping:missing
```

### Pipeline

1. Screenshot Playwright full-page (URLs avec events futurs uniquement)
2. Envoie screenshot + liste des events DB à Claude CLI
3. Claude identifie les events sur le screenshot qu'on n'a pas en DB
4. **Comparaison par DATE** (pas par titre) — même prof + même date = couvert

### Rapport

Généré dans `tmp/scraping_missing_report.md`.

### Limites connues

- **Faux positifs possibles** — Claude peut halluciner des dates/noms sur des screenshots complexes (QR codes, images, texte petit). Vérifier manuellement les events signalés.
- Ne s'exécute que sur les URLs avec events futurs en DB (skip les autres)
- ~15s par URL

### Résultat type

```
URLs vérifiées : 4
✅ Complet : 2
⚠️ Events manquants détectés : 2
💀 Erreurs : 0
Total events manquants : 5
```

---

## Récapitulatif des 3 tâches

| Tâche | Ce qu'elle vérifie | Claude ? | Durée |
|-------|-------------------|----------|-------|
| `scraping:dry_run` | Pipeline fetch + markdown OK | Non | ~100s |
| `scraping:verify` | Events DB correspondent au site | Oui | ~3min |
| `scraping:missing` | Events sur le site absents de la DB | Oui | ~1min |

**Ordre recommandé :**
1. `dry_run` d'abord (rapide, sans Claude)
2. `verify` ensuite (vérifie la cohérence)
3. `missing` en dernier (détecte les oublis)
