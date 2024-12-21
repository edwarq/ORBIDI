from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List

app = FastAPI()

# Modelo de datos
class Item(BaseModel):
    id: int
    name: str
    description: str = None
    price: float

# Simulación de base de datos en memoria
fake_db = {}

# Método GET para obtener todos los items
@app.get("/items", response_model=List[Item])
async def get_items():
    return list(fake_db.values())

# Método GET para obtener un item por su ID
@app.get("/items/{item_id}", response_model=Item)
async def get_item(item_id: int):
    if item_id not in fake_db:
        raise HTTPException(status_code=404, detail="Item not found")
    return fake_db[item_id]

# Método POST para crear un nuevo item
@app.post("/items", response_model=Item)
async def create_item(item: Item):
    if item.id in fake_db:
        raise HTTPException(status_code=400, detail="Item already exists")
    fake_db[item.id] = item
    return item

# Método PUT para actualizar un item
@app.put("/items/{item_id}", response_model=Item)
async def update_item(item_id: int, item: Item):
    if item_id not in fake_db:
        raise HTTPException(status_code=404, detail="Item not found")
    fake_db[item_id] = item
    return item

# Método DELETE para eliminar un item
@app.delete("/items/{item_id}")
async def delete_item(item_id: int):
    if item_id not in fake_db:
        raise HTTPException(status_code=404, detail="Item not found")
    del fake_db[item_id]
    return {"message": "Item deleted successfully"}
