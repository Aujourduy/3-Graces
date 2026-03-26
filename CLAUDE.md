# 3 Graces — Règles Projet

## SURCHARGES DU CLAUDE.MD GLOBAL

### Override Règle 2 — PENDANT L'EXÉCUTION DES STORIES
Quand Duy a lancé l'exécution des stories ("go", "continue", "enchaîne"),
ne PAS s'arrêter entre les stories pour proposer des options.
Enchaîner story suivante → tests → commit → push → story suivante.
La règle 2 reste active pour toute AUTRE discussion.

### Override Règle 3 (Démarrage session)
Ce projet N'UTILISE PAS SUIVI_ENCOURS.md ni SUIVI_ARCHITECTURE.md.
Au démarrage, lire ce fichier puis le fichier story de l'epic en cours.
Pour savoir où on en est : `git log --oneline` — le dernier commit 
feat: Story X.X indique la dernière story terminée.
Stories : `_bmad-output/planning-artifacts/epic-*.md`
Architecture : `_bmad-output/planning-artifacts/architecture.md`
Maquette UI : `docs/ui-reference.md` et `docs/ui-reference.jsx`

### Override Règle 4 et 8 (Git) — MODE AUTONOME
Commits et push AUTORISÉS SANS mot-clé ni token.
Commit + push automatique après chaque story réussie.
Format : `feat: Story X.X - Description`
La protection git-firewall.sh est désactivée pour ce projet.

### Mode continu
Ne PAS s'arrêter entre les epics pour faire un bilan ou résumé.
Enchaîner : story → tests → commit → push → story suivante →
jusqu'à ce que toutes les stories de tous les epics soient terminées.
Un résumé n'est PAS un problème bloquant.
STOP uniquement si erreur technique bloquante nécessitant intervention humaine.

---

## Projet
Agenda danse exploratoire France. Site read-only, zéro compte utilisateur.
Rails 8, PostgreSQL, Solid Queue, Tailwind, Turbo, Pagy.

## Définition de "Story terminée"
Une story est terminée UNIQUEMENT quand :
1. Code écrit selon acceptance criteria
2. Tests écrits ET passent (`rails test`)
3. Commit + push
Si les tests échouent, corriger avant de passer à la suite.

## Conventions à respecter PARTOUT

- **Timezone** : UTC en base, Europe/Paris à l'affichage. JAMAIS stocker en local.
- **Pagination** : Pagy (`@pagy, @records = pagy(scope)`). JAMAIS `.page().per()`.
- **Compteurs** : `Professor.increment_counter(:x, id)`. JAMAIS `increment!`.
- **Scopes temps** : `Time.current` dans Event.futurs. JAMAIS `Date.current`.
- **Jobs** : retry exponentiel 3x. ScrapingDispatchJob enqueue les ScrapingJobs.
- **Routes publiques** : français (/evenements, /professeurs).
- **Scraping MVP** : un seul HtmlScraper générique, pas de scrapers spécialisés.

## Ordre des Epics
Epic 1 DÉBUT → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → Epic 1 FIN (Docker/prod en dernier).

## Contexte serveur
- PostgreSQL local (user dang, peer auth, pas de mot de passe)
- Docker v1 tourne en parallèle — NE PAS TOUCHER
- Ports occupés : 3000, 3001, 80, 443
- Si bloqué : WebSearch ou WebFetch pour la doc