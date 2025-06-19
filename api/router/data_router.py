from typing import List, Annotated
from fastapi import FastAPI, Depends, HTTPException, status, APIRouter, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from database import get_db
from models import Base, users
import crud, auth, schemas



router = APIRouter()


@router.post("/meteo/", response_model=schemas.MeteoDataOut)
def read_meteo_point(request: schemas.MeteoRequest, db: Session = Depends(get_db)):
    """
    Retrieve daily weather data for a given date and Lambert coordinates.

    Args:
        request (MeteoRequest): JSON payload with `date`, `lambx`, and `lamby`.

    Returns:
        MeteoDataOut: Weather data record.

    Raises:
        404: If no matching data is found.
    """
    meteo_data = crud.get_meteo_by_date_coords(db, request.input_date, request.lambx, request.lamby)

    if not meteo_data:
        raise HTTPException(status_code=404, detail="No weather data found for the given point and date.")

    return meteo_data

@router.post("/piezo_value/", response_model=schemas.PiezoPaginatedResponse)
def read_piezo_value(
        request: schemas.PiezoRequest,
        db: Session = Depends(get_db),
        limit: int = Query(50, ge=1, le=1000),
        offset: int = Query(0, ge=0)
    ):

    total, results = crud.get_paginated_piezo_data_by_code_bss(
        db, code_bss=request.code_bss, offset=offset, limit=limit
    )

    if not results:
        raise HTTPException(status_code=404, detail="No piezo data found for the given code_bss.")

    return schemas.PiezoPaginatedResponse(
        total=total,
        limit=limit,
        offset=offset,
        results=results
    )


