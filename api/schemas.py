from typing import List
from datetime import date
from pydantic import BaseModel, Field

class UserCreate(BaseModel):
    """
    Pydantic model for creating a new user.

    This model is used for validating and serializing the data required to create a new user.

    Attributes:
        username (str): The username for the new user. This should be a unique identifier.
        password (str): The password for the new user. It will be hashed before storing.
    """
    username: str
    password: str

class UserOut(BaseModel):
    """
    Pydantic model for representing a user in responses.

    This model is used for serializing user data that is returned in API responses.

    Attributes:
        id (int): The unique identifier of the user.
        username (str): The username of the user.

    Config:
        from_attributes (bool): This configuration allows the model to be created from ORM models directly.

    Notes:
        The `Config` subclass enables compatibility with ORM models by allowing `UserOut` to be constructed 
        from attributes of ORM models.
    """
    id: int
    username: str

    class Config:
        from_attributes = True



class MeteoRequest(BaseModel):
    input_date: date = Field(..., description="Date in YYYY-MM-DD format")
    lambx: int = Field(..., description="Lambert X coordinate")
    lamby: int = Field(..., description="Lambert Y coordinate")

from typing import Optional

class MeteoDataOut(BaseModel):
    DATE: date
    PRENEI_Q: Optional[float]
    PRELIQ_Q: Optional[float]
    T_Q: Optional[float]
    FF_Q: Optional[float]
    Q_Q: Optional[float]
    DLI_Q: Optional[float]
    SSI_Q: Optional[float]
    HU_Q: Optional[float]
    EVAP_Q: Optional[float]
    ETP_Q: Optional[float]
    PE_Q: Optional[float]
    SWI_Q: Optional[float]
    DRAINC_Q: Optional[float]
    RUNC_Q: Optional[float]
    RESR_NEIGE_Q: Optional[float]
    RESR_NEIGE6_Q: Optional[float]
    HTEURNEIGE_Q: Optional[float]
    HTEURNEIGE6_Q: Optional[float]
    HTEURNEIGEX_Q: Optional[float]
    SNOW_FRAC_Q: Optional[float]
    ECOULEMENT_Q: Optional[float]
    WG_RACINE_Q: Optional[float]
    WGI_RACINE_Q: Optional[float]
    TINF_H_Q: Optional[float]
    TSUP_H_Q: Optional[float]

    class Config:
        from_attributes = True

class PiezoRequest(BaseModel):
    code_bss: str

class PiezoDataOut(BaseModel):
    code_bss: str
    date_mesure: date
    code_nature_mesure: Optional[str]
    code_continuite: Optional[int]
    code_producteur: Optional[int]
    qualification: Optional[str]
    statut: Optional[str]
    mode_obtention: Optional[str]
    profondeur_nappe: Optional[float]
    niveau_nappe_eau: Optional[float]

    class Config:
        from_attributes = True

class PiezoPaginatedResponse(BaseModel):
    total: int
    limit: int
    offset: int
    results: List[PiezoDataOut]        