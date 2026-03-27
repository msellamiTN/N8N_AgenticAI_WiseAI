================================================================================
                         CAHIER D'ATELIER PÉDAGOGIQUE
================================================================================

Titre        Construction d'un système multi-agents responsable avec n8n
             Guide pratique illustré — niveau introductif

Formation    Atelier WiseAI
Responsable  Mokhtar Sellami
Période      Mars 2026
Version du document   1.1

================================================================================
RÉSUMÉ
================================================================================

Ce cahier constitue le support d'un atelier d'initiation à l'orchestration de
flux agentiques au moyen de la plateforme n8n, dans un environnement Windows
conteneurisé. Il formalise les objectifs d'apprentissage, la progression
pédagogique, les exigences de sécurité et de gouvernance minimales associées
à l'usage de modèles de langage de grande taille (LLM), ainsi que les critères
de validation. Les repères [ILLUSTRATION] signalent les emplacements réservés
aux figures dans la version éditoriale illustrée du manuscrit.

================================================================================
MOTS-CLÉS
================================================================================

Orchestration de workflows ; automatisation ; agents logiciels ; n8n ; Docker ;
intelligence artificielle responsable ; sécurité des API ; validation
fonctionnelle ; environnement Windows.

================================================================================
CADRE ET FINALITÉS
================================================================================

L'atelier s'inscrit dans une perspective de compétences « data-to-AI » : les
participants apprennent à structurer un problème sous forme de graphe
d'exécution, à intégrer des services d'IA générique via des interfaces
programmatiques, et à réduire les risques (fuite d'informations, abus,
hallucinations documentaires, dérive des coûts) par des mécanismes techniques et
organisationnels élémentaires. Les notions de transparence, de limites
fonctionnelles et de moindre privilège pour les identifiants secrets sont
traitées de manière explicite.

================================================================================
PUBLIC VISÉ ET PRÉREQUIS
================================================================================

Public visé
  - Étudiants de premier ou second cycle, professionnels en reconversion, ou
    toute personne disposant d'une culture informatique de base.

Prérequis
  - Notions élémentaires de systèmes d'exploitation (fichiers, réseau local).
  - Capacité à suivre des procédures en ligne de commande (PowerShell).
  - Aucun prérequis sur n8n ni sur les conteneurs ; la virtualisation et
    Docker sont introduits au fil du cahier.

================================================================================
MODALITÉS PÉDAGOGIQUES (INDICATIF)
================================================================================

Volume global indicatif : 8 à 12 heures de travail guidé, selon le rythme du
groupe et l'ampleur des projets de synthèse (capstones).

================================================================================
TABLE DES MATIÈRES
================================================================================
1. Préparation de l'environnement Windows
2. Installation et persistance de n8n sous Docker
3. Prise en main méthodique de l'interface n8n
4. Gestion des identifiants d'accès aux services externes
5. Conception d'un workflow multi-agents
6. Mécanismes de sécurité et cadre d'usage responsable
7. Protocole de tests et de validation
8. Travaux de synthèse guidés (capstones)
9. Diagnostic, dépannage et pistes d'optimisation
Annexe A — Glossaire
Annexe B — Liste de contrôle préalable à une mise en service locale
Annexe C — Ressources documentaires et référentiels (lectures)
Annexe D — Critères d'évaluation sommative (capstones)

================================================================================
1. PRÉPARATION DE L'ENVIRONNEMENT WINDOWS
================================================================================

Objectifs d'apprentissage (taxonomie opérationnelle)
  - Vérifier la compatibilité matérielle et logicielle de la station de travail.
  - Identifier les paramètres réseau pertinents pour l'exécution locale de n8n.

Durée indicative : 20 à 40 minutes

1.1 Exigences système et privilèges d'administration
  - Système d'exploitation : Windows 10 (build 22H2 ou ultérieur) ou Windows 11,
    de préférence à jour dans ses correctifs de sécurité.
  - Privilèges suffisants pour installer Docker Desktop et, le cas échéant,
    activer des fonctions de virtualisation.
  - Activation de la virtualisation matérielle (firmware BIOS/UEFI) si l'outil
    de diagnostic Docker l'exige.

1.2 Logiciels requis ou recommandés
  - Docker Desktop pour Windows — documentation officielle :
    https://docs.docker.com/desktop/
  - Outil de gestion de versions (Git), facultatif mais recommandé pour archiver
    les exports de workflows hors des canaux publics non sécurisés.
  - Navigateur Web récent (Edge, Chrome ou Firefox) pour l'interface graphique.

