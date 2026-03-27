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

**Solution :** Une interface web simple (read-only) où l'utilisateur ouvre le site et voit immédiatement l'agenda complet des ateliers disponibles. Recherche par mots-clés, filtres par plage de temps et localisation pour planifier des déplacements et organiser des "tournées danse".

**Vision future :** Dans 1-2 ans, les danseurs explorateurs en France sauront que TOUTES les propositions de danse exploratoires et non-performatives sont sur Stop & Dance. C'est le réflexe automatique pour trouver quoi faire.

**Objectif stratégique secondaire :** Stop & Dance sert de canal d'acquisition pour le programme de coaching "Du chaos au vivant" (Duy), les visiteurs étant le public cible exact du coaching.

### Ce qui rend ce produit spécial

**Exhaustivité automatisée :** Architecture unique basée sur scraping automatisé + génération de contenu par LLM (Claude Code CLI headless). Le système scrape les sites des profs, détecte les changements via diff HTML, et génère/met à jour automatiquement les fiches événements. Orchestration complète via Solid Queue dans Rails 8. Zéro intervention manuelle.

**Simplicité d'usage immédiate :** Pas de compte utilisateur, pas de CRUD. L'utilisateur ouvre le site → tout l'agenda est là. Recherche intuitive + filtres pour planifier à l'avance.

**Curation spécialisée :** Focus exclusif sur les pratiques exploratoires et non-performatives. Ce que les plateformes généralistes (Google, Facebook, Eventbrite) ne savent pas identifier ni présenter clairement.

**Efficacité opérationnelle :** Conçu pour fonctionner avec un minimum d'intervention humaine (créateur = nouveau papa avec disponibilité très limitée). L'automatisation maximale permet de maintenir l'exhaustivité sans effort.

## Classification du Projet

**Type de projet :** Web App (application web Rails 8 + PostgreSQL, interface responsive mobile-first)

**Domaine :** Général (événements culturels / danse)

**Complexité :** Medium
- Architecture technique sophistiquée (scraping automatisé, orchestration de jobs, intégration LLM)
- Pas de régulations lourdes ni de compliance critique
- Workflows d'automatisation complexes mais domaine métier standard

**Contexte projet :** Greenfield (nouveau projet construit depuis zéro)

## Success Criteria

### User Success

Le succès utilisateur se mesure au moment où l'utilisateur trouve un atelier qui l'intéresse et clique vers le site du prof pour s'inscrire. L'utilisateur a résolu son problème : il a trouvé facilement une pratique de danse exploratoire qui correspond à ses critères (date, lieu, type).

