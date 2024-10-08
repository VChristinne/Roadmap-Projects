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


@app.put("/todos/{task_id}")
async def update_task(task_id: int, task: Task, user: dict = Depends(get_current_user)):
    cursor = db.cursor(dictionary=True)
    
    try:
        cursor.execute(
            "SELECT * FROM Tasks WHERE id = %s AND user_id = %s", 
            (task_id, user['id'])
        )
        existing_task = cursor.fetchone()
        
        if not existing_task:
            raise HTTPException(status_code=403, detail="Forbidden")
        
        cursor.execute(
            "UPDATE Tasks SET title = %s, description = %s WHERE id = %s AND user_id = %s",
            (task.title, task.description, task_id, user['id'])
        )
        db.commit()
    
        cursor.execute("SELECT * FROM Tasks WHERE id = %s", task_id)
        result = cursor.fetchone()
        
        if not result:
            raise HTTPException(status_code=500, detail="Task not found for update")
    
        return {
            "id": result['id'],
            "title": result['title'],
            "description": result['description']
        }
    
    except HTTPException as e:
        raise e
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()


@app.delete("/todos/{task_id}")
async def update_task(task_id: int, user: dict = Depends(get_current_user)):
    cursor = db.cursor(dictionary=True)

    try:
        cursor.execute(
            "SELECT * FROM Tasks WHERE id = %s AND user_id = %s", 
            (task_id, user['id'])
        )
        existing_task = cursor.fetchone()

        if not existing_task:
            raise HTTPException(status_code=403, detail="Forbidden")

        cursor.execute(
            "DELETE FROM Tasks WHERE id = %s AND user_id = %s",
            (task_id, user['id'])
        )
        db.commit()

        return {
            HTTPException(status_code=203, detail="Task deleted!")
        }

    except HTTPException as e:
        raise e

    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()


@app.get("/todos/")
async def list_task(page: int = 1, limit: int = 10, user: dict = Depends(get_current_user)):
    cursor = db.cursor(dictionary=True)

    try:
        offset = (page - 1) * limit
        cursor.execute(
            "SELECT * FROM Tasks WHERE user_id = %s LIMIT %s OFFSET %s",
            (user['id'], limit, offset)
        )
        result = cursor.fetchall()

        if result:
            return {
                "data": [
                    {
                        "id": task['id'],
                        "title": task['title'],
                        "description": task['description'],
                    } for task in result
                ],
                "page": page,
                "limit": limit,
                "total": len(result)
            }
        else:
            raise HTTPException(status_code=404, detail="No tasks found")

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    finally:
        cursor.close()
