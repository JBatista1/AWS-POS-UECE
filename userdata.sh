  #!/bin/bash
#!/bin/bash

# Navegar até o diretório target e iniciar o aplicativo Java
cd /home/ubuntu/BE-Pos-UECE/target
sudo java -jar contasAPagar-0.0.1-SNAPSHOT.jar > /home/ubuntu/contasAPagar.log 2>&1 &

# Navegar para o diretório do frontend e iniciar o aplicativo Node.js
cd /home/ubuntu/FE-POS-UECE
sudo npm install
sudo nohup npm start > /home/ubuntu/myreactapp.log 2>&1 &
