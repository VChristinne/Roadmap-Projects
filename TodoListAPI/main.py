from fastapi import FastAPI
from pydantic import BaseModel


class User(BaseModel):
    name: str
    email: str
    password: str


app = FastAPI()

@app.get("/get-message")
async def message():
    return {
        "Message": "Hello, World!"
    }

@app.post("/register")
async def register(user: User):
    return user
