from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime, timezone

import schemas, crud, auth, security
from database import get_db

router = APIRouter()

@router.post("/register", response_model=schemas.UserOut)
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    if crud.get_user(db, user.username):
        raise HTTPException(status_code=400, detail="Username already exists")

    if not user.consent_given:
        raise HTTPException(status_code=400, detail="Consent required")

    return crud.create_user(db, user)

@router.post("/login")
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
):
    db_user = crud.get_user(db, form_data.username)

    if (
        not db_user
        or not db_user.is_active
        or db_user.deleted_at
        or not security.verify_password(
            form_data.password, db_user.hashed_password
        )
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    crud.update_last_login(db, db_user)

    token = auth.create_access_token({"sub": db_user.username})

    return {
        "access_token": token,
        "token_type": "bearer"
    }