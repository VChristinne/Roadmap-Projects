from uuid import uuid4
from passlib.hash import sha256_crypt
from mysql import connector
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel


class User(BaseModel):
    name: str
    email: str
    password: str


class LoginUser(BaseModel):
    email: str
    password: str


db = connector.connect(
    host="localhost",
    user="root",
    password="",
    database="ToDoList"
)

app = FastAPI()

@app.get("/message")
async def message():
    return {
        "Message": "Hello, World!"
    }

@app.post("/register")
async def register(user: User):
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE email = %s", (user.email,))
    if cursor.fetchone():
        raise HTTPException(status_code=400, detail="Email already in use")

    hashed = sha256_crypt.using(rounds=1000).hash(user.password)
    token = str(uuid4())
    
    cursor = db.cursor()
    cursor.execute("""
        INSERT INTO users (name, email, password, token) VALUES (%s, %s, %s, %s)
        """, (user.name, user.email, hashed, token)
    )
    db.commit()
    
    if cursor.rowcount == 1:
        return {"token": token}
    else:
        raise HTTPException(status_code=500, detail="Error creating user")

@app.post("/login")
async def login(user: LoginUser):
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE email = %s", (user.email,))
    result = cursor.fetchone()

    # TODO: email verify got 500 error
    if user.email == result['email'] and sha256_crypt.verify(user.password, result['password']):
        return {"token": result['token']}
    else:
        raise HTTPException(status_code=401, detail=f"Invalid email or password")
