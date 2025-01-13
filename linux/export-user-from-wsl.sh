#!/bin/bash

# @author Sérgio Oliveira
# @version 1.0.0
# @license MIT
# @description Esse aquivo é para exportar toda a pasta de um usuário Linux e 
# os pacotes instalados na distribuição gerando assim arquivos para serem 
# copiados para a nova distribuição e importados, atualizando também a lista
# de pacotes

# Função para imprimir mensagens com [OK] em verde
print_ok() {
  echo -e "\033[32m[OK]\033[0m $1"
}

# Função para imprimir mensagens com [ERROR] em vermelho
print_error() {
  echo -e "\033[31m[ERROR]\033[0m $1"
}

# Solicitar o nome do usuário
read -p "Digite o nome do usuário: " usuario

# Verificar se o usuário existe no sistema
if ! id "$usuario" &>/dev/null; then
  print_error "Usuário '$usuario' não encontrado. Nenhuma ação foi realizada."
  exit 1
fi

# Definir os caminhos com base no nome do usuário
diretorio_home="/home/$usuario"
arquivo_tar="/var/tmp/${usuario}_linux.tar"
arquivo_import_sh="/var/tmp/import_${usuario}.sh"
arquivo_readme="/var/tmp/README.txt"

# Compactar o diretório /home/$usuario em um arquivo tar e salvar em /var/tmp
tar -czf "$arquivo_tar" "$diretorio_home"

# Mensagem de sucesso após a exportação
print_ok "Exportação concluída: $arquivo_tar"

# Mostrar o tamanho do arquivo gerado
print_ok "Tamanho do arquivo tar gerado:"
du -h "$arquivo_tar"

# Listar pacotes instalados no sistema
dpkg --get-selections | grep -v deinstall | awk '{print $1}' > /var/tmp/package_list.txt
print_ok "Arquivo package_list.txt criado"

# Criar o arquivo import.sh no diretório /var/tmp
cat << EOF > "$arquivo_import_sh"
#!/bin/bash

# Descompactar o arquivo tar para o diretório /home/$usuario
tar -xzf $arquivo_tar -C /home/$usuario

echo "Importação concluída para /home/$usuario"

# Instalar pacotes a partir do arquivo package_list.txt
sudo apt install -y \$(cat /home/$usuario/package_list.txt)

echo "Pacotes instalados"
EOF

# Tornar o import.sh executável
chmod +x "$arquivo_import_sh"

# Mensagem final após criação do import.sh
print_ok "Arquivo $arquivo_import_sh criado em /var/tmp"

# Criar o arquivo README.txt com instruções
cat << EOF > "$arquivo_readme"
Instruções de uso:

1. Copie o arquivo ${usuario}_linux.tar e o arquivo package_list.txt para a nova distribuição.

2. Na nova distribuição, mova os arquivos para o diretório adequado, por exemplo:
   - Copie o ${usuario}_linux.tar para o diretório /var/tmp.
   - Copie o package_list.txt para o diretório /home/$usuario/.

3. Execute o arquivo de importação:
   - Torne o script de importação executável: chmod +x /var/tmp/import_${usuario}.sh
   - Execute o script de importação: /var/tmp/import_${usuario}.sh

O processo irá descompactar o arquivo tar e instalar os pacotes listados no package_list.txt.
EOF

# Mensagem final após criação do README.txt
print_ok "Arquivo README.txt criado em /var/tmp com as instruções de uso"