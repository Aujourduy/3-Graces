# Checklist Tests — Session 2026-04-11

Cocher chaque item après validation.

---

## 1. Tests automatisés

- [ ] `bin/rails test` — 110 tests, 0 failures, 0 errors
- [ ] `bin/rails test test/tasks/scraping_dry_run_test.rb` — 11 tests, 0 failures
- [ ] `bin/rails test test/lib/recurrence_expander_test.rb` — 10 tests, 0 failures
- [ ] `bin/rubocop` — 0 offense
- [ ] `bin/brakeman --no-progress` — 0 warning

## 2. Dry-run scraping

```bash
bin/rails scraping:dry_run
```

- [ ] La tâche s'exécute sans crash
- [ ] Rapport affiche : Total URLs, ✅ Success, ❌ Failed, Total duration
- [ ] Chaque ligne affiche : ✅/❌, #ID, nom, durée en ms
- [ ] URLs en succès affichent : html=XKB md=XKB
- [ ] URLs en échec affichent : ERROR: <message>
- [ ] Les URLs example.com sont en échec (Markdown too small)
- [ ] Aucun `Event` créé par la tâche (vérifier count avant/après)
- [ ] Aucun champ `derniere_version_html` modifié

**Vérification DB intacte :**
```bash
bin/rails runner "
before = Event.count
ScrapingDryRun.run_all
puts 'OK' if Event.count == before
"
```

- [ ] Retourne "OK"

## 3. Photos professeurs

### Upload

- [ ] Aller sur `/admin/professors/:id/edit`
- [ ] Le champ "Photo (upload)" est visible
- [ ] Upload une image → crop auto 300×300
- [ ] L'image s'affiche dans la liste `/admin/professors`
- [ ] L'image s'affiche sur `/professeurs/:id`
- [ ] L'image s'affiche dans les event cards de ce prof

### Alerte

- [ ] Alerte bleue "X professeur(s) sans photo" visible sur `/admin/professors`
- [ ] Bouton "Sans photo" filtre correctement

## 4. Admin Jobs

- [ ] `/admin/jobs` affiche stats (en attente, échoués, terminés, total)
- [ ] Section "Jobs en attente / en cours" affiche 20/page
- [ ] Section "Jobs échoués" affiche 20/page avec boutons Relancer / Supprimer
- [ ] Scroll infinite fonctionne sur les deux sections

## 5. Admin Notifications

- [ ] `/admin/notifications` affiche la liste
- [ ] Filtres : Toutes, Non lues, Erreurs, Warnings, Récurrence, Archivées
- [ ] Bulk actions : Marquer lu, Archiver
- [ ] Actions individuelles : Lu, Validé, Archiver
- [ ] Badge compteur "non_lu" dans la navbar admin
- [ ] Infinite scroll fonctionne

## 6. Infinite scroll sur toutes les pages

Pour chaque page, scroller jusqu'en bas doit charger plus d'items si `count > limit`:

- [ ] `/evenements` (public)
- [ ] `/admin/scraped_urls`
- [ ] `/admin/professors`
- [ ] `/admin/events`
- [ ] `/admin/change_logs`
- [ ] `/admin/site_crawls`
- [ ] `/admin/notifications`
- [ ] `/admin/jobs` (ready + failed sections)

**Vérification visuelle :** le spinner de chargement n'est jamais duplicate (un seul à la fois en bas).

## 7. Sécurité /admin (Tailscale)

- [ ] Accès via `server-dang:3002/admin` (Tailscale) → 200 + popup login
- [ ] Accès via IP non-Tailscale (localhost 127.0.0.1) → 403 Forbidden
- [ ] Site public `/evenements` toujours accessible
- [ ] README.md mentionne la config Tailscale pour fork/deploy

## 8. Agenda (site public)

- [ ] Ouvrir `/evenements` sur mobile
- [ ] Pas de scroll horizontal
- [ ] Cards events affichent : horaire ou "—" si inconnu, badges Atelier/Stage/Présentiel
- [ ] Durée affichée en XXmin ou XXhXXmin
- [ ] Photos profs Cloudinary (33 profs sur 65) s'affichent
- [ ] Recherche "peter" → 14 events
- [ ] Recherche "silvestre" → 38 events
- [ ] Cliquer sur un event ouvre la modal avec lien "Voir la page source"

## 9. Récurrences events

- [ ] Marc Silvestre : ~21 vendredis "Vagues - Paris" du prochain vendredi au dernier avant 31 août
- [ ] Peter Wilberforce : ~19 mardis "Le Corps de la Danse"
- [ ] Exclusions respectées (ex: 3 avril et 12 juin pour Marc sont en events séparés "Studio Noces")

## 10. Documentation

- [ ] `docs/scraping-urls.md` existe et documente le format du rapport
- [ ] `docs/etat-projet.md` à jour (date, dernier commit, session courante)
- [ ] `CLAUDE.md` mentionne l'infinite scroll obligatoire
- [ ] `README.md` mentionne Tailscale pour l'admin
- [ ] Gist synced avec `bin/sync-gist.sh`

---

**Date :** 2026-04-11
**Dernier commit main :** f195f5f
**Validé par :** _______________

---

## Résultats automatisés

- ✅ Tests Minitest : 110 runs, 341 assertions, 0 failures, 0 errors, 4 skips
- ✅ Tests scraping_dry_run : 11 tests, 37 assertions, 0 failures
- ✅ Rubocop : 120 files, 0 offenses
- ⚠️ Brakeman : 1 weak warning (faux positif, professors_controller redirect)
- ✅ Dry_run : 27 URLs, 20 succès, 7 échecs (6 example.com + 1 localhost test)
- ✅ Dry_run : 0 écriture DB (Event.count unchanged)
- ✅ Restriction Tailscale : localhost → 403, Tailscale IP → 200
- ✅ Toutes pages publiques : 200 + pas d'overflow horizontal mobile
- ✅ Toutes pages admin : 200 (via Tailscale)
- ✅ Infinite scroll : /evenements (30→60), /admin/professors (30→60)

