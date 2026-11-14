#!/usr/bin/env bash
# Gera a chave OFICIAL do Kipper para Android e a linha do segredo KIPPER_ANDROID_CHAVE.
#
# Uso: tools/kipper/chave-android.sh PASTA_DE_SAIDA
#
# Escreve em PASTA_DE_SAIDA:
#   kipper-oficial.p12          a chave (guarde uma cópia em lugar seguro: sem ela, quem já
#                               instalou o Kipper não recebe mais atualização)
#   KIPPER_ANDROID_CHAVE.txt    "apelido:senha:base64", o valor do segredo no GitHub
#
# NUNCA coloque esses arquivos no repositório. Rodar de novo cria OUTRA chave: só faça isso
# antes da primeira versão oficial do Android.
set -euo pipefail
saida="${1:?pasta de saída}"
mkdir -p "$saida"
p12="$saida/kipper-oficial.p12"
[ ! -e "$p12" ] || { echo "Já existe $p12; não sobrescrevo." >&2; exit 1; }
senha="$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32 || true)"
[ ${#senha} -eq 32 ] || { echo 'não consegui gerar a senha' >&2; exit 1; }
keytool -genkeypair -keystore "$p12" -storetype PKCS12 -alias kipper \
    -keyalg RSA -keysize 4096 -validity 10950 -dname "CN=Kipper, O=Kipper" \
    -storepass "$senha" -keypass "$senha" >/dev/null 2>&1
printf 'kipper:%s:%s\n' "$senha" "$(base64 -w0 "$p12")" > "$saida/KIPPER_ANDROID_CHAVE.txt"
chmod 600 "$p12" "$saida/KIPPER_ANDROID_CHAVE.txt"
keytool -list -v -keystore "$p12" -storepass "$senha" 2>/dev/null | grep -E 'SHA256:|Owner:' | head -2
echo "Pronto: $saida"
