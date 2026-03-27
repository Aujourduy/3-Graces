---
stepsCompleted:
  - step-01-init
  - step-02-discovery
  - step-02b-vision
  - step-02c-executive-summary
  - step-03-success
  - step-04-journeys
  - step-05-domain-skipped
  - step-06-innovation-skipped
  - step-07-project-type
  - step-08-scoping-skipped
  - step-09-functional
  - step-10-nonfunctional
  - step-11-polish
inputDocuments:
  - docs/brief.md
workflowType: 'prd'
briefCount: 1
researchCount: 0
brainstormingCount: 0
projectDocsCount: 0
classification:
  projectType: web_app
  domain: general
  complexity: medium
  projectContext: greenfield
---

# Product Requirements Document - 3graces-v2

**Author:** Duy
**Date:** 2026-03-23

## Executive Summary

Stop & Dance est l'agenda de référence exhaustif des pratiques de danse exploratoires et non-performatives en France. Le produit répond à une question simple que Google et Facebook ne savent pas résoudre : "Où trouver un atelier de danse exploratoire ?" (ce soir à Paris, ce week-end à Lyon, la semaine prochaine à Marseille, etc.)

**Utilisateurs cibles :** Danseurs occasionnels ou réguliers qui veulent découvrir de nouvelles pratiques exploratoires et non-performatives, mais ne savent pas où chercher.

**Problème résolu :** Les informations sur les ateliers de danse exploratoire sont éparpillées sur des dizaines de sites individuels de professeurs. Google et Facebook n'offrent pas de recherche claire par date et activités pour ce type de pratiques. Les danseurs perdent du temps à chercher et ratent des opportunités.

**Solution :** Interface web simple (read-only) où l'utilisateur voit immédiatement l'agenda complet des ateliers disponibles. Recherche par mots-clés, filtres par plage de temps et localisation pour planifier des déplacements et organiser des "tournées danse".

**Vision future :** Dans 1-2 ans, les danseurs explorateurs en France sauront que TOUTES les propositions de danse exploratoires et non-performatives sont sur Stop & Dance. Réflexe automatique pour trouver quoi faire.

**Objectif stratégique secondaire :** Stop & Dance sert de canal d'acquisition pour le programme de coaching "Du chaos au vivant" (Duy), les visiteurs étant le public cible exact du coaching.

### Ce qui rend ce produit spécial

**Exhaustivité automatisée :** Architecture basée sur scraping automatisé + génération de contenu par LLM (Claude Code CLI headless). Le système scrape les sites des profs, détecte les changements via diff HTML, génère/met à jour automatiquement les fiches événements. Orchestration complète via Solid Queue dans Rails 8. Zéro intervention manuelle.

**Simplicité d'usage immédiate :** Pas de compte utilisateur, pas de CRUD. L'utilisateur ouvre le site → tout l'agenda est là. Recherche intuitive + filtres pour planifier à l'avance.

**Curation spécialisée :** Focus exclusif sur les pratiques exploratoires et non-performatives. Ce que les plateformes généralistes (Google, Facebook, Eventbrite) ne savent pas identifier ni présenter clairement.

**Efficacité opérationnelle :** Conçu pour fonctionner avec minimum d'intervention humaine (créateur = nouveau papa avec disponibilité très limitée). Automatisation maximale maintient l'exhaustivité sans effort.

## Classification du Projet

**Type de projet :** Web App (Rails 8 + PostgreSQL, interface responsive mobile-first)

**Domaine :** Général (événements culturels / danse)

**Complexité :** Medium
- Architecture technique sophistiquée (scraping automatisé, orchestration jobs, intégration LLM)
- Pas de régulations lourdes ni compliance critique
- Workflows d'automatisation complexes mais domaine métier standard

**Contexte projet :** Greenfield (nouveau projet construit depuis zéro)

## Success Criteria

### User Success

Le succès utilisateur se mesure quand l'utilisateur trouve un atelier qui l'intéresse et clique vers le site du prof pour s'inscrire. L'utilisateur a résolu son problème : trouver facilement une pratique de danse exploratoire correspondant à ses critères (date, lieu, type).

