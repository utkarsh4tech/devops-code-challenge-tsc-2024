from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from server.schemas import User, UserBase, UserCredentials, StoredUser, AccessToken, UserWithToken
from server.utils.hash import hash_password, verify_password
from server.utils.jwt import encode

import server.models as md
from datetime import datetime, timedelta

def add_user(db_session: Session, item: User):
  """Add a new user to database

  Args:
      db_session (Session): database session
      item (User): new user to add

  Raises:
      HTTPException: error 409 returned when user already exist.

  Returns:
      UserBase: user details without the password
  """
  # Check if user already exists
  to_fetch = db_session.query(md.User).filter(md.User.email == item.email)

  if to_fetch.first():
    raise HTTPException(status_code=409, detail="Resource already exists.")
  
  # Hash given password before storing it in the database
  password_hash = hash_password(item.password)
  
  user = md.User(email=item.email, user_name=item.name, firstname=item.firstname, password_hash=password_hash)

  db_session.add(user)
  db_session.commit()
  db_session.refresh(user)

  return UserBase(email=user.email, name=user.user_name, firstname=user.firstname)

def get_user(db_session: Session, item: UserCredentials) -> UserWithToken:
  """Get user info and access token

  Args:
      db_session (Session): Database session
      item (UserCredentials): user credentials

  Raises:
      HTTPException: error 401 if invalid credentials

  Returns:
      user info and JWT token
  """
  # Check if user already exists
  to_fetch = db_session.query(md.User).filter(md.User.email == item.email)
  userDb: StoredUser or None = to_fetch.first()

  if userDb:
    # Check if passwords match
    passwordVerified = verify_password(item.password, userDb.password_hash)

    if passwordVerified:
      exp = 2 * 60 * 60 # the lifetime in seconds of the access token
      token = encode(userDb.email, exp)

      user_info: UserBase = {
        "email": userDb.email,
        "name": userDb.user_name,
        "firstname": userDb.firstname
      }

      user_token: AccessToken = {
        "access_token": token,
        "type": "Bearer",
        "expires_in": exp
      }

      return {
        "user_info": user_info,
        "access_token": user_token
      }
  raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")