1.3 Vérification post-installation de Docker Desktop
  - Démarrer Docker Desktop et attendre l'état opérationnel (« Docker is
    running »).
  - Activer l'intégration WSL 2 lorsque l'assistant d'installation le propose.
  - Contrôler l'installation dans PowerShell, par exemple :
      docker --version
      docker run hello-world

1.4 Paramètres réseau
  - Le service n8n écoute par défaut sur le port TCP 5678 ; ce port doit être
    libre ou remplacé conformément à la procédure décrite dans DEPLOY.md.
  - Configurer le pare-feu Windows si les politiques de l'établissement ou de
    l'entreprise l'imposent.

1.5 Organisation du répertoire de travail
  - Créer un espace disque dédié aux artefacts de l'atelier, par exemple :
      D:\AtelierWiseAI\n8n-data
  - Y conserver ultérieurement les exports JSON des workflows et, le cas
    échéant, les sauvegardes de volume documentées dans DEPLOY.md.

[ILLUSTRATION : Docker Desktop en fonctionnement, numéros de version visibles]

================================================================================
2. INSTALLATION ET PERSISTANCE DE N8N SOUS DOCKER
================================================================================

Objectifs d'apprentissage
  - Déployer n8n dans un conteneur avec persistance des données applicatives.
  - Initialiser l'instance et le compte administrateur de premier accès.

Durée indicative : 25 à 45 minutes