**Métrique clé :** Taux de clics sortants (pourcentage de visiteurs qui cliquent vers le site d'un prof).

### Business Success

**Métriques d'engagement :**
- Visiteurs uniques par mois
- Taux de clics sortants vers les profs
- Nombre de profs référencés en base

**Objectif stratégique :** Stop & Dance devient un canal d'acquisition viable pour le programme de coaching "Du chaos au vivant", les visiteurs étant le public cible exact.

### Technical Success

Le système automatisé est fiable quand :
- **Autonomie opérationnelle :** Le système tourne 7 jours consécutifs sans intervention manuelle
- **Exactitude des données :** Les fiches générées par Claude Code CLI contiennent dates/lieux/prix corrects (95%+ d'exactitude)
- **Fiabilité du scraping :** Le journal de diff ne montre aucune erreur silencieuse (changements non détectés, parsing échoué)

### Measurable Outcomes

**3-6 mois après lancement :**
- Le site référence un nombre significatif de profs de danse exploratoire en France
- Les visiteurs cliquent régulièrement vers les sites des profs
- Le système automatisé fonctionne de manière autonome sans intervention quotidienne
- Les danseurs commencent à considérer Stop & Dance comme référence pour trouver des ateliers

## Product Scope

### MVP - Minimum Viable Product

**Automatisation core :**
- Liste d'URLs prédéfinie de profs avec avatar + bio
- Scraping HTML automatisé via Solid Queue (cron toutes les 24h + jobs)
- Formats supportés MVP : sites web HTML/HTTP classiques, Google Calendar, Helloasso
- Formats exclus MVP : Instagram, Facebook (authentification requise, post-MVP)
- Détection de changements via diff avec version stockée
- Génération/mise à jour automatique des fiches par Claude Code CLI headless
- Journal des changements détectés
- Écriture en base PostgreSQL (timezone Europe/Paris)

**Interface utilisateur :**
- Affichage agenda chronologique des événements (futur par défaut, passé accessible)
- Carte événement : heure · tags · titre · animé par · lieu · prix
- Filtres de base : date, type (atelier/stage), présentiel/en ligne, gratuit
- Interface responsive mobile-first (design terracotta/orangé + beige + fond sombre)

**Engagement utilisateur :**
- Newsletter : inscription email simple

**Stack technique MVP :**
- Rails 8 + PostgreSQL (config.time_zone = "Europe/Paris")
- Solid Queue (orchestration cron + jobs)
- Claude Code CLI headless (abonnement Pro, pas Claude API)
- Tailwind CSS
- Docker sur serveur HP EliteDesk (Linux headless)

### Growth Features (Post-MVP)

**Recherche avancée :**
- Recherche par mots-clés dans barre de recherche (Algolia)
- Géolocalisation "Moins de X km autour de (ville)" via Geocoding API (Algolia Geo Search ou Google Maps)
- Planification de déplacements et organisation de "tournée danse"

**Médias optimisés :**
- Cloudinary pour avatars profs et images événements optimisées

**Engagement pros :**
- Formulaire "Publies tes ateliers" (contact simple pour les pros, pas de CRUD)

**Scraping étendu :**
- Instagram et Facebook (authentification gérée)

**Sécurité renforcée :**
- Chiffrement AES-256 au repos pour emails newsletter

### Vision (Future)

**État futur à 1-2 ans :**
- Stop & Dance est LA référence exhaustive reconnue pour les pratiques de danse exploratoires et non-performatives en France
- Les danseurs ont le réflexe automatique : "Je cherche un atelier exploratoire → je vais sur Stop & Dance"
- Le système fonctionne de manière totalement autonome avec minimum d'intervention humaine
- Canal d'acquisition établi et efficace pour le coaching "Du chaos au vivant"

## User Journeys

### Journey 1 : Danny, le Danseur Explorateur (Prioritaire)

**Persona :** Danny, 40 ans, salarié à Paris. Pratique le développement personnel et cherche à bouger son corps de manière connectée à son être. Ouvert au bien-être.

**Situation :** Danny veut explorer des pratiques de danse mais les infos sont très éparpillées. Pas d'annuaire ni d'agenda global. La nomenclature est floue (danse ecstatique vs noms similaires). Google le renvoie sur des pages à fort trafic mais pas pertinentes (dates passées, mauvais ciblage).

**Parcours :**
- **Découverte :** Via Google ("atelier danse libre Paris ce weekend") ou bouche à oreille
- **Arrivée sur Stop & Dance :** Filtre par date et lieu d'abord, puis par type
- **Préférence visuelle :** Bascule entre mode clair et mode sombre selon confort (utilise souvent le site le soir)
- **Climax :** En moins de 2 minutes, trouve un atelier qui l'intéresse
- **Action :** Clique vers le site du prof pour s'inscrire
- **Engagement :** S'inscrit à la newsletter pour rester informé

**Résolution :** Danny explore de nouvelles pratiques qu'il n'aurait jamais trouvées seul. Il revient sur Stop & Dance quand l'envie d'explorer se manifeste — pas forcément chaque semaine, mais c'est son réflexe. Recommande le site à des amis dans la même situation. Parfois découvre un atelier de Duy et ça l'amène vers "Du chaos au vivant".

---

### Journey 2 : Administrateur (Duy)

**Persona :** Duy, créateur et administrateur de Stop & Dance. Nouveau papa avec disponibilité très limitée. Besoin d'un système qui tourne sans intervention.

**Besoin principal :** Savoir que le système fonctionne de manière autonome.

**Parcours :**
- **Monitoring léger :** Consulte les logs uniquement quand quelque chose semble anormal (souvent tard le soir → préfère mode sombre)
- **Ajout d'URLs :** Ajoute manuellement de nouvelles URLs à scraper (rare)
- **Correction d'erreurs :** Si le journal signale un problème de parsing, intervient pour corriger
- **Notes correctrices par URL :** Laisse une note correctrice par URL scrapée (ex: "ignorer la section X", "le prix est toujours dans ce format", "cette page utilise du JS dynamique"). Claude Code CLI lit ces notes avant de parser chaque URL. Fichier texte simple par URL, pas d'interface complexe.

**Succès :** Le système tourne 7 jours sans intervention. Logs clairs, pas de dashboard complexe.

---

### Journey 3 : Prof de Danse

**Persona :** Marc, prof de Contact Impro à Paris. Cherche à remplir ses ateliers avec un public qualifié.

**Besoin :** Visibilité ciblée auprès de danseurs explorateurs vraiment intéressés, pas des débutants perdus.

**Parcours :**
- **Zéro effort :** Son site est scrapé automatiquement, il n'a rien à faire
- **Trafic qualifié :** Reçoit des inscriptions depuis Stop & Dance via clics sortants
- **Stats publiques :** Peut voir combien de fois son profil a été consulté et combien de clics sortants vers son site ont été générés. Page publique simple : `3graces.community/profs/nom-du-prof/stats` (pas de compte, juste une URL unique). Peut basculer en mode clair/sombre pour consulter ses stats confortablement.

**Succès :** Plus d'inscrits qui correspondent à son public idéal (explorateurs, pratiques non-performatives). Ses ateliers se remplissent avec le bon public.

## Web App Technical Requirements

### Architecture Front-End

**Type :** Multi-Page App (MPA) avec Rails 8 + Turbo + Tailwind CSS

**Justification :**
- Simplicité de développement et maintenance (pas de framework JS lourd)
- Turbo (inclus par défaut dans Rails 8) offre navigation rapide style SPA
- SEO natif (rendu côté serveur)
- Temps de développement réduit
- Compatible avec automatisation Claude Code CLI

### Browser Matrix

**Navigateurs supportés :**
- Chrome/Edge : 2 dernières versions
- Firefox : 2 dernières versions
- Safari : 2 dernières versions (iOS et macOS)

**Non supportés :** Internet Explorer 11 et navigateurs obsolètes

**Justification :** Audience tech-friendly (danseurs explorateurs), pas de besoin de support legacy. Évite polyfills et bugs complexes.

### Responsive Design

**Approche :** Mobile-first

**Breakpoints :**
- Mobile : 375px - 768px (référence iPhone 12 Pro : 390px)
- Tablet : 768px - 1024px
- Desktop : 1024px+

**Layout :**
- Mobile : Panel filtres dépliable, liste événements pleine largeur
- Desktop : Sidebar filtres visible en permanence, liste événements centrale

**Design System :**
- Palette : Terracotta/orangé + beige + fond sombre (identité forte)
- Tailwind CSS pour styles
- Mode clair/sombre avec toggle utilisateur (préférence sauvegardée)

### Performance Targets

**Objectifs de chargement :**
- First Contentful Paint (FCP) : < 1.5s
- Time to Interactive (TTI) : < 3s
- Largest Contentful Paint (LCP) : < 2.5s

**Optimisations :**
- Images optimisées (format WebP, lazy loading)
- CSS/JS minifiés par défaut (Rails asset pipeline)
- Turbo pour navigation instantanée sans rechargement complet

### SEO Strategy

**Balises meta par page :**
- Title unique et descriptif (< 60 caractères)
- Meta description (< 160 caractères)
- Canonical URL

**Schema.org markup :**
- Type `Event` pour chaque atelier
- Propriétés : name, startDate, endDate, location, organizer, price
- Affichage enrichi dans Google Search

**Open Graph :**
- og:title, og:description, og:image, og:url
- Optimisation partages réseaux sociaux (bouche à oreille)

**Sitemap & Robots :**
- Sitemap XML généré automatiquement (tous les événements)
- robots.txt configuré pour indexation complète

**URLs propres :**
- Structure sémantique : `/evenements/contact-impro-paris-2026-03-25`
- Pas d'IDs numériques exposés

### Accessibility Level

**Conformité :** WCAG 2.1 AA (standard légal France/EU)

**Exigences :**
- Contraste couleurs minimum 4.5:1 (texte normal), 3:1 (texte large)
- Navigation clavier complète (Tab, Enter, Esc)
- Labels ARIA sur éléments interactifs (filtres, boutons)
- Alt text descriptif sur toutes les images
- Structure sémantique HTML5 (header, nav, main, article, footer)
- Focus visible sur éléments interactifs

**Tests :**
- Lighthouse Accessibility score > 90
- Validation avec lecteur d'écran (NVDA ou VoiceOver)

### PWA Support

**Progressive Web App :**
- Manifest.json généré par Rails 8 (nom, icônes, couleurs)
- Service worker généré par Rails 8
- Installation sur écran d'accueil mobile (iOS et Android)

**Stratégie de cache :**
- **Network-first** pour le contenu HTML/JSON (toujours chercher la version serveur en premier)
- **Cache-busting automatique** : assets versionnés par Rails (fingerprinting)
- **Service worker auto-update** : détection nouvelle version → prompt utilisateur pour recharger
- **Pas de cache agressif** : évite que les utilisateurs gardent une vieille version après déploiement

**Fonctionnalités offline :** Non nécessaires pour le MVP. Le PWA permet uniquement l'installation comme app mobile, pas de cache offline.

**Gestion de version :**
- Service worker détecte les mises à jour automatiquement
- Message "Nouvelle version disponible" → bouton "Recharger" pour forcer le refresh
- Pas de cache persistant qui bloque les déploiements

**Justification :** Améliore l'expérience mobile (icône dédiée, lancement rapide) sans complexité de gestion offline ni problèmes de version coincée en cache.

### Real-Time Requirements

**Temps réel :** Non requis pour le MVP

**Justification :** Les ateliers sont planifiés à l'avance, pas de besoin d'instantanéité. Les utilisateurs consultent l'agenda pour planifier, pas pour réagir en temps réel. Simplifie l'architecture (pas de WebSocket).

**Mise à jour contenu :** Le scraping Solid Queue met à jour la base de données en arrière-plan. L'utilisateur voit les nouveaux ateliers au prochain refresh de page (comportement web standard acceptable).

## Functional Requirements

### Découverte et Consultation d'Événements

- **FR1:** Les visiteurs peuvent consulter l'agenda chronologique complet des ateliers de danse exploratoire
- **FR2:** Les visiteurs peuvent filtrer les événements par plage de dates
- **FR3:** Les visiteurs peuvent filtrer les événements par type (atelier, stage)
- **FR4:** Les visiteurs peuvent filtrer les événements par format (présentiel, en ligne)
- **FR5:** Les visiteurs peuvent filtrer les événements gratuits
- **FR6:** Les visiteurs peuvent basculer entre mode d'affichage clair et mode sombre
- **FR7:** Les visiteurs peuvent accéder aux informations détaillées d'un événement (titre, tags, heure, lieu, prix, animateur)
- **FR8:** Les visiteurs peuvent cliquer vers le site du professeur pour s'inscrire à un événement
- **FR9:** Le système masque par défaut les événements passés de l'affichage agenda
- **FR10:** Le filtre date applique par défaut une plage "aujourd'hui" à "aujourd'hui + 10 ans"
- **FR11:** Les visiteurs peuvent activer manuellement le filtre date pour afficher les événements passés dans la plage sélectionnée

### Engagement Utilisateur

- **FR12:** Les visiteurs peuvent s'inscrire à une newsletter par email
- **FR13:** Les visiteurs peuvent consulter le profil public d'un professeur

### Acquisition et Mise à Jour Automatisée du Contenu

- **FR14:** Le système peut scraper automatiquement les URLs de sites de professeurs selon un planning défini (toutes les 24h)
- **FR15:** Le système peut scraper les formats suivants en MVP : sites web HTML/HTTP classiques, Google Calendar, Helloasso
- **FR16:** Le système peut détecter les changements HTML entre deux versions d'une page scrapée
- **FR17:** Le système peut générer automatiquement des fiches événements à partir du contenu HTML scrapé
- **FR18:** Le système peut mettre à jour automatiquement les fiches événements existantes quand des changements sont détectés
- **FR19:** Le système peut enregistrer un journal des changements détectés lors du scraping
- **FR20:** Le système peut persister les événements générés dans une base de données

### Administration et Monitoring

- **FR21:** L'administrateur peut consulter les logs de scraping, parsing et erreurs
- **FR22:** L'administrateur peut ajouter manuellement de nouvelles URLs de professeurs à scraper
- **FR23:** L'administrateur peut associer des notes correctrices à une URL scrapée
- **FR24:** Le système peut lire les notes correctrices avant de parser chaque URL
- **FR25:** L'administrateur peut être alerté quand un problème de scraping/parsing est détecté

### Visibilité Professeurs

- **FR26:** Les professeurs peuvent consulter une page publique de statistiques associée à leur profil
- **FR27:** Le système peut tracker le nombre de consultations du profil d'un professeur
- **FR28:** Le système peut tracker le nombre de clics sortants vers le site d'un professeur
- **FR29:** Les professeurs peuvent accéder à leurs statistiques via une URL unique sans création de compte

### SEO et Découvrabilité

- **FR30:** Le système peut générer des balises meta uniques pour chaque page d'événement
- **FR31:** Le système peut générer un balisage Schema.org de type Event pour chaque atelier
- **FR32:** Le système peut générer des balises Open Graph pour optimiser les partages sociaux
- **FR33:** Le système peut générer un sitemap XML de tous les événements
- **FR34:** Le système peut servir des URLs sémantiques pour les événements

### Progressive Web App

- **FR35:** Les visiteurs peuvent installer l'application sur l'écran d'accueil de leur appareil mobile
- **FR36:** Le système peut détecter quand une nouvelle version de l'application est disponible
- **FR37:** Les visiteurs peuvent recharger l'application pour obtenir la dernière version

### Accessibilité

- **FR38:** Les visiteurs utilisant un clavier peuvent naviguer complètement dans l'interface
- **FR39:** Les visiteurs utilisant un lecteur d'écran peuvent accéder à tout le contenu et toutes les fonctionnalités
- **FR40:** Le système peut afficher des alternatives textuelles pour tout contenu visuel

### Gestion des Préférences

- **FR41:** Le système peut sauvegarder la préférence de mode d'affichage (clair/sombre) du visiteur

## Non-Functional Requirements

### Performance

- **NFR-P1:** Le First Contentful Paint (FCP) de l'agenda principal ne doit pas excéder 1,5 seconde sur connexion 4G
- **NFR-P2:** Le Time to Interactive (TTI) de l'agenda principal ne doit pas excéder 3 secondes sur connexion 4G
- **NFR-P3:** Le Largest Contentful Paint (LCP) de l'agenda principal ne doit pas excéder 2,5 secondes sur connexion 4G
- **NFR-P4:** L'application des filtres doit produire un résultat visible en moins de 500ms
- **NFR-P5:** Le chargement d'une page événement individuelle doit atteindre LCP en moins de 2 secondes sur connexion 4G

### Security & Privacy

- **NFR-S1:** Le système doit respecter les directives robots.txt de chaque site scrapé
- **NFR-S2:** Le système doit respecter le RGPD : consentement explicite pour newsletter, droit d'accès et de suppression des données
- **NFR-S3:** Les connexions HTTPS doivent utiliser TLS 1.3 minimum
- **NFR-S4:** Le scraping doit identifier le user-agent comme "3graces.community bot" avec email de contact

### Reliability & Availability

- **NFR-R1:** Le système automatisé de scraping doit fonctionner 7 jours consécutifs sans intervention manuelle (99% du temps sur période de 30 jours)
- **NFR-R2:** Les jobs de scraping échoués doivent être rejoués automatiquement avec stratégie de retry exponentiel (3 tentatives maximum)
- **NFR-R3:** Les erreurs critiques de scraping/parsing doivent déclencher une alerte email à l'administrateur en moins de 15 minutes
- **NFR-R4:** Le site public doit maintenir une disponibilité de 99,5% (downtime maximal : 3,6 heures/mois)
- **NFR-R5:** Les données scrapées doivent être sauvegardées quotidiennement avec rétention de 30 jours
- **NFR-R6:** Le système ne déclenche pas d'alerte immédiate pour une URL en erreur (404, timeout). Après 3 tentatives échouées consécutives lors de 3 cycles de scraping distincts, le système envoie une alerte email à l'administrateur
- **NFR-R7:** Le système conserve la dernière fiche événement connue en base de données même si l'URL source devient inaccessible

### Accessibility

- **NFR-A1:** L'interface doit atteindre un score Lighthouse Accessibility minimum de 90/100
- **NFR-A2:** Le contraste des couleurs doit respecter WCAG 2.1 AA : ratio minimum 4.5:1 pour texte normal, 3:1 pour texte large
- **NFR-A3:** Toutes les fonctionnalités interactives (filtres, toggle mode, boutons) doivent être accessibles via navigation clavier seul
- **NFR-A4:** Les lecteurs d'écran (NVDA, VoiceOver) doivent pouvoir lire l'intégralité du contenu sans blocage

### Integration & Automation

- **NFR-I1:** L'intégration avec Claude Code CLI headless doit traiter une URL scrapée en moins de 60 secondes (parsing + génération fiche)
- **NFR-I2:** Solid Queue doit orchestrer les jobs de scraping avec un délai maximum de 5 minutes entre détection de changement et mise à jour en base
- **NFR-I3:** Le système doit tolérer une indisponibilité temporaire de Claude Code CLI (jusqu'à 30 minutes) sans perte de données
- **NFR-I4:** Les notes correctrices par URL doivent être lisibles en moins de 100ms avant chaque parsing
- **NFR-I5:** Le système utilise exclusivement la timezone Europe/Paris pour tous les événements (scope France uniquement). Les timestamps sont stockés en base de données avec timezone Europe/Paris. Configuration Rails : `config.time_zone = "Europe/Paris"`
- **NFR-I6:** Les jobs de scraping s'exécutent automatiquement toutes les 24 heures via Solid Queue cron

**Note technique - Claude Code CLI Headless:**
- Claude Code CLI doit être invoqué avec le flag `--dangerously-skip-permissions` pour fonctionner en mode headless sans interactions utilisateur
- Le container Docker doit monter le volume `~/.claude:/root/.claude` pour persister l'authentification Claude entre redémarrages
- Les jobs Solid Queue doivent vérifier la validité du token d'authentification avant chaque invocation CLI

### Maintainability

- **NFR-M1:** Les logs de scraping, parsing et erreurs doivent être consultables pendant 90 jours minimum
- **NFR-M2:** Le code source doit être documenté avec README à jour et commentaires inline pour les workflows complexes (scraping, génération LLM)
- **NFR-M3:** Les déploiements doivent être reproductibles via Docker Compose sur tout serveur Linux headless

### Scalability

- **NFR-SC1:** Le système doit supporter l'ajout de 100 nouvelles URLs de professeurs sans dégradation de performance de scraping (temps de traitement par URL constant)
- **NFR-SC2:** L'affichage de l'agenda doit rester performant (LCP < 2,5s) avec jusqu'à 500 événements affichés simultanément
