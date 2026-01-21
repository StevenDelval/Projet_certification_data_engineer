from typing import List
from datetime import date
from pydantic import BaseModel, Field, EmailStr

class UserCreate(BaseModel):
    username: str
    password: str
    first_name: str
    last_name: str
    email: EmailStr
    address: str
    consent_given: bool

class UserLogin(BaseModel):
    username: str
    password: str

class UserOut(BaseModel):
    id: int
    username: str
    email: EmailStr

    class Config:
        from_attributes = True



class MeteoRequest(BaseModel):
    input_date: date = Field(..., description="Date in YYYY-MM-DD format")
    lambx: int = Field(..., description="Lambert X coordinate")
    lamby: int = Field(..., description="Lambert Y coordinate")

from typing import Optional

class MeteoDataOut(BaseModel):
    DATE: date
    PRENEI: Optional[float]
    PRELIQ: Optional[float]
    T: Optional[float]
    FF: Optional[float]
    Q: Optional[float]
    DLI: Optional[float]
    SSI: Optional[float]
    HU: Optional[float]
    EVAP: Optional[float]
    ETP: Optional[float]
    PE: Optional[float]
    SWI: Optional[float]
    DRAINC: Optional[float]
    RUNC: Optional[float]
    RESR_NEIGE: Optional[float]
    RESR_NEIGE6: Optional[float]
    HTEURNEIGE: Optional[float]
    HTEURNEIGE6: Optional[float]
    HTEURNEIGEX: Optional[float]
    SNOW_FRAC: Optional[float]
    ECOULEMENT: Optional[float]
    WG_RACINE: Optional[float]
    WGI_RACINE: Optional[float]
    TINF_H: Optional[float]
    TSUP_H: Optional[float]

    class Config:
        from_attributes = True

class PiezoRequest(BaseModel):
    code_bss: str
    include_info: Optional[bool] = False
    include_continuite: Optional[bool] = False
    include_nature: Optional[bool] = False
    include_producteur: Optional[bool] = False

class PiezoInfoOut(BaseModel):
    code_bss: str
    urn_bss: Optional[str]
    LAMBX: Optional[int]
    LAMBY: Optional[int]

    class Config:
        from_attributes = True

class ContinuiteOut(BaseModel):
    code_continuite: int
    nom_continuite: Optional[str]

    class Config:
        from_attributes = True

class NatureMesureOut(BaseModel):
    code_nature_mesure: str
    nom_nature_mesure: Optional[str]

    class Config:
        from_attributes = True

class ProducteurOut(BaseModel):
    code_producteur: int
    nom_producteur: Optional[str]

    class Config:
        from_attributes = True

class PiezoDataOut(BaseModel):
    code_bss: str
    date_mesure: date
    niveau_nappe_eau: Optional[float]
    profondeur_nappe: Optional[float]

    info: Optional[PiezoInfoOut] = None
    continuite: Optional[ContinuiteOut] = None
    nature_mesure: Optional[NatureMesureOut] = None
    producteur: Optional[ProducteurOut] = None

    class Config:
        from_attributes = True


class PiezoPaginatedResponse(BaseModel):
    total: int
    limit: int
    offset: int
    results: List[PiezoDataOut]        