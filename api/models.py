from sqlalchemy import Column, Integer, String, Date, Boolean, BigInteger, TIMESTAMP
from sqlalchemy.sql import func
from sqlalchemy.ext.automap import automap_base
from database import Base, engine



AutoBase = automap_base()
AutoBase.prepare(engine, reflect=True)

TableMeteoQuotidien = AutoBase.classes.TableMeteoQuotidien
TablePiezoInfo = AutoBase.classes.TablePiezoInfo
Nature_mesure = AutoBase.classes.Nature_mesure
Continuite = AutoBase.classes.Continuite
Producteur = AutoBase.classes.Producteur
TablePiezoQuotidien = AutoBase.classes.TablePiezoQuotidien
users = AutoBase.classes.users


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(100), unique=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)

    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    address = Column(String(255), nullable=False)

    # RGPD
    consent_given = Column(Boolean, default=False, nullable=False)
    consent_date = Column(TIMESTAMP(timezone=True))
    consent_version = Column(String(20))

    is_active = Column(Boolean, default=True, nullable=False)
    deleted_at = Column(TIMESTAMP(timezone=True))

    created_at = Column(
        TIMESTAMP(timezone=True),
        server_default=func.now(),
        nullable=False
    )
    last_login_at = Column(TIMESTAMP(timezone=True))