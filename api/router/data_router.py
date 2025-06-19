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
    offset: int = Query(0, ge=0),
):
    total, rows = crud.get_paginated_piezo_data_by_code_bss(
        db=db,
        code_bss=request.code_bss,
        offset=offset,
        limit=limit,
        include_info=request.include_info,
        include_continuite=request.include_continuite,
        include_nature=request.include_nature,
        include_producteur=request.include_producteur
    )

    if not rows:
        raise HTTPException(status_code=404, detail="No piezo data found.")

    results = []
    for row in rows:
        piezo = row[0] if isinstance(row, tuple) else row

        # Initialise les autres à None
        info = continuite = nature = producteur = None

        idx = 1
        if request.include_info:
            info = row[idx]
            idx += 1
        if request.include_continuite:
            continuite = row[idx]
            idx += 1
        if request.include_nature:
            nature = row[idx]
            idx += 1
        if request.include_producteur:
            producteur = row[idx]


        results.append(schemas.PiezoDataOut(
            code_bss=piezo.code_bss,
            date_mesure=piezo.date_mesure,
            niveau_nappe_eau=piezo.niveau_nappe_eau,
            profondeur_nappe=piezo.profondeur_nappe,

            info = info if request.include_info else None,
            continuite = continuite if request.include_continuite else None,
            nature_mesure = nature if request.include_nature else None,
            producteur = producteur if request.include_producteur else None

        ))

    return schemas.PiezoPaginatedResponse(
        total=total,
        limit=limit,
        offset=offset,
        results=results
    )


