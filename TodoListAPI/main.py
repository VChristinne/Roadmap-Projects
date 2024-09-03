from uuid import uuid4
from passlib.hash import sha256_crypt
from fastapi import FastAPI, HTTPException, Depends, Header

from config import *
from models import *


app = FastAPI()


async def get_current_user(authorization: str = Header(...)):
    token = authorization
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE token = %s", (token,))
    user = cursor.fetchone()

    if user is None:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    
    return user


@app.get("/message")
async def message():
    return {
        "Message": "Hello, World!"
    }


@app.post("/register")
async def register(user: User):
    cursor = db.cursor(dictionary=True)
    
    try:
        cursor.execute(
            "SELECT * FROM users WHERE email = %s", 
            (user.email,)
        )
        if cursor.fetchone():
            raise HTTPException(status_code=400, detail="Email already in use")
    
        hashed = sha256_crypt.using(rounds=1000).hash(user.password)
        token = str(uuid4())
        
        cursor = db.cursor()
        cursor.execute(
            "INSERT INTO users (name, email, password, token) VALUES (%s, %s, %s, %s)", 
            (user.name, user.email, hashed, token)
        )
        db.commit()
        
        if cursor.rowcount == 1:
            return {"token": token}
        else:
            raise HTTPException(status_code=500, detail="Error creating user")

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()


@app.post("/login")
async def login(user: LoginUser):
    cursor = db.cursor(dictionary=True)
    
    try:
        cursor.execute(
            "SELECT * FROM users WHERE email = %s", 
            (user.email,)
        )
        result = cursor.fetchone()
    
        if result is None or not sha256_crypt.verify(user.password, result['password']):
            raise HTTPException(status_code=401, detail=f"Invalid email or password")
    
        return {"token": result['token']}

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()


@app.post("/todos")
async def create_task(task: Task, user: dict = Depends(get_current_user)):
    cursor = db.cursor(dictionary=True)
    try:
        cursor.execute(
            "INSERT INTO Tasks (title, description, user_id) VALUES (%s, %s, %s)",
            (task.title, task.description, user['id'])
        )
        db.commit()

        task_id = cursor.lastrowid
        cursor.execute("SELECT * FROM Tasks WHERE id = %s", (task_id,))
        result = cursor.fetchone()

        if result:
            return {
                "id": result['id'],
                "title": result['title'],
                "description": result['description']
            }
        else:
            raise HTTPException(status_code=500, detail="Task not found after creation")
    
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    
    finally:
        cursor.close()