2.1 Exécution ponctuelle en ligne de commande (pédagogie du conteneur)
  Les commandes suivantes illustrent le principe de volume nommé ; elles
  conviennent à une démonstration, mais ne remplacent pas la procédure Compose
  pour un usage récurrent.

  docker volume create n8n_data

  docker run -it --rm --name n8n_atelier -p 5678:5678 ^
    -v n8n_data:/home/node/.n8n ^
    n8nio/n8n

  Remarques méthodologiques :
  - Sous PowerShell, le caractère de continuation de ligne peut être l'accent
    grave (`) plutôt que l'accent circonflexe (^).
  - L'option --rm recycle le conteneur à l'arrêt : à éviter lorsque l'on
    souhaite conserver un identifiant de conteneur stable entre sessions.

2.2 Accès à l'interface d'administration
  - URI par défaut : http://localhost:5678
  - Lors de la première connexion, créer le compte « owner » conformément aux
    politiques locales de gestion des mots de passe.

2.3 Persistance des données
  - Le volume Docker associé au chemin /home/node/.n8n conserve workflows,
    paramètres et métadonnées de chiffrement des secrets applicatifs.
  - Toute suppression non maîtrisée du volume entraîne une perte irréversible des
    configurations, sauf restauration préalable.

2.4 Déploiement structuré par Docker Compose (recommandé)
  Le dépôt fournit une chaîne de déploiement documentée :
  - docker-compose.yml   Déclaration du service, volume persistant, contrôle
                          d'intégrité (healthcheck)
  - .env.example         Modèle de variables ; recopier vers .env et renseigner
                          notamment N8N_ENCRYPTION_KEY pour la stabilité du
                          déchiffrement des identifiants stockés
  - DEPLOY.md            Procédure complète (démarrage, import, sauvegarde,
                          exposition des webhooks, résolution d'incidents)
  - workflows/*.json     Jeux d'exemple importables dans l'éditeur

  Séquence type (racine du projet, invite PowerShell) :
    copy .env.example .env
    (édition du fichier .env)
    docker compose pull
    docker compose up -d

  URL d'accès : http://localhost:<N8N_PORT> selon la variable N8N_PORT.

[ILLUSTRATION : Écran d'accueil n8n après création du compte propriétaire]
[ILLUSTRATION : Sortie de docker ps listant le conteneur n8n]

================================================================================
3. PRISE EN MAIN MÉTHODIQUE DE L'INTERFACE N8N
================================================================================

Objectifs d'apprentissage
  - Identifier les modules fonctionnels : conception de workflows, historique
    d'exécution, gestion des identifiants, paramètres d'instance.
  - Analyser le passage des données structurées (items JSON) entre nœuds.

Durée indicative : 45 à 60 minutes

3.1 Architecture fonctionnelle de l'interface
  - Éditeur de workflows : représentation graphique du graphe d'exécution.
  - Registre des exécutions : traçabilité des statuts, durées et erreurs.
  - Gabarits (templates) : sources d'inspiration à réviser systématiquement
    avant adoption en contexte sensible.

3.2 Concepts fondamentaux
  - Nœud : unité élémentaire de traitement (déclenchement, transformation,
    interopérabilité réseau, etc.).
  - Arête (connexion) : canal de transmission des sorties d'un nœud vers les
    entrées d'un autre.
  - Item : unité logique de données, le plus souvent sérialisée en JSON.

3.3 Stratégies de déclenchement
  - Déclencheur manuel : approprié à l'apprentissage et aux essais contrôlés.
  - Déclencheurs événementiels (webhooks, planification, messagerie) : étudiés
    après maîtrise du cycle d'exécution manuel.

3.4 Inspection des jeux de données
  - Après exécution d'essai, examiner les charges utiles en entrée et en sortie
    de chaque nœud.
  - Les expressions (par ex. {{ $json.champ }}) formalisent le chaînage des
    champs entre étapes.

3.5 Règles de lisibilité et d'ingénierie logicielle légère
  - Attribuer aux nœuds des libellés sémantiques (ex. Agent_Redacteur,
    Garde_TailleEntree).
  - Versionner les exports JSON via un mécanisme approprié (dépôt privé,
    stockage institutionnel), en l'absence de secrets en clair.

Travaux dirigés — Séquence « Hello »
  - Composer un workflow minimal : déclencheur manuel, nœud Set, nœud de
    terminaison ou réponse HTTP selon la configuration pédagogique.
  - Exécuter le scénario et interpréter la structure JSON produite.

[ILLUSTRATION : Toile d'édition avec deux ou trois nœuds connectés]
[ILLUSTRATION : Panneau d'inspection JSON post-exécution]

================================================================================
4. GESTION DES IDENTIFIANTS D'ACCÈS AUX SERVICES EXTERNES
================================================================================

Objectifs d'apprentissage
  - Configurer les secrets via le sous-système Credentials de n8n.
  - Appliquer le principe du moindre privilège et planifier la rotation des clés.

Durée indicative : 30 minutes

4.1 Emplacement de configuration
  - Menu Credentials ou assistant intégré au nœud consommateur.
  - Sélection du connecteur adapté : fournisseur LLM, authentification HTTP,
    schéma générique, etc.

4.2 Fournisseurs couramment mobilisés en formation
  - API compatibles OpenAI (point de terminaison et jeton d'accès).
  - Azure OpenAI (URL de déploiement, clé, version d'API — conformément au
    modèle de ressource provisionné).
  - Autres fournisseurs (Anthropic, Mistral, etc.) selon les conventions du
    programme de formation.

4.3 Politique de protection des secrets
  - Interdiction de coder en dur des jetons dans les paramètres exportables ou
         sur des supports de capture d'écran diffusés.
  - Interdiction de publier sur des dépôts ouverts des exports contenant des
    identifiants actifs.
  - En cas de divulgation accidentelle : révocation immédiate et émission.

4.4 Protocole de vérification « end-to-end » réduit
  - Mettre en œuvre un appel minimal au fournisseur (requête de service ou nœud
    d'inférence léger) avant l'intégration d'une architecture multi-agents.

[ILLUSTRATION : Écran Credentials, champs sensibles masqués]

================================================================================
5. CONCEPTION D'UN WORKFLOW MULTI-AGENTS
================================================================================

Objectifs d'apprentissage
  - Décomposer une tâche en rôles aux interfaces d'entrée-sortie contractuelles.
  - Mettre en œuvre le routage, la composition séquentielle et la fusion de
    résultats.

Durée indicative : 90 à 120 minutes

5.1 Définition opérationnelle de l'« agent » dans n8n
  Sous réserve des limites de la plateforme, un agent est modélisé ici comme
  un sous-graphe caractérisé par :
  - une consigne de rôle (prompt système ou instructions équivalentes),
  - des entrées explicitement bornées,
  - une sortie structurée exploitable par les étapes aval.

5.2 Patron architectural de référence

  [Entrée utilisateur]
        → [Normalisation / validation]
        → [Routeur d'intentions]
        → [Agent A] ─┐
        → [Agent B] ─┼→ [Synthèse / livrable final]
        → [Agent C] ─┘

5.3 Patrons d'orchestration
  - Routage déterministe ou assisté par LLM : nœuds Switch, IF, ou classification
    légère.
  - Chaînage séquentiel : la sortie d'un agent constitue l'entrée du suivant
    (attention aux coûts d'inférence et à l'accumulation d'erreurs).
  - Parallélisation contrôlée : branches concurrentes suivies d'une étape de
    fusion (Merge, Code).

5.4 Cadrage éthique et qualitatif des invites (prompts)
  - Prévoir des refus explicites hors périmètre (données personnelles, sujets
    réglementés lorsque applicable).
  - Exiger la distinction entre connaissance étayée et hypothèse ; éviter la
    fabrication de faits lorsque l'agent n'est pas outillé pour la vérification.
  - Lorsque des outils de recherche sont connectés : exiger citation ou
    aveu d'insuffisance documentaire.

5.5 Patron minimal viable (énoncé pour mise en œuvre pratique)
  (1) Déclencheur manuel — variable « question » (chaîne).
  (2) Normalisation — borne de longueur ; rejet ou troncature documentée.
  (3) Nœud LLM — agent « Analyste » : structuration de la demande et plan.
  (4) Nœud LLM — agent « Rédacteur » : production à partir du plan, sans
      enrichissement factuel non sourcé.
  (5) Livraison — affichage local ou réponse HTTP selon le dispositif pédagogique.

[ILLUSTRATION : Schéma logique routeur et trois agents]
[ILLUSTRATION : Capture partielle d'export JSON sans métadonnées sensibles]

================================================================================
6. MÉCANISMES DE SÉCURITÉ ET CADRE D'USAGE RESPONSABLE
================================================================================

Objectifs d'apprentissage
  - Identifier et atténuer les risques usuels : abus, exfiltration, actions
    irréversibles non supervisées.

Durée indicative : 45 à 60 minutes

6.1 Confinement des entrées
  - Limitation de longueur et de complexité ; filtres lexicaux ou motifs pour
    les patterns d'injection grossiers.
  - Gestion du débit (file d'attente, secret de webhook) lorsque l'instance est
    exposée au réseau.

6.2 Gouvernance des jetons d'API
  - Jeux d'identifiants dédiés à la formation, budgets et quotas restreints.
  - Séparation stricte entre environnements d'essai et de production.

6.3 Données à caractère personnel et journalisation
  - Minimiser la conservation de journaux contenant des contenus utilisateurs.
  - Anonymiser les jeux de données pédagogiques.

6.4 Supervision humaine (human-in-the-loop)
  - Pour les actions à effets externes (messagerie, publication, transactions),
    insérer une étape d'approbation lorsque le contexte organisationnel l'exige.

6.5 Alignement sur les principes d'intelligence artificielle digne de confiance
  - Transparence vis-à-vis de l'utilisateur final sur la nature générative de la
    réponse.
  - Vigilance face aux biais et aux stéréotypes dans la formulation des invites.
  - Réduction de la surface d'attaque aux injonctions de contournement (prompt
    injection) par séparation stricte des instructions système et des données
    utilisateur.

[ILLUSTRATION : Branche conditionnelle « garde taille » et chemin d'erreur]

================================================================================
7. PROTOCOLE DE TESTS ET DE VALIDATION
================================================================================

Objectifs d'apprentissage
  - Élaborer une batterie de cas reproductibles et des critères d'acceptation.

Durée indicative : 45 minutes

7.1 Jeux d'épreuves minimaux
  - Cas nominal : requête courte conforme au domaine déclaré.
  - Cas limites : entrée vide, volumineuse, comportant des caractères spéciaux.
  - Cas de refus : requête manifestement hors champ ou soumise à politique de
    rejet.

7.2 Critères d'acceptation
  - Exactitude ou refus explicite conforme aux spécifications.
  - Temps de réponse compatible avec le cas d'usage (mesuré via l'interface
    d'exécution).
  - Absence d'erreurs d'authentification ou de quota sur une série d'exécutions
    contrôlées.

7.3 Revue détaillée des traces d'exécution
  - Pour chaque cas, inspecter successivement les nœuds et les transformations
    intermédiaires.

7.4 Perspectives d'automatisation externe
  - Les appels HTTP automatisés vers un webhook n8n peuvent constituer une suite
    de non-régression ; ce niveau dépasse l'objectif strictement introductif.

[ILLUSTRATION : Liste des exécutions filtrée par statut]

================================================================================
8. TRAVAUX DE SYNTHÈSE GUIDÉS (CAPSTONES)
================================================================================

Modalité : chaque capstone représente environ 1 à 2 heures de travail autonome
supervisé. Livrables attendus : export JSON du workflow, brève notice
méthodologique (objectif, prérequis, limites connues, jeux de test).

Capstone A — Système question-réponse sur corpus interne
  - Entrée : interrogation portant sur un texte de référence injecté en amont.
  - Agents : extraction de passages pertinents ; formulation de réponse courte.
  - Garde-fous : refus lorsque la question excède la couverture documentaire.

Capstone B — Routage taxonomique de demandes
  - Entrée : message utilisateur non structuré.
  - Agent classifieur : catégories prédéfinies (ex. incident technique,
    facturation, autre).
  - Traitement : branchement vers des modèles de réponse spécialisés et voie
    par défaut.

Capstone C — Synthèse prudentielle
  - Entrée : texte non confidentiel fourni dans le cadre de l'atelier.
  - Sortie : résumé accompagné d'une liste explicite des « zones d'incertitude »
    imposée par consigne.
  - Contrôle : borne de taille en entrée obligatoire.

[ILLUSTRATION : Aperçu partiel d'exports JSON (secrets exclus)]

================================================================================
9. DIAGNOSTIC, DÉPANNAGE ET PISTES D'OPTIMISATION
================================================================================

9.1 Défaillance du moteur Docker
  - Contrôler la virtualisation, redémarrer l'hôte si nécessaire, appliquer les
    mises à jour de Docker Desktop.

9.2 Indisponibilité du service HTTP local
  - Vérifier l'état du conteneur (docker ps), le mappage des ports et l'absence
    de conflit avec un autre service.

9.3 Erreurs d'authentification auprès du fournisseur d'IA
  - Renouveler les jetons, contrôler les points de terminaison, les quotas et
    l'état de facturation ou de provisionnement.

9.4 Performances et coûts d'inférence
  - Réduire le nombre d'appels LLM, fusionner les étapes redondantes, affecter
    un modèle de moindre envergure aux tâches de routage, envisager la mise en
    cache pour des requêtes strictement idempotentes.

9.5 Dérives comportementales du modèle
  - Renforcer les consignes, ajuster les hyperparamètres exposés (température),
    introduire des garde-fous postérieurs à l'inférence.

9.6 Perte de données après redémarrage
  - Confirmer l'attachement à un volume Docker persistant et l'absence d'option
    --rm incompatible avec la conservation de l'état.

Principe méthodologique : mesurer avant d'optimiser (latences médianes, coût par
requête nominale).

[ILLUSTRATION : Message d'erreur fournisseur intégré dans l'interface n8n]

================================================================================
ANNEXE A — GLOSSAIRE
================================================================================
  Workflow           Graphe orienté d'activités automatisées.
  Déclencheur        Événement initiant une exécution.
  Item               Portion de données, généralement encodée en JSON.
  Credential         Secret géré par le magasin d'identifiants de la plateforme.
  LLM                Grand modèle de langage accessible par API.
  Garde-fou          Mécanisme technique ou linguistique de limitation du risque.

================================================================================
ANNEXE B — LISTE DE CONTRÔLE PRÉALABLE À UNE MISE EN SERVICE LOCALE
================================================================================
  [ ] Volume Docker sauvegardé ou procédure de sauvegarde rédigée
  [ ] Absence de secrets en clair dans les nœuds, exports et captures
  [ ] Garde-fous d'entrée (taille, domaine fonctionnel) en service
  [ ] Batterie de tests manuels exécutée (au minimum cinq cas)
  [ ] Comportement de refus vérifié et documenté
  [ ] Estimation du coût d'inférence pour le scénario nominal
  [ ] Procédure d'installation (version n8n, commandes Docker) à jour

================================================================================
ANNEXE C — RESSOURCES DOCUMENTAIRES ET RÉFÉRENTIELS (LECTURES)
================================================================================

Documentation technique
  - Documentation officielle n8n (hébergement, Docker, variables) :
    https://docs.n8n.io/
  - Documentation Docker Desktop pour Windows :
    https://docs.docker.com/desktop/

Cadres normatifs et guides de bonnes pratiques (lecture de cadrage)
  - Commission européenne — éthique et législation pertinentes à l'IA :
    https://digital-strategy.ec.europa.eu/en/policies/european-approach-artificial-intelligence
  - ISO/IEC 42001 — systèmes de management de l'IA (référence institutionnelle).

Les URL ont vocation à être vérifiées au moment de l'édition du support ; les
référentiels évoluent indépendamment de ce document.

================================================================================
ANNEXE D — CRITÈRES D'ÉVALUATION SOMMATIVE (CAPSTONES)
================================================================================

Pour chaque travail de synthèse, une grille type peut retenir :
  - Cohérence architecturale du graphe (séparation des rôles, lisibilité).
  - Pertinence des garde-fous et respect du principe de minimisation des données.
  - Rigueur du protocole de test (cas nominal, limites, refus).
  - Qualité de la notice méthodologique et traçabilité des limitations.

================================================================================
FIN DU DOCUMENT — Support textuel ; version illustrée : substituer les
repères [ILLUSTRATION] par les figures numérotées du polycopié ou du LMS.
================================================================================