**Métrique clé :** Taux de clics sortants (pourcentage de visiteurs qui cliquent vers le site d'un prof).

### Business Success

**Métriques d'engagement :**
- Nombre de visiteurs uniques par mois
- Taux de clics sortants vers les profs
- Nombre de profs référencés dans la base

**Objectif stratégique :** Stop & Dance devient un canal d'acquisition viable pour le programme de coaching "Du chaos au vivant", les visiteurs étant le public cible exact.

### Technical Success

Le système automatisé est considéré comme fiable quand :
- **Autonomie opérationnelle :** Le système tourne 7 jours consécutifs sans intervention manuelle
- **Exactitude des données :** Les fiches générées par Claude Code CLI contiennent des dates/lieux/prix corrects (95%+ d'exactitude)
- **Fiabilité du scraping :** Le journal de diff ne montre aucune erreur silencieuse (changements non détectés, parsing échoué)

### Measurable Outcomes

**3-6 mois après lancement :**
- Le site référence un nombre significatif de profs de danse exploratoire en France
- Les visiteurs cliquent régulièrement vers les sites des profs
- Le système automatisé fonctionne de manière autonome sans nécessiter d'intervention quotidienne
- Les danseurs commencent à considérer Stop & Dance comme une référence pour trouver des ateliers

## Product Scope

### MVP - Minimum Viable Product

**Fonctionnalités obligatoires pour prouver le concept :**

**Automatisation core :**
- Liste d'URLs prédéfinie de profs avec avatar + bio
- Scraping HTML automatisé via Solid Queue (cron + jobs)
- Détection de changements via diff avec version stockée
- Génération/mise à jour automatique des fiches par Claude Code CLI headless
- Journal des changements détectés
- Écriture en base de données PostgreSQL

**Interface utilisateur :**
- Affichage agenda chronologique des événements
- Carte événement : heure · tags · titre · animé par · lieu · prix
- Filtres de base : date, type (atelier/stage), présentiel/en ligne, gratuit
- Interface responsive mobile-first (design terracotta/orangé + beige + fond sombre)

**Engagement utilisateur :**
- Newsletter : inscription email simple

**Stack technique MVP :**
- Rails 8 + PostgreSQL
- Solid Queue (orchestration cron + jobs)
- Claude Code CLI headless (abonnement Pro, pas Claude API)
- Tailwind CSS
- Docker sur serveur HP EliteDesk (Linux headless)

### Growth Features (Post-MVP)

**Fonctionnalités compétitives à introduire après validation du concept :**

**Recherche avancée :**
- Recherche par mots-clés dans barre de recherche (Algolia)
- Géolocalisation "Moins de X km autour de (ville)" via Geocoding API (Algolia Geo Search ou Google Maps)
- Permet de planifier des déplacements et organiser une "tournée danse"

**Médias optimisés :**
- Cloudinary pour avatars profs et images événements optimisées

**Engagement pros :**
- Formulaire "Publies tes ateliers" (contact simple pour les pros, pas de CRUD)

### Vision (Future)

**État futur à 1-2 ans :**
- Stop & Dance est LA référence exhaustive reconnue pour les pratiques de danse exploratoires et non-performatives en France
- Les danseurs ont le réflexe automatique : "Je cherche un atelier exploratoire → je vais sur Stop & Dance"
- Le système fonctionne de manière totalement autonome avec un minimum d'intervention humaine
- Canal d'acquisition établi et efficace pour le coaching "Du chaos au vivant"

## User Journeys

### Journey 1 : Danny, le Danseur Explorateur (Prioritaire)

**Persona :** Danny, 40 ans, salarié à Paris. Il pratique le développement personnel et cherche à bouger son corps de manière connectée à son être. Ouvert au bien-être.

**Situation :** Danny veut explorer des pratiques de danse mais les infos sont très éparpillées. Pas d'annuaire ni d'agenda global. La nomenclature est floue (danse ecstatique vs noms similaires). Google le renvoie sur des pages à fort trafic mais pas pertinentes (dates passées, mauvais ciblage).

**Parcours :**
- **Découverte :** Via Google ("atelier danse libre Paris ce weekend") ou bouche à oreille
- **Arrivée sur Stop & Dance :** Filtre par date et lieu d'abord, puis par type
- **Préférence visuelle :** Peut basculer entre mode clair et mode sombre selon son confort (utilise souvent le site le soir)
- **Climax :** En moins de 2 minutes, il a trouvé un atelier qui l'intéresse
- **Action :** Il clique vers le site du prof pour s'inscrire
- **Engagement :** S'inscrit à la newsletter pour rester informé

**Résolution :** Danny explore de nouvelles pratiques qu'il n'aurait jamais trouvées seul. Il revient sur Stop & Dance quand l'envie d'explorer se manifeste — pas forcément chaque semaine, mais c'est son réflexe. Il recommande le site à des amis dans la même situation. Parfois il découvre un atelier de Duy et ça l'amène vers "Du chaos au vivant".

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

---

### Journey Requirements Summary

**Capacités révélées par les journeys :**

**Journey Danny (Danseur) :**
- Affichage agenda chronologique
- Filtres : date, lieu, type (atelier/stage), présentiel/en ligne, gratuit
- Recherche par mots-clés (post-MVP)
- Clics sortants trackés vers sites profs
- Newsletter : inscription email simple (MVP) / contenu éditorial (post-MVP)
- Interface mobile-first responsive
- Toggle mode clair/sombre (préférence utilisateur sauvegardée)

**Journey Admin (Duy) :**
- Journal de logs clair (scraping, parsing, erreurs)
- Gestion manuelle d'URLs à scraper
- Système de notes correctrices par URL scrapée (fichier texte simple)
- Claude Code CLI lit les notes avant parsing de chaque URL
- Monitoring autonome (alerte si problème)
- Mode sombre pour consultation logs tard le soir

**Journey Prof (Marc) :**
- Scraping automatique des URLs prof
- Page stats publique par prof (consultations + clics sortants)
- URL unique type `/profs/nom-du-prof/stats`
- Pas de compte requis pour consulter les stats
- Toggle mode clair/sombre sur page stats

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

**Optimisations essentielles :**

**Balises meta par page :**
- Title unique et descriptif (< 60 caractères)
- Meta description (< 160 caractères)
- Canonical URL

**Schema.org markup :**
- Type `Event` pour chaque atelier
- Propriétés : name, startDate, endDate, location, organizer, price
- Permet affichage enrichi dans Google Search

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

