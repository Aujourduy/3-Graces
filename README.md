# Stop & Dance - Agenda Danse Exploratoire

Rails 8 application for aggregating and displaying exploratory dance events in France.

## Prerequisites

* Ruby 3.3+
* PostgreSQL 16+
* Rails 8.1+

## Configuration

**Environment Variables:**

Copy `.env.example` to `.env` and set your production credentials before running the app:

```bash
cp .env.example .env
```

Edit `.env` with your actual credentials (never commit this file).

## Setup

```bash
bundle install
rails db:create db:migrate db:seed
```

## Running the Application

```bash
rails server
```

## Background Jobs

Development mode runs jobs inline (immediately). To test worker processes:

```bash
rails solid_queue:start
```

## Outils développement

- **Ctrl+Shift+D** : Mode debug design
  - Affiche les propriétés CSS au hover (balise, classes, couleurs, police, padding/margin, dimensions, contenu texte)
  - Infobulle centrée sur fond vert pistache
  - Outline terracotta autour de l'élément survolé
  - Disponible uniquement en development
