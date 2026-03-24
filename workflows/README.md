# Corpus de workflows exportables — environnement n8n

## Objet

Ce répertoire regroupe des **exports JSON** destinés à être importés dans une instance n8n aux fins d'**enseignement**, de **démonstration** et de **tests de non-régression** fonctionnelle à l'échelle d'un atelier.

## Procédure d'importation

1. Ouvrir l'interface n8n (voir **`DEPLOY.md`** pour le déploiement).
2. Menu **Workflows** → **Import from File**.
3. Sélectionner le fichier `.json` approprié.
4. **Sauvegarder** le workflow, puis configurer les **Credentials** requis par les nœuds.

## Politique de gestion des secrets

Les fichiers JSON **ne doivent pas** contenir de clés API, jetons OAuth ni mots de passe. Toute authentification auprès des fournisseurs externes se configure **après import** via le sous-système **Credentials** de n8n.

## Archivage des travaux produits en formation

Après modification d'un workflow dans l'éditeur, il est recommandé d'**exporter** à nouveau le graphe vers ce répertoire (ou vers un dépôt **privé** institutionnel), en contrôlant l'absence de données sensibles dans les paramètres exportés.

## Fichiers livrés

| Fichier | Finalité |
|---------|----------|
| `wiseai-hello-starter.json` | Vérification minimale du déploiement : déclencheur manuel et nœud *Set* |
