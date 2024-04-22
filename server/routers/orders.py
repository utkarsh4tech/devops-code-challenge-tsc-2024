from fastapi import APIRouter, Depends, HTTPException, status, Query, Header
from fastapi.security import OAuth2PasswordBearer
from server.schemas import OrderBase, Order, OrderPost, NextPatch
from server.crud.orders import get_orders, add_order, get_order, update_order_state_with_id
from server.utils.db_utils import get_db
from sqlalchemy.orm import Session
from typing import List
from server.utils.credentials import verify_token
from server.utils.typing import is_int

router = APIRouter()

@router.get("", response_model=List[Order])
async def get_all_orders(db_session: Session = Depends(get_db), user_email: str = Depends(verify_token)):
  """Get all user's orders

  Args:
      db_session (Session, optional): database session
      user_email (str, optional): user email decoded from access token

  Returns:
      List(Order): list of orders
  """
  if not user_email:
      raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")
  return get_orders(db_session, user_email)

@router.get("/{order_id}", response_model=Order)
async def get_order_by_id(order_id: int, db_session: Session = Depends(get_db), user_email: str = Depends(verify_token)):
  """Get an order by its id

  Args:
      order_id (int): id of the requested order
      db_session (Session, optional): database session
      user_email (str, optional): user email decoded from access token

  Returns:
     related order
  """
  if not user_email:
      raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")
  return get_order(db_session, order_id, user_email)

@router.post("", response_model=Order)
async def add_new_order(
    item: OrderBase,
    db_session: Session = Depends(get_db),
    user_email: str = Depends(verify_token)
):
  """Add a new order to database

  Args:
      item (OrderBase): new order to add
      db_session (Session, optional): database session
      user_email (str, optional): user_email decoded from access token

  Returns:
      New order added to database
  """
  if not user_email:
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")
  return add_order(db_session, item, user_email)

@router.patch("/{order_id}/next", response_model=Order)
async def patch_order_next_step(
    order_id: int,
    item: NextPatch,
    db_session: Session = Depends(get_db),
    user_email: str = Depends(verify_token)
):
  """Update order state to a next process state

  Args:
      order_id (int): id of the order to update
      item (NextPatch): next state
      db_session (Session, optional): database session
      user_email (str, optional): user email decoded from access token
  Returns:
      updated order
  """
  if not user_email:
      raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")
  
  # Check ordeer_id and next_state_id are both integers
  if not is_int(order_id) or not is_int(item.next_state_id):
      raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Bad request")
      
  
  # Check that order exists
  order = get_order(db_session, order_id, user_email)
  if not order:
      raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Resource not found")
  
  # Check if order belongs to user_email
  if order.user_email != user_email:
      raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")
      
  return update_order_state_with_id(db_session, order, item.next_state_id, user_email)