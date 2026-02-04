from sqlalchemy.orm import Session
from models import User, Meteo, Info_nappe, Nature_mesure, Continuite, Producteur, Nappe, Localisation
from schemas import UserCreate
from passlib.context import CryptContext
from security import get_password_hash
from datetime import datetime, timedelta, timezone

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_user(db: Session, username: str):
    """
    Retrieve a user from the database by their username.

    Args:
        db (Session): The SQLAlchemy database session used to query the database.
        username (str): The username of the user to retrieve.

    Returns:
        users: The user object if found, otherwise None.
        
    Notes:
        The function performs a query to find a user with the matching username. 
        It returns the first matching user or None if no user is found.
    """
    return db.query(User).filter(User.username == username).first()


def create_user(db: Session, user: UserCreate):
    """
    Create a new user in the database.

    Args:
        db (Session): The SQLAlchemy database session used to interact with the database.
        user (UserCreate): The user data to create, including username and password.

    Returns:
        users: The created user object with an assigned ID.
        
    Notes:
        The function hashes the provided password using `pwd_context.hash` and creates a new `users` 
        instance with the hashed password. The new user is then added to the database, committed, 
        and refreshed to obtain the new user’s ID.
    """
    db_user = User(
        username=user.username,
        hashed_password=get_password_hash(user.password),
        first_name=user.first_name,
        last_name=user.last_name,
        email=user.email,
        address=user.address,
        consent_given=user.consent_given,
        consent_date=datetime.utcnow(),
        consent_version="v1.0"
)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def get_row_by_primary_keys(db: Session, model, **pk_values):
    return db.query(model).get(tuple(pk_values.values()))

def get_meteo_by_date_coords(db: Session, date, lambx, lamby):
    return get_row_by_primary_keys(db, Meteo, DATE=date, LAMBX=lambx, LAMBY=lamby)

def get_paginated_piezo_data_by_code_bss(
        db: Session,
        code_bss: str,
        offset: int = 0,
        limit: int = 50,
        include_info: bool = False,
        include_continuite: bool = False,
        include_nature: bool = False,
        include_producteur: bool = False,
    ):
    columns = [Nappe]

    if include_info:
        columns.append(Info_nappe)
    if include_continuite:
        columns.append(Continuite)
    if include_nature:
        columns.append(Nature_mesure)
    if include_producteur:
        columns.append(Producteur)

    query = db.query(*columns).filter(Nappe.code_bss == code_bss)

    if include_info:
        query = query.join(Info_nappe, Nappe.code_bss == Info_nappe.code_bss)

    if include_continuite:
        query = query.outerjoin(Continuite, Nappe.code_continuite == Continuite.code_continuite)

    if include_nature:
        query = query.outerjoin(Nature_mesure, Nappe.code_nature_mesure == Nature_mesure.code_nature_mesure)

    if include_producteur:
        query = query.outerjoin(Producteur, Nappe.code_producteur == Producteur.code_producteur)

    total = query.count()

    results = (
        query.order_by(Nappe.date_mesure.desc())
        .offset(offset)
        .limit(limit)
        .all()
    )

    return total, results

def get_piezo_info_by_code_bss(db: Session, code_bss):
    return get_row_by_primary_keys(db, Info_nappe, code_bss=code_bss)

def get_all_piezo(db: Session):
    return db.query(Info_nappe)

def get_piezo_and_meteo_by_date_range_for_code_bss(db: Session,code_bss, start_date, end_date):
    return (
        db.query(
            Nappe.code_bss,
            Nappe.date_mesure,
            Nappe.profondeur_nappe,
            Nappe.niveau_nappe_eau,
            Meteo
        )
        .join(
            Info_nappe,
            Nappe.code_bss == Info_nappe.code_bss
        )
        .join(
            Localisation,
            (Info_nappe.LAMBX == Localisation.LAMBX )&
            (Info_nappe.LAMBY == Localisation.LAMBY)
        )
        .join(
            Meteo,
            (Localisation.LAMBX == Meteo.LAMBX) &
            (Localisation.LAMBY == Meteo.LAMBY) &
            (Nappe.date_mesure == Meteo.DATE)
        )
        .filter(
            Nappe.date_mesure.between(start_date, end_date)
        )
        .filter(Nappe.code_bss == code_bss)
        .all()
    )

def update_last_login(db: Session, user):
    user.last_login_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(user)
    return user