from typing import List, Annotated
from fastapi import FastAPI, Depends, HTTPException, status, APIRouter, Query
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from database import get_db
from models import Base, users
import crud, auth, schemas, models



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
    """
    Retrieve paginated piezometer measurement data with optional related information.
    
    This endpoint allows fetching piezometer measurements for a specific code_bss
    with optional joins to related tables (info, continuite, nature_mesure, producteur).
    Results are paginated for efficient data retrieval.
    
    Args:
        request (schemas.PiezoRequest): JSON payload containing:
            - code_bss (str): Piezometer identification code
            - include_info (bool): Include Info_nappe data
            - include_continuite (bool): Include Continuite data
            - include_nature (bool): Include Nature_mesure data
            - include_producteur (bool): Include Producteur data
        db (Session): Database session dependency
        limit (int): Maximum number of records to return (1-1000, default: 50)
        offset (int): Number of records to skip (default: 0)
    
    Returns:
        PiezoPaginatedResponse: Paginated response containing:
            - total (int): Total number of matching records
            - limit (int): Applied limit
            - offset (int): Applied offset
            - results (List[PiezoDataOut]): List of piezometer measurements with optional related data
    """
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
        piezo = row[0] if not isinstance(row, models.Nappe) else row

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
            info=info if request.include_info else None,
            continuite=continuite if request.include_continuite else None,
            nature_mesure=nature if request.include_nature else None,
            producteur=producteur if request.include_producteur else None,
        ))

    return schemas.PiezoPaginatedResponse(
        total=total,
        limit=limit,
        offset=offset,
        results=results
    )


@router.get("/piezo/list", response_model=schemas.PiezoListResponse)
def list_all_piezometers(
    db: Session = Depends(get_db),
    limit: int = Query(100, ge=1, le=1000),
    offset: int = Query(0, ge=0)
):
    """
    List all piezometers with their basic information.
    
    Args:
        db: Database session
        limit: Maximum number of results to return
        offset: Number of results to skip
    
    Returns:
        PiezoListResponse: List of piezometers with pagination info
    """
    query = crud.get_all_piezo(db)
    
    piezos = query.offset(offset).limit(limit).all()
    total = query.count()
    
    if not piezos:
        raise HTTPException(status_code=404, detail="No piezometers found.")
    
    return schemas.PiezoListResponse(
        total=total,
        limit=limit,
        offset=offset,
        results=piezos
    )

@router.post("/piezo_meteo/", response_model=schemas.PiezoMeteoResponse)
def get_piezo_with_meteo(
    request: schemas.PiezoMeteoRequest,
    db: Session = Depends(get_db)
):
    """
    Retrieve piezometer measurements with associated meteorological data for a date range.
    
    Args:
        request: JSON payload with code_bss, start_date, and end_date
    
    Returns:
        PiezoMeteoResponse: Combined piezo and meteo data
    
    Raises:
        404: If no data is found for the given parameters
    """
    # Validate date range
    if request.start_date > request.end_date:
        raise HTTPException(
            status_code=400,
            detail="start_date must be before or equal to end_date"
        )
    
    # Check if piezometer exists
    piezo_info = crud.get_piezo_info_by_code_bss(db, request.code_bss)
    if not piezo_info:
        raise HTTPException(
            status_code=404,
            detail=f"Piezometer {request.code_bss} not found"
        )
    
    # Get combined data
    results = crud.get_piezo_and_meteo_by_date_range_for_code_bss(
        db=db,
        code_bss=request.code_bss,
        start_date=request.start_date,
        end_date=request.end_date
    )
    
    if not results:
        raise HTTPException(
            status_code=404,
            detail="No data found for the given date range"
        )
    
    # Format results
    data = []
    for row in results:
        data.append(schemas.PiezoMeteoData(
            code_bss=row.code_bss,
            date_mesure=row.date_mesure,
            profondeur_nappe=row.profondeur_nappe,
            niveau_nappe_eau=row.niveau_nappe_eau,
            meteo=row.Meteo
        ))
    
    return schemas.PiezoMeteoResponse(
        code_bss=request.code_bss,
        start_date=request.start_date,
        end_date=request.end_date,
        count=len(data),
        data=data
    )
