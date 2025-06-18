from sqlalchemy import Column, Integer, String, Date, Boolean, BigInteger
from sqlalchemy.ext.automap import automap_base
from database import Base, engine


class User(Base):
    """
    SQLAlchemy model for the User table.

    This model represents a user in the system and maps to the 'users' table in the database.

    Attributes:
        id (Column): The unique identifier for the user. An auto-incremented integer and primary key.
        username (Column): The username for the user. Must be unique and is indexed for faster queries.
        hashed_password (Column): The hashed password for the user. Stored as a string.

    Table:
        - `users`: The table in the database where user records are stored.

    Notes:
        The `id` field is automatically assigned by the database and does not need to be specified 
        when creating a new user. The `username` must be unique to prevent duplicate accounts.
    """
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)

AutoBase = automap_base()
AutoBase.prepare(engine, reflect=True)

TableMeteoQuotidien = AutoBase.classes.TableMeteoQuotidien
TablePiezoInfo = AutoBase.classes.TablePiezoInfo
Nature_mesure = AutoBase.classes.Nature_mesure
Continuite = AutoBase.classes.Continuite
Producteur = AutoBase.classes.Producteur
TablePiezoQuotidien = AutoBase.classes.TablePiezoQuotidien