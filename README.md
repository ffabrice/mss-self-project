# MSSS Projet - S.E.L.F. Automatisation de VPN

* **S**.andie VAN HULLE 
* **E**.ric BADELLON
* **L**.ionel GIRARD 
* **F**.abrice FIQUEMO

## mss-self-project

### Quickstart
Pour lancer le projet, lancer le script shell setup.sh :
 
    sh ./setup.sh

Prérequis : les comptes AWS et OVH doivent être configurés avec les commandes suivantes :

AWS : 

    aws configure sso
 
OVH : (le fichier openrc.sh est téléchargeable depuis l'interface web OVH, menu Project Management -> Users & Roles puis pour le user choisi ... Download OpenStack's RC file) :

    source openrc.sh

Pour supprimer les ressources apres utilisation :
  
      sh ./menage.sh


----------------

### Schéma de l'architecture 

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/280267343-bab5cd6b-dba5-4b11-aa37-6825e1cad9b8.png)

Pour notre projet, nous avons souhaité automatiser au maximum les étapes de création de notre architecture.

----------------

### setup.sh
Pour se faire, nous avons créé un fichier **setup.sh** qui permet de faire des vérifications de versions d’AWS, de Terraform, de Python et d’Ansible, de vérifier que les credentials AWS et OVH sont bien présents avant de lancer le Terraform qui permettra l’orchestration des déploiements des modules pour la création de l’architecture retenue. 

Une tentative d'utiliser Terraform pour cette partie avait été envisagée mais Terraform étant très déclaratif, il était donc dangereux de l'utiliser pour faire les vérifications et arrêter le process suivant des conditions. Donc, cette solution a été abandonnée pour conserver le script shell.

Les pré-requis logiciels nécessaires sont les suivants :
* AWS CLI installé, vérification : aws --version
* Terraform installé, vérification : terraform --version
* Python installé, vérification : python3 --version
* Ansible installé, vérification : ansible --version

Les pré-requis de configuration sont les suivants :
* Credentials AWS CLI configurés, vérification : aws sts get-caller-identity
* Credentials OVH configurés, vérification : les variables d'environnement suivantes doivent être correctement initialiées : ceci est réalisé avec le fichier openrc.sh téléchargé depuis l'interface web ovh et exécuté

Si tous ces pré-requis ne sont pas satisfaits, le **setup.sh** ne pourra pas s'exécuter comme attendu jusqu'au bout.

Pour déployer notre architecture, veuillez exécuter le script **setup.sh** et saisir "yes" lorsque cela vous est demandé ET que les informations affichées vous semblent cohérentes.

----------------

### main.tf

Le fichier main.tf permet d’orchestrer le déploiement des différents modules Terraform qui permettront de déployer un service VPN inter cloud entre un VPC AWS et un Cloud Public OVH de manière automatisée.

Ce fichier est construit de la manière suivante : 

* **Une partie pour créer l’instance OVH**

On utilise un module Terraform “create-ovh-instance” pour créer l’instance OVH.

* **Une partie pour créer l’instance AWS EC2**
  
On utilise un module Terraform “create-ec2-instance” pour créer l’instance AWS.

Une particularité que nous avons fait par rapport au TP est de créer des security group pour chacun des flux que nous souhaitions avoir sur notre instance. Dans notre cas, nous souhaitions avoir les flux ssh (pour pouvoir accéder à une machine à distance de manière sécurisée. Dans notre cas, accéder à la machine virtuelle présente sur l’instance), rdp (pour pouvoir se connecter à distance à une autre machine), icmp (pour pouvoir réaliser les ping), http (pour accéder à internet) et https (pour accéder à internet de manière plus sécurisée avec du chiffrement). En faisant ainsi, ces security group pourraient être réutilisés pour d’autres projets.

* **Une partie pour installer Nginx sur l’instance EC2 d’AWS**

  - **Un fichier de configuration et un fichier d’inventaire pour permettre la configuration Nginx dans l'instance EC2**

  Ces fichiers sont générés à partir d'informations issues du module précédent (qui crée l'instance AWS EC2) permettant ainsi de récupérer les credentials AWS et l'adresse IP publique qui permettront de lancer le playbook Ansible pour installer Nginx sur l'instance EC2.

  - **Un playbook Ansible pour l’installation de Nginx**

  Ce playbook va permettre l’installation de Nginx en permettant d’avoir les bonnes configurations. On a utilisé Ansible car on souhaite suivre une procédure d’installation. Or, Ansible est conseillé pour une programmation procédurale ou impérative. Il permet de préserver la configuration d'une infrastructure informatique en définissant les étapes permettant d'atteindre l'état souhaité ce qui est souhaité dans notre cas pour l’installation de Nginx.
  Avant d'exécuter ce playbook, nous réalisons un test de connexion à l'instance EC2 ainsi qu'une dépendance sur l'existance du fichier d'inventaire. L'installation de NGINX ne peut se faire que si ces deux conditions sont réunies.

