# imagen Python
FROM python:3.12

# carpeta de trabajo..
WORKDIR /app

# Copiar los archivos de local a contenedor
COPY . /app

# Instalar dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Crear la base de datos
RUN python manage.py makemigrations
RUN python manage.py migrate


# Exponer el puerto que utiliza Django
EXPOSE 8000

# Comando para ejecutar la aplicación
CMD ["python", "manage.py", "runserver", "0.0.0.0:80"]
