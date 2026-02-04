from fastapi import FastAPI, Depends
from fastapi.responses import RedirectResponse
from database import engine
from models import Base
from auth import get_current_user
from router import user_router, data_router

app = FastAPI()

@app.get("/", include_in_schema=False)
async def redirect_to_docs():
    return RedirectResponse(url="/docs")

Base.metadata.create_all(bind=engine)

app.include_router(
    user_router.router,
    prefix="/user",
    tags=["User"]
)

app.include_router(
    data_router.router,
    prefix="/data",
    dependencies=[Depends(get_current_user)],
    tags=["Data"]
)
