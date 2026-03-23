# 3 Graces — Projet BMAD

## Vision produit
Agenda de référence des pratiques de danse exploratoires et 
non-performatives en France.
"Quel atelier ce soir à Paris ?" — ce que Google et Facebook 
ne savent pas faire.

## URL
3graces.community

## Utilisateur cible
Danseurs occasionnels ou réguliers qui veulent découvrir de 
nouvelles pratiques. Ils explorent de temps en temps mais ne 
savent pas où chercher.
Interface read-only : consultation + filtres de recherche. 
Zéro CRUD utilisateur.

## Lien stratégique
3 Graces sert aussi de canal d'acquisition pour le programme 
de coaching "Du chaos au vivant" (Duy). Les visiteurs sont 
le public cible exact du coaching.

## Stack technique
- Rails 8 + PostgreSQL
- Solid Queue (cron + jobs — pas de n8n)
- Claude Code CLI headless (auth abonnement Pro, pas Claude API)
- Tailwind CSS
- Algolia (recherche + filtres — introduit après le core)
- Cloudinary (avatars profs, images — introduit après le core)
- Docker sur HP EliteDesk (serveur perso Linux headless)

## Architecture core
1. Liste d'URLs prédéfinie (profs avec avatar + bio)
2. Fetch HTML → diff avec version stockée → journal des 
   changements
3. Si diff détecté → Claude Code CLI rédige/met à jour la fiche
4. Résultat écrit en DB — zéro intervention manuelle
5. Solid Queue orchestre tout (cron + jobs)

## Pages UI

### Homepage
- Hero photo danse + texte de présentation
- Boutons CTA : Agenda, Publies tes ateliers, Actualités, 
  Qui est Duy, Me contacter, Donations

### Liste événements
- Chronologique par date
- Carte événement : heure · tags · titre · animé par · 
  lieu · prix
- Sidebar filtres (desktop) / panel dépliable (mobile)

### Fiche événement (modal)
- Carrousel photos
- Début / Fin / Durée
- Lieu + adresse complète
- Prix normal / Prix réduit
- Site web + email du prof
- Description longue

### Filtres
- Type : Atelier / Stage / En présentiel / En ligne / Gratuit
- À partir du (date)
- Lieu + "Moins de X km autour de (ville)"
  → Geocoding manuel, France uniquement
  → Permet de chercher dans une ville où on sera plus tard
  → Algolia Geo Search ou Google Maps Geocoding API

### "Publies tes ateliers"
- Formulaire de contact simple pour les pros
- Pas de CRUD — juste un email entrant

### Newsletter
- Inscription email simple

## Design
- Palette : Terracotta / orangé + beige + fond sombre
- Identité forte à conserver
- Mobile-first (maquettes iPhone 12 Pro)
- Desktop : sidebar filtres visible en permanence
- Mobile : panel filtres dépliable

## Décisions techniques prises
- Pas de compte utilisateur ni CRUD
- Pas de n8n — tout dans Rails natif (Solid Queue)
- Pas de Claude API payante — Claude Code CLI avec 
  abonnement Pro à 20$/mois
- Cowork écarté — GUI desktop, pas headless
- Algolia et Cloudinary introduits APRÈS que le core 
  fonctionne
- HP EliteDesk = serveur Linux headless sous Docker
- Claude Code CLI s'authentifie via claude auth login 
  avec le compte Pro

## Méthode de travail — BMAD
1. Brief ✅ (fait — conversation claude.ai 23/03/2026)
2. PRD → PM agent dans Claude Code
3. Architecture doc → Architect agent
4. Stories → Scrum Master agent
5. Exécution story par story en mode agent autonome

## Contraintes
- Duy = nouveau papa, dispo très limitée
- Objectif : maximum de travail sans lui
- Pour chaque décision, toujours évaluer :
  1. Ce qui peut se faire sans Duy
  2. Comment gagner du temps
  3. Comment réduire les coûts
  4. Comment être plus efficace

## Prochaine étape
```bash
rails new 3graces --database=postgresql
cd 3graces
git init && git add . && git commit -m "init"
npx bmad-method install
# Choisir Claude Code comme AI tool
```
Puis dans Claude Code :
```
bmad-help I just installed, what should I do first?
```
Puis lancer le PM agent → générer le PRD.

## Règle de fin de conversation
À chaque fin de conversation sur ce projet, proposer 
de mettre à jour les docs pour Claude Code (décisions, 
specs, architecture) à copier dans docs/ du repo.
