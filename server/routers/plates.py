from fastapi import APIRouter, Depends
from typing import List
from server.crud.plates import get_plates, add_plate, add_review, get_plate, check_review_allowed
from server.schemas import PlateBase, Plate, PlateCount, Review, ReviewPost, PlateGet, ReviewAllowed
from server.utils.db_utils import get_db
from sqlalchemy.orm import Session
from server.utils.credentials import verify_token
from fastapi import HTTPException, status

router = APIRouter()

@router.get("", response_model=List[PlateGet])
async def search_plates(db_session: Session = Depends(get_db)):
    """Get all plates
    """
    return get_plates(db_session)

@router.get("/{plate_id}", response_model=PlateGet)
async def search_plates(plate_id: int, db_session: Session = Depends(get_db)):
    """Get plate by id

    """
    return get_plate(db_session, plate_id)

@router.post("", response_model=Plate)
async def post_new_plate(
    item: PlateBase,
    db_session: Session = Depends(get_db),
):
    """Add a new plate
    """
    return add_plate(db_session, item)

@router.post('/review', response_model=Review)
async def add_new_review(
    item: ReviewPost,
    db_session: Session = Depends(get_db),
    user_email: str = Depends(verify_token)
):
  """Add a new review to a plate

  Args:
      item (ReviewPost): new review
      db_session (Session, optional): database session
      user_email (str, optional): user_email decoded from access token header
  Returns:
      New review added
  """
  if not user_email:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")
  return add_review(db_session, item, user_email)

@router.get('/{plate_id}/review/allowed', response_model=ReviewAllowed)
async def check_is_review_allowed(
    plate_id: int,
    db_session: Session = Depends(get_db),
    user_email: str = Depends(verify_token)
):
  """ Check if a user is allowed to leave a review to a specific plate

  Args:
      plate_id (int): id of the plate
      db_session (Session, optional): database session
      user_email (str, optional): user email decoded from access token

  Returns:
      bool: true if user is allowed to leave a review, false otherwise
  """
  if not user_email:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")
  return check_review_allowed(db_session, plate_id, user_email)