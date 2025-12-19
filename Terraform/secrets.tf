# Strapi application secrets
resource "random_password" "app_key1" { length = 32 }
resource "random_password" "app_key2" { length = 32 }
resource "random_password" "app_key3" { length = 32 }
resource "random_password" "app_key4" { length = 32 }
resource "random_password" "api_salt" { length = 32 special = true }
resource "random_password" "admin_jwt" { length = 32 special = true }
resource "random_password" "jwt_secret" { length = 32 special = true }

locals {
  strapi_secrets = {
    APP_KEYS         = "${random_password.app_key1.result},${random_password.app_key2.result},${random_password.app_key3.result},${random_password.app_key4.result}"
    API_TOKEN_SALT   = random_password.api_salt.result
    ADMIN_JWT_SECRET = random_password.admin_jwt.result
    JWT_SECRET       = random_password.jwt_secret.result
  }
}
