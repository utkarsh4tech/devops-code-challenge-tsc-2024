from fastapi import HTTPException, status
import server.models as md
from server.schemas import PlateBase, Review, ReviewPost, PlateGet, ReviewGet, ReviewAllowed
from sqlalchemy.orm import Session, joinedload
from typing import List

def get_plates(db_session: Session):
    """Get all plates

    Args:
        db_session (Session): database session

    Returns:
        List(Plate): list of all plates
    """
    plates_with_reviews_db = (
      db_session.query(md.Plate)
      .outerjoin(md.Review, md.Plate.plate_id == md.Review.plate_id)
      .options(joinedload(md.Plate.reviews))
      .all()
    )

    plates_with_reviews: List[PlateGet] = []

    # Get reviews details for each plate
    for plate in plates_with_reviews_db:
        reviews: List[ReviewGet] = []
        for review in plate.reviews:
          user = (
            db_session.query(md.User)
            .filter(md.User.email == review.user_email)
            .first()
          )

          if user:
            reviews.append(
                ReviewGet(
                  rating = review.rating,
                  comment = review.comment,
                  user_short=f"{user.firstname} {user.user_name[0]}."
                )
            )

        plates_with_reviews.append(
          PlateGet(
              plate_id = plate.plate_id,
              plate_name=plate.plate_name,
              price = plate.price,
              picture = plate.picture,
              reviews = reviews
          )
        )

    return plates_with_reviews

def get_plate(db_session: Session, plate_id: int):
    """Get plate by id

    Args:
        db_session (Session): database session
        plate_id (int): plate id

    Raises:
        HTTPException: 404 not found if plate is unknown

    Returns:
        Plate: requested plate
    """
    plate_db = (
      db_session.query(md.Plate)
      .outerjoin(md.Review, md.Plate.plate_id == md.Review.plate_id)
      .options(joinedload(md.Plate.reviews))
      .filter(md.Plate.plate_id == plate_id)
      .first()
    )

    reviews: List[ReviewGet] = []
    if not plate_db:
       raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Resource not found')
    for review in plate_db.reviews:
      user = (
        db_session.query(md.User)
        .filter(md.User.email == review.user_email)
        .first()
      )

      if user:
        reviews.append(
            ReviewGet(
              rating = review.rating,
              comment = review.comment,
              user_short=f"{user.firstname} {user.user_name[0]}."
            )
        )

    return PlateGet(
        plate_id = plate_db.plate_id,
        plate_name=plate_db.plate_name,
        price = plate_db.price,
        picture = plate_db.picture,
        reviews = reviews
    )

def add_plate(db_session: Session, item: PlateBase):
    """Add a new plate to database

    Args:
        db_session (Session): database session
        item (PlateBase): new plate to add

    Raises:
        HTTPException: 409 conflict if a plate already exists with the same name

    Returns:
        Plate: new plate
    """
    to_fetch = db_session.query(md.Plate).filter(md.Plate.plate_name == item.plate_name)

    if to_fetch.first():
        raise HTTPException(status_code=409, detail="Resource already exists.")

    item = md.Plate(plate_name=item.plate_name, price=item.price, picture=item.picture)

    db_session.add(item)
    db_session.commit()
    db_session.refresh(item)

    return item

def add_review(db_session: Session, item: ReviewPost, user_email: str) -> Review:
  """Add a new review to a plate

  Args:
      db_session (Session): database session
      item (ReviewPost): new review
      user_email (str): email of user's who wrote this review

  Raises:
      HTTPException: 401 Unauthorized if user not authorized to leave a review for this plate
      HTTPException: 409 conflict if user already left a review for this plate

  Returns:
      Review: new review added
  """
  plate_orders = (
    db_session.query(md.PlateOrder)
    .filter(md.PlateOrder.plate_id == item.plate_id).
    all()
  )

  # Check if order belongs to user
  orders = (
    db_session.query(md.User, md.Order)
    .join(md.Order, md.Order.user_email == md.User.email)
    .filter(md.User.email == user_email)
    .filter(md.Order.order_id.in_([plate_order.order_id for plate_order in plate_orders]))
    .filter(md.Order.state_id == 7)
    .all()
  )

  if not len(orders):
    raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Unauthorized')
  

  # Get user information
  user = (
    db_session.query(md.User.email, md.User.firstname, md.User.user_name)
    .filter(md.User.email == user_email)
    .first()
  )

  if not user:
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")

  # Verify if a review already exist for this plate from this user
  review = (
     db_session.query(md.Review)
     .filter(md.Review.plate_id == item.plate_id)
     .filter(md.Review.user_email == user_email)
     .first()
  )

  if review:
    raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="A review already exist" )
  
  reviewDb = md.Review(
     plate_id = item.plate_id,
     user_email = user_email,
     rating = item.rating,
     comment = item.comment
  )

  db_session.add(reviewDb)
  db_session.commit()
  db_session.refresh(reviewDb)


  return Review(
    plate_id=item.plate_id,
    rating=item.rating,
    comment= item.comment,
    user_short = f"{user.firstname} {user.user_name[0]}."
  )

def check_review_allowed(db_session: Session, plate_id: int,  user_email: str) -> ReviewAllowed:
  """Check if a user is allowed to leave a review for a plate

  Args:
      db_session (Session): database session
      plate_id (int): plate id
      user_email (str): user email

  Returns:
      ReviewAllowed: object containing a boolean "is_allowed", true if user is allowed, false otherwise
  """
  res = {
      'is_allowed': False
  }

  # Check if there is already a review from this user for this plate
  review = (
     db_session.query(md.Review)
     .filter(md.Review.plate_id == plate_id)
     .filter(md.Review.user_email == user_email)
     .first()
  )

  if not review:
    plate_orders = (
      db_session.query(md.PlateOrder)
      .filter(md.PlateOrder.plate_id == plate_id).
      all()
    )

    # Check if there are orders that belongs to the user AND with state "delivered"
    orders = (
      db_session.query(md.User, md.Order)
      .join(md.Order, md.Order.user_email == md.User.email)
      .filter(md.User.email == user_email)
      .filter(md.Order.order_id.in_([plate_order.order_id for plate_order in plate_orders]))
      .filter(md.Order.state_id == 7)
      .all()
    )

    if len(orders) :
      res = {
        'is_allowed': True
      }

  return res