* **Une partie pour permettre le déploiement de la connexion VPN du côté AWS**
  
On utilise un module Terraform “deploy-vpn-connection” pour réaliser le déploiement de la connexion VPN. Le déploiement de la connexion VPN se fait dans un premier temps côté AWS. C’est pour cela que nous avons mis un depends_on pour s’assurer que l’instance EC2 d’AWS est bien installée avant de faire la connexion.

* **Une partie pour installer Strongswan sur l’instance OVH**

  - **Un fichier de configuration et un fichier d’inventaire pour permettre la configuration Strongswan dans OVH**
    
  Ces fichiers générés permettent de récupérer les credentials OVH qui permettront de lancer le playbook Ansible pour installer Strongswan.

  - **Un playbook Ansible pour l’installation de Strongswan**
    
  Ce playbook va permettre l’installation de Strongswan en permettant d’avoir les bonnes configurations. On a utilisé Ansible car on souhaite suivre une procédure d’installation. Or, Ansible est conseillé pour une programmation procédurale ou impérative. Il permet de préserver la configuration d'une infrastructure informatique en définissant les étapes permettant d'atteindre l'état souhaité ce qui est souhaité dans notre cas pour l’installation de Strongswan.
  De la meme manière que lors de l'installation de NGINX sur l'instance EC2, nous vérifions ici que la connection à l'instance OVH est opérationnelle et ajoutons une dépdence sur l'existance du fichier d'inventaire soit deux pré-requis indispensables.

* **Une partie pour installer un virtual host sur AWS**

  - **Un fichier de configuration, un fichier d’inventaire et un fichier générique pour permettre la configuration du virtual host dans AWS**
    
  Ces fichiers sont générés avec les informations nécessaires pour permettre de lancer le playbook Ansible pour créer le virtual host.
  
  - **Un test pour s’assurer que l’instance EC2 d’AWS est fonctionnelle**
    
  Pour s’assurer de la bonne création du virtual host, on ajoute une condition avec depends_on pour s’assurer que l’instance EC2 est bien là, qu’on a bien les fichiers nécessaires pour la création et que Nginx est bien installé.
  
  - **Un test pour s’assurer que la machine virtuelle Ubuntu sur l’instance EC2 d’AWS est opérationnelle**
    
  Ceci permet de s’assurer que tout est opérationnel dans l’instance EC2 d’AWS avant de lancer le déploiement du virtual host.
  
  - **Un playbook Ansible pour créer un virtual host**
    
  Ce playbook permet de créer le virtual host qui servira de serveur web pour notre site web. 

* **Une partie pour installer le site web sur le virtual host de Nginx**

  - **Un test pour s’assurer que l’instance EC2 d’AWS est fonctionnelle**
    
  Pour s’assurer de la bonne création du site web, on ajoute une condition avec depends_on pour s’assurer que l’instance AWS est bien là, qu’on a bien les fichiers nécessaires pour la création, que Nginx est bien installé et que le virtual host existe.

  - **Un test pour s’assurer que la machine virtuelle Ubuntu sur l’instance EC2 d’AWS est opérationnelle**
    
  Ceci permet de s’assurer que tout est opérationnel dans l’instance EC2 d’AWS avant de lancer le déploiement du site web.
  
  - **Un playbook Ansible pour créer un site web**

  Ce playbook permet de créer le site web.

* **Une partie pour déployer un certificat pour le site web**

  - **Un test pour s’assurer que l’instance EC2 d’AWS est fonctionnelle**
    
  Pour s’assurer de la bonne création du site web, on ajoute une condition avec depends_on pour s’assurer que l’instance AWS est bien là, qu’on a bien les fichiers nécessaires pour la création, que Nginx est bien installé, que le virtual host existe et que le site web existe.
  
  - **Un test pour s’assurer que la machine virtuelle Ubuntu sur l’instance EC2 d’AWS est opérationnelle**
    
  Ceci permet de s’assurer que tout est opérationnel dans l’instance EC2 d’AWS avant de lancer le déploiement du site web.
  
  - **Un playbook Ansible pour déployer un certificat pour le site web**
    
  Ce playbook permet de déployer un certificat pour le site web.

* **Une partie pour automatiser les tests**
  
Les tests de disponibilité du VPN et de ses 2 tunnels sont réalisés à l'aide de commandes fournies par l'AWS CLI.

Une boucle de 12 tentatives est réaliée en script shell.

