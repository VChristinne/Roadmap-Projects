from fastapi import FastAPI


app = FastAPI()

@app.get("/get-message")
async def message():
    return {
        "Message": "Hello, World!"
    }
