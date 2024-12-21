@echo off

:: Define las variables
set IMAGE_TAG="latest"
set CUENTA="533267192957"

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin %CUENTA%.dkr.ecr.us-east-1.amazonaws.com

:: Crear los repositorios en ECR
aws ecr create-repository --repository-name testdevopsback --region us-east-1
aws ecr create-repository --repository-name testdevopsfront --region us-east-1

:: Para el contenedor de la API Django
cd .\restDjango2\
docker build -t testdjango .
docker tag testdjango %CUENTA%.dkr.ecr.us-east-1.amazonaws.com/testdevopsfront:%IMAGE_TAG%
docker push %CUENTA%.dkr.ecr.us-east-1.amazonaws.com/testdevopsfront:%IMAGE_TAG%
cd ..

:: Para el contenedor de la API FastAPI
cd .\CrudFaskApi\
docker build -t testfaskapi .
docker tag testfaskapi %CUENTA%.dkr.ecr.us-east-1.amazonaws.com/testdevopsback:%IMAGE_TAG%
docker push %CUENTA%.dkr.ecr.us-east-1.amazonaws.com/testdevopsback:%IMAGE_TAG%
cd ..
