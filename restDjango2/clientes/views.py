from django.shortcuts import render
from .models import Cliente

def lista_clientes(request):
    # Añadir datos de ejemplo si no existen
    if not Cliente.objects.exists():
        Cliente.objects.create(nombre="Edwar Quintero", email="edwar@undominio.com", telefono="1234567890")
        Cliente.objects.create(nombre="Claudia Agudelo", email="claudia@undominio.com", telefono="0987654321")

    clientes = Cliente.objects.all()
    return render(request, 'clientes/lista_clientes.html', {'clientes': clientes})
