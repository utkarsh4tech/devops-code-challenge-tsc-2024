from fastapi import APIRouter, Depends
from server.crud.users import add_user, get_user
from server.schemas import UserWithToken, User, UserBase, UserCredentials
from server.utils.db_utils import get_db
from sqlalchemy.orm import Session

router = APIRouter()

@router.post("/signup", response_model=UserBase)
async def post_new_user(
  item: User,
  db_session: Session = Depends(get_db)
):
  """Register a new user

  Args:
      item (User): user to add
      db_session (Session, optional): database session

  Returns:
      new added user
  """
  return add_user(db_session, item)

@router.post("/signin", response_model=UserWithToken)
async def post_authenticate_user(
  item: UserCredentials,
  db_session: Session = Depends(get_db)
):
  """Verify user credentials.
     Returns a JWT token if authentication is successful.
  """
  return get_user(db_session, item)
