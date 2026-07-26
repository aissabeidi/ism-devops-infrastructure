# Déploiement automatisé d'un serveur web sécurisé sur AWS

Terraform (infrastructure) + Ansible (configuration) + GitHub Actions (orchestration CI/CD).

## Arborescence

```
.
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── ansible/
│   ├── inventory/aws_ec2.yml
│   ├── playbook.yml
│   ├── requirements.yml
│   └── roles/
│       ├── system-update/
│       └── nginx/
└── .github/workflows/deploy.yml
```

## 1. Prérequis locaux (test avant CI/CD)

```bash
# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt install terraform

# Ansible + collections
pip install ansible boto3 botocore
ansible-galaxy collection install -r ansible/requirements.yml

# Credentials AWS
aws configure
```

Générer une paire de clés SSH si besoin :
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

## 2. Backend distant Terraform (à faire une seule fois, manuellement)

Avant d'activer le bloc `backend "s3"` dans `main.tf`, créez le bucket et la table de verrouillage :

```bash
aws s3api create-bucket --bucket VOTRE-NOM-BUCKET-STATE --region eu-west-3 \
  --create-bucket-configuration LocationConstraint=eu-west-3

aws dynamodb create-table --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST --region eu-west-3
```

Puis décommentez le bloc `backend` dans `terraform/main.tf` avec le nom du bucket.

## 3. Test local (avant d'automatiser)

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# éditez terraform.tfvars : mettez votre IP publique réelle dans ssh_allowed_cidr
terraform init
terraform plan
terraform apply
```

Récupérez l'IP :
```bash
terraform output instance_public_ip
```

Puis testez Ansible en local :
```bash
cd ../ansible
ansible-playbook -i inventory/aws_ec2.yml playbook.yml --private-key ~/.ssh/id_rsa -u ubuntu
```

Vérifiez dans un navigateur : `http://<IP_INSTANCE>`.

## 4. Secrets GitHub à configurer

Dans `Settings > Secrets and variables > Actions` du dépôt, ajoutez :

| Secret               | Description                                    |
|----------------------|-------------------------------------------------|
| `AWS_ACCESS_KEY_ID`  | Clé d'accès IAM dédiée à la CI/CD                |
| `AWS_SECRET_ACCESS_KEY` | Secret associé                              |
| `SSH_PUBLIC_KEY`     | Contenu de `~/.ssh/id_rsa.pub`                  |
| `SSH_PRIVATE_KEY`    | Contenu de `~/.ssh/id_rsa` (clé privée)          |
| `SSH_ALLOWED_CIDR`   | Votre IP publique au format `X.X.X.X/32`         |

Recommandation sécurité : créez un utilisateur IAM dédié avec des permissions minimales (EC2, VPC, S3, IAM PassRole limité) plutôt que d'utiliser des credentials root.

## 5. Déclenchement automatique

Un simple `git push` sur `main` déclenche `.github/workflows/deploy.yml` qui enchaîne :
1. `terraform plan` + `apply`
2. Récupération de l'IP en sortie
3. Playbook Ansible (mise à jour système, durcissement pare-feu, installation Nginx, déploiement de la page)
4. Test HTTP post-déploiement (échoue le pipeline si le serveur ne répond pas)

## 6. Nettoyage

Pour détruire l'infrastructure et éviter des coûts AWS inutiles :
```bash
cd terraform
terraform destroy
```

## Pistes de durcissement supplémentaires (pertinentes pour un mémoire sécurité)

- Restreindre le SSH à un bastion ou VPN plutôt qu'à une IP fixe
- Activer AWS CloudTrail + GuardDuty pour la traçabilité
- Chiffrer le volume EBS de l'instance (`root_block_device.encrypted = true`)
- Ajouter un WAF devant Nginx si le serveur est exposé publiquement
- Faire tourner `fail2ban` (déjà installé par le rôle `system-update`) avec une configuration personnalisée
