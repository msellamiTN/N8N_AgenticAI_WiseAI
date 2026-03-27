# Guide technique de déploiement — plateforme n8n (WiseAI)

## Objet et champ d'application

Ce document décrit la procédure standardisée pour déployer une instance **n8n** en environnement local ou pédagogique, à l'aide de **Docker Compose**, avec persistance des données et paramètres de sécurité de base. Il complète le cahier d'atelier (**`doc.m`**) sur le plan opérationnel.

**Environnement cible :** Microsoft Windows avec Docker Desktop ; la procédure est transposable sous Linux ou macOS sous réserve d'adapter les chemins et interpréteurs de commandes.

**Non couvert par le présent guide :** hébergement en haute disponibilité, authentification unique institutionnelle (SSO), chiffrement TLS de bout en bout en production, et politiques réseau avancées. Ces sujets relèvent d'une ingénierie infrastructure dédiée.

## Hypothèses et prérequis

1. **Docker Desktop** installé, démarré et validé selon la [documentation officielle Docker](https://docs.docker.com/desktop/).
2. Accès à une invite **PowerShell** (ou équivalent) positionnée sur le répertoire racine du projet.
3. **Disponibilité du port TCP** configuré pour l'hôte (valeur par défaut : `5678`), ou capacité à modifier `N8N_PORT` dans le fichier d'environnement.

## Artéfacts du dépôt

| Artéfact | Description |
|----------|-------------|
| `docker-compose.yml` | Spécification du service n8n, volume nommé, contrôle d'état (healthcheck) |
| `.env.example` | Modèle de variables d'environnement ; ne contient aucun secret |
| `.env` | Fichier opérationnel à créer localement ; **exclu du contrôle de version** |
| `workflows/` | Corpus d'exports JSON importables dans l'interface graphique |
| `doc.m` | Cadre pédagogique, sécurité responsable et validation |

## Phase 1 — Préparation du fichier d'environnement

Exécuter à la racine du projet :

```powershell
cd "d:\Data2AI Academy\N8N_AgenticAI_WiseAI"
copy .env.example .env
```

Ouvrir **`.env`** dans un éditeur de texte et renseigner **`N8N_ENCRYPTION_KEY`** avec une valeur aléatoire d'entropie suffisante (recommandation : au moins 32 octets encodés, par exemple en Base64). Cette clé conditionne la cohérence du déchiffrement des identifiants stockés dans la base applicative de n8n ; son absence ou son alteration entre recréations de volume peut rendre les secrets existants **irrécupérables**.

**Exemple de génération (PowerShell) :**

```powershell
[Convert]::ToBase64String((1..32 | ForEach-Object { Get-Random -Maximum 256 }))
```

Insérer la chaîne obtenue après `N8N_ENCRYPTION_KEY=` sans guillemets ni espaces superflus.

## Phase 2 — Instanciation de la pile logicielle

```powershell
docker compose pull
docker compose up -d
```

**Vérification du statut :**

```powershell
docker compose ps
docker compose logs -f n8n
```

La combinaison **Ctrl+C** interrompt uniquement le flux de journalisation ; le conteneur poursuit son exécution.

## Phase 3 — Accès à l'interface d'administration

1. Saisir dans le navigateur : **`http://localhost:<N8N_PORT>`** (port défini dans `.env`, `5678` par défaut).
2. Lors de la **première connexion**, enregistrer les identifiants du compte propriétaire conformément aux règles locales de complexité et de conservation.

## Phase 4 — Import des workflows fournis

1. Dans n8n : **Workflows** → **Import from File** (ou menu équivalent).
2. Sélectionner un fichier **`.json`** sous `workflows/`.
3. **Enregistrer** le workflow, puis lancer une exécution d'essai sur le déclencheur manuel lorsque celui-ci est présent.

**Remarque méthodologique :** les exports JSON **n'intègrent pas** les secrets. Après import, configurer explicitement les **Credentials** (fournisseurs LLM, HTTP, etc.).

## Phase 5 — Exposition des webhooks hors poste local (facultatif)

Pour générer des URL de webhook valides depuis des clients distants :

- Fixer **`N8N_HOST`** au nom d'hôte ou à l'adresse IP joignable.
- En présence d'un **reverse proxy** ou d'un tunnel **HTTPS**, renseigner **`WEBHOOK_URL`** avec l'URL publique de base conforme à la configuration n8n retenue.

En l'absence de ces réglages, les scénarios **strictement locaux** (déclencheur manuel, webhooks sur `localhost`) demeurent fonctionnels pour l'enseignement en salle.

## Référentiel de commandes

| Opération | Commande |
|-----------|----------|
| Arrêt temporaire | `docker compose stop` |
| Relance | `docker compose up -d` |
| Déconstruction des conteneurs (volume **conservé**) | `docker compose down` |
| Inspection du volume nommé | `docker volume inspect wiseai_n8n_data` |

**Avertissement :** la commande `docker compose down -v` **détruit** le volume nommé ; elle entraîne la perte des workflows et des métadonnées de secrets chiffrés. Elle ne doit être employée qu'après **sauvegarde** ou en contexte entièrement jetable.

## Stratégie de sauvegarde (atelier ou pré-exploitation)

1. Exporter périodiquement chaque workflow au format JSON vers un répertoire sécurisé (par ex. `workflows/sauvegardes/`).
2. Documenter la procédure d'archivage du volume Docker lorsque les données revêtent une valeur autre que purement pédagogique.

**Exemple d'archive du répertoire applicatif monté dans le volume :**

```powershell
docker run --rm -v wiseai_n8n_data:/source -v ${PWD}/backup-n8n:/backup alpine tar czf /backup/n8n-home.tar.gz -C /source .
```

La restauration s'effectue par extraction inverse dans un volume ad hoc.

## Diagnostic succinct

| Symptôme | Piste d'analyse |
|----------|------------------|
| Conflit de port | Modifier `N8N_PORT` dans `.env`, puis `docker compose up -d` |
| Conteneur signalé « unhealthy » | Attendre la fin de `start_period` ; analyser `docker compose logs n8n` |
| Secrets illisibles après recréation | Vérifier l'identité de `N8N_ENCRYPTION_KEY` et du volume sous-jacent |
| Référence d'image | Ce dépôt pointe vers `docker.n8n.io/n8nio/n8n` (registre documenté par l'éditeur) |

## Référence croisée

Pour les objectifs d'apprentissage, l'architecture multi-agents, le cadre d'IA responsable et les critères de validation, consulter **`doc.m`**.
