from sqlalchemy import Column, Integer, String, Date, Boolean, BigInteger
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