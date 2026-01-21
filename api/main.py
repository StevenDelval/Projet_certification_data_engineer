from fastapi import FastAPI, Depends
from database import engine
from models import Base
from auth import get_current_user
from router import user_router, data_router

app = FastAPI()

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