Une fois cette vérification effectuée, des ping croisés entre l'instance OVH et l'instance EC2 d'AWS sont réalisés ainsi qu'un appel à l'outil curl pour récupérer depuis ovh le site web déployé sur l'instance EC2 d'AWS.


* **Une partie output pour récupérer les adresses IP publiques des instances OVH et AWS, ainsi qu'un lien vers notre site web déployé**

----------------

### memage.sh

Le fichier **menage.sh** est un script shell qui a été créé pour permettre l'automatisation du destroy des éléments créés lors de l'exécution sur **setup.sh**.
Il est recommandé de l'exécuter une fois que l'architecture déployée n'est plus utilisée afin de réduire la facture liée à l'architecture déployée chez les fournisseurs de cloud OVH et AWS.

----------------

### Démarche, alternatives et perspectives

#### Architecture
Pour mener à bien ce projet, nous avons commencé par construire l'architecture en ligne de commande comme nous l'avions fait dans les précédents lab. Ensuite, nous avons regroupé ces commandes dans un script shell et enfin nous avons transcrit ce script shell en un main.tf Terraform. Ce passage du script shell au main.tf Terraform nous a facilité le passage des informations d'un module à l'autre. Il nous a aussi permis d'obtenir un état global à toute notre architecture grâce à la gestion de l'idempotence propre à Terraform. En effet, si on re-exécute le setup.sh sans modifier aucun fichier, on a le message suivant :

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/CaptureSECONDRUN.JPG)

Il nous confirme que le principe d'idempotence est respecté.

Les différentes ressources Terraform dépendant fortement les une des autres, la déclaration de la liste des security group attachés à notre instance EC2 lors de sa création (module create-ec2-instance) a été faite avec le paramètre **vpc_security_group_ids** et non security_groups, ceci a été déterminant pour obtenir ce résultat. 

Le travail en groupe a été facilité par l'utilisation d'un référentiel GitHub.

Une autre approche aurait été d'orchestrer avec Ansible au lieu de Terraform. En effet, il exite un module **community.general.terraform** dans Ansible qui permet d'appeler des modules Terraform depuis un playbook Ansible. Nous avons fait le choix d'utiliser Terrafom pour orchestrer le projet et déployer des infrastructures cloud, mais nous utilisons aussi Ansible pour déployer sur ces infrastructures cloud et nous utilisons aussi un peu de AWS CLI via du script shell pour certaines opérations comme le test de la disponibilité du VPN et des deux tunnels ou l'association d'un profil d'instance IAM à une instance EC2. Le tout encapsulé dans un script shell, qui pourra s'avérer très utile pour l'étape suivante.

L'étape suivante serait l'intégration de notre **setup.sh** dans un outil de CI/CD comme Gitlab CI ou Jenkins.

#### Analyse de code statique
D'autres prespectives d'évolutions nous sont données par l'excellente intervention de Romain R. dans ce module. Nous avons installé 3 outils d'analyse statique de notre IACode, **TFSec**, **Checkov** et **Kics**, les résultats de ces analyses sont dans le répertoire doc : [AnalysisWithCheckov.out](https://github.com/ffabrice/mss-self-project/blob/main/doc/AnalysisWithCheckov.out) , [AnalysisWithTFSec.out](https://github.com/ffabrice/mss-self-project/blob/main/doc/AnalysisWithTFSec.out) et [AnalysisWithKics.out](https://github.com/ffabrice/mss-self-project/blob/main/doc/AnalysisWithKics.out)

Premier constat, aucun résultat d'analyse n'est vierge, Checkov relève 9 failles dans nos modules Terraform, aucun dans nos modules ansibles, Kics relève 14 erreurs critiques, 1 moyenne, 2 basses et 175 au niveau information et enfin TFSec relève 10 erreurs critiques, 2 haute et une moyenne.

De ces analyses statique de code, nous pouvons déduire quelques pistes d'amélioration :
* Pour la lisibilité du code, il nous faudrait ajouter un champ description pour chaque variable déclarée dans les fichiers variables.tf (cela lèverait simplement 113 "info" relevées par Kics)
* Pour identifier plus facilement les ressources coté AWS, Kics nous préconise d'utiliser d'autres tags addtionnels en plus du tag "Name" (16 "info")
* Idem que pour les variables, une bonne pratique est d'ajouter un champ description aux variables en output Terraform (19 "info")
* Autre bonne pratique de codage que nous n'avons pas toujours respecté, certains noms de ressources ne respectent pas le "snake case pattern" en utilisant des "-" au lieu de "_" (25 "info")
* Certaines remarques portent sur les bonnes pratiques AWS comme l'utilisation d'une instance EBS optimisée (relevé par Kics et Checkov), le cryptage des instance EC2 ou l'activation du monitoring des instances et les logs du VPC (très utile pour la sécurité et relevé par les 3 outils)
* Des failles de sécurité de notre projet concernent nos security group et leurs règles entrantes portant sur "la terre entière" ["0.0.0.0/0"] (relevé par Kics, TFSec et Checkov avec un niveau élevé)
* Kics, étant plus exaustif, nous suggère d'ajouter un firewall à notre VPC


----------------

### Tests

* **Récupération des adresses IP publiques depuis les outputs de setup.sh :**

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/280258502-1f6f4e6f-d8ba-4fb3-b486-f622d0e6e01f.png)

    aws_public_ip = "3.139.66.52"
    ovh_public_ip = "135.125.91.35"
Note : Ces adresses IP étant attribuées par les fournisseurs de Cloud AWS et OVH, elles diffèrent à chaque déploiement.

* **Récupération des adresses IP privées dans le fichier variables.yml dans modules/check-conf/vars :**

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/280258604-3096be05-815e-4fa2-a2c2-cd2c6de8f8de.png)

    ovh_loopback_ip = "10.10.1.252"
    aws_private_ip = "10.1.1.59"
Note : Ces adresses IP étant attribuées par les fournisseurs de Cloud AWS et OVH, elles diffèrent à chaque déploiement.

* **Accès au site web non sécurisé à l'adresse http://3.139.66.52 :**

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/280258771-357d2019-4529-44a8-b083-b752150bded3.png)

* **Accès au site web sécurisé à l'adresse https://selfmsss.devops.intuitivesoft.cloud./ :**

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/280261055-518a6681-d0ef-4c78-a2e8-25dd7e75af42.png)

* **Vérification des tunnels côté AWS :**

Les 2 tunnels sont up côté AWS :

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/280259051-a812cd56-d341-4209-8ef7-bec9f0091031.png)

Connexion à la machine virtuelle Ubuntu dans l'instance AWS :

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/280259229-33574014-a222-4ea0-9d06-39b2456845a3.png)


Test de ping par tunnel vers l'instance d'OVH :

    ping ovh_loopback_ip

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/280260592-456f9aeb-27da-4ed0-8dfc-40a61b8c3707.png)


* **Vérification des tunnels côté OVH :**

Connexion à la machine virtuelle Ubuntu dans l'instance OVH et vérification avec la commande **sudo ipsec status** que les tunnels sont up côté OVH :

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/280259332-bbba050c-20c5-4546-a266-d2d3944d4ddc.png)

Test de ping par tunnel vers l'instance d'AWS :

    ping -I ovh_loopback_ip aws_private_ip 

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/CapturePingAWSdepuisOVH.png)

Enfin coté OVH, nous réalisons un curl sur l'adresse privée AWS afin de récupérer le contenu du site web déployé :

    curl --interface ovh_loopback_ip  http://aws_private_ip 

![image](https://github.com/ffabrice/mss-self-project/blob/main/images/CaptureCurlAWSdepuisOVH.JPG)


----------------

### Outputs

L'exécution du **setup.sh** génère différents fichiers en sortie :
* doc/project-digraph.dot : il s'agit du graph Terraform de notre architecture. Devant le nombre de ressources de notre projet, ce graph est devenu conséquent.
* selfsetup.out : ce fichier contient les logs, il permet de faire des recherches et des vérifications à postériori (un exemple de log obtenu est présent dans doc : [selfsetupEXPLE.out](https://github.com/ffabrice/mss-self-project/blob/main/doc/selfsetupEXPLE.out) pour une première exécution ainsi que les logs suite à une deuxième exécution sans rien changer entre les deux [selfsetupEXPLEsecondRUNverifidempotent.out](https://github.com/ffabrice/mss-self-project/blob/main/doc/selfsetupEXPLEsecondRUNverifidempotent.out)  ).
* Différents fichiers d'inventaires et de configuration générés.
* Les fichiers des clefs privées générées pour la connections à l'instance OVH et à l'instance EC2 (dans le répertoire .ssh à la racine du projet).

L'exécution du **menage.sh** génère de la même façon un fichier de log "selfmenage.out" (exemple ici : [selfmenageEXPLE.out](https://github.com/ffabrice/mss-self-project/blob/main/doc/selfmenageEXPLE.out) ). Ce script permet également de supprimer les fichiers générés comme les fichiers d'inventaire, de configuration ainsi que les fichiers des clefs privées ".pem" dans le répertoire .ssh à la racine du projet.





----------------





Equipe S.E.L.F. :


Sandie Van Hulle, 
Eric Badellon, 
Lionel Girard, 
Fabrice Fiquemo


--
