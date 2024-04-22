import asyncio
from fastapi import HTTPException, status
import random
from server.schemas import OrderBase, Order, State, StateBase, OrderPost
import server.models as md
from sqlalchemy.orm import Session

def get_order(db_session: Session, order_id: int, user_email: str) :
    """Get an order by id

    Args:
        db_session (Session): database session
        order_id (int): order's id to get
        user_email (str): user email

    Raises:
        HTTPException: 401 unauthorized raised if order does not belong to user

    Returns:
        Order: requested order
    """
    order = (
      db_session.query(
          md.Order,
          md.State,
      )
      .join(md.State, md.State.state_id == md.Order.state_id)
      .filter(md.Order.order_id == order_id)
      .filter(md.Order.user_email == user_email)
      .order_by(md.Order.order_id, md.Order.order_time.desc())
      .first()
    )

    if not order:
      raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Unauthorized')
       

    baseOrder: Order = order[0]
    baseState: StateBase = order[1]

    # Request the next states available for this order
    next_states = (
        db_session.query(md.State)
        .join(md.NextState, md.State.state_id == md.NextState.next_state_id)
        .filter(md.NextState.state_id == baseState.state_id)
        .all()
    )

    order_with_state = Order(
        order_id = baseOrder.order_id,
        order_time = baseOrder.order_time,
        plates = baseOrder.plates,
        user_email = baseOrder.user_email,
        state = State(
            state_id = baseState.state_id,
            state_name = baseState.state_name,
            user_triggerable = baseState.user_triggerable,
            next_states = [
                StateBase(
                    state_id=next_state.state_id,
                    state_name=next_state.state_name,
                    user_triggerable=next_state.user_triggerable
                ) for next_state in next_states
            ]
        )
    )

    return order_with_state

def get_orders(db_session: Session, user_email: str):
    """Get all orders related to a user

    Args:
        db_session (Session): database session
        user_email (str): user email

    Returns:
        List(Order): list of user's orders
    """
    orders = (
      db_session.query(
          md.Order,
          md.State
      )
      .join(md.State, md.State.state_id == md.Order.state_id)
      .filter(md.Order.user_email == user_email)
      .order_by(md.Order.order_id, md.Order.order_time.desc())
      .distinct(md.Order.order_id)
      .all()
    )

    orders_with_states = []

    # Request the next states available for each order
    for order in orders:
      baseOrder: Order = order[0]
      baseState: StateBase = order[1]

      next_states = (
          db_session.query(md.State)
          .join(md.NextState, md.State.state_id == md.NextState.next_state_id)
          .filter(md.NextState.state_id == baseState.state_id)
          .all()
      )

      orders_with_states.append ( 
          Order(
              order_id = baseOrder.order_id,
              order_time = baseOrder.order_time,
              plates = baseOrder.plates,
              user_email = baseOrder.user_email,
              state = State(
                  state_id = baseState.state_id,
                  state_name = baseState.state_name,
                  user_triggerable = baseState.user_triggerable,
                  next_states = [
                      StateBase(
                          state_id=next_state.state_id,
                          state_name=next_state.state_name,
                          user_triggerable=next_state.user_triggerable
                      ) for next_state in next_states
                  ]
              )
          )
      )

    return orders_with_states

def add_order(db_session: Session, item: OrderBase, user_email: str):
    """Add a new order to database

    Args:
        db_session (Session): database session
        item (OrderBase): New order to add
        user_email (str): user email

    Raises:
        HTTPException: 404 not found if the new order contains an unknown plate
        HTTPException: 400 bad request if the new order contains a negative quantity

    Returns:
        Order: new added order
    """
    # Check if all plates exist.
    plate_ids = [plate.plate_id for plate in item.plates]
    plate_ids_result = db_session.query(md.Plate.plate_id).filter(
        md.Plate.plate_id.in_(plate_ids)
    )
    if plate_ids_result.count() != len(plate_ids):
        raise HTTPException(
            status_code=404,
            detail="Plate does not exist."
        )

    # Check if quantity of each plate is non-negative.
    for plate in item.plates:
        if plate.quantity <= 0:
            raise HTTPException(
                status_code=400,
                detail="Non-positive plate quantity."
            )

    order = md.Order(state_id=1, user_email = user_email)

    # Add PlateOrder objects.
    for plate in item.plates:
        plate_order = md.PlateOrder(
            plate_id=plate.plate_id,
            order_id=order.order_id,
            quantity=plate.quantity
        )
        order.plates.append(plate_order)

    db_session.add(order)
    db_session.commit()
    db_session.refresh(order)

    # Uncomment the next line to start the state machine
    # start_background_state_machine(db_session, order.order_id)

    return get_order(db_session, order.order_id, user_email)

def update_order_state_with_id(db_session: Session, order: Order, next_state_id: int, user_email: str):
  """Update the state of an order

  Args:
      db_session (Session): database session
      order (Order): order to update
      next_state_id (int): Next order state
      user_email (str): user email

  Raises:
      HTTPException: 400 bad request if the new order state does not respect the state transition.

  Returns:
      Order: updated order object
  """
  if (order):
    # Check if the new state id corresponds to one of the next possible order state.
    is_corresponding = any(int(obj.state_id) == int(next_state_id) for obj in order.state.next_states)
    if (is_corresponding):
      # Get again order from database in case the automatic state machine has updated the current order state.
      orderDb = db_session.query(md.Order).filter(md.Order.order_id == order.order_id).first()

      if (orderDb):
          orderDb.state_id = next_state_id
          db_session.commit()
          updated_order = get_order(db_session, order.order_id, user_email)
          return updated_order
    else:
       raise HTTPException(
            status_code=400,
            detail=f"The next state {next_state_id} does not adhere to the state transition defined."
        )
    return None

def start_background_state_machine(db_session: Session, order_id: int, user_email: str):
  """Start the state machine in background

  Args:
      db_session (Session): database session
      order_id (int): Order id
      user_email (str): user email
  """
  asyncio.ensure_future(update_order_state(db_session, order_id, user_email))
 
async def update_order_state(db_session: Session, order_id: int, user_email: str):
    """Update order state to one of the next possible state

    Args:
        db_session (Session): database session
        order_id (int): order id
        user_email (str): user email
    """
    await asyncio.sleep(60)  
    order = get_order(db_session, order_id, user_email)
    if (order and len(order.state.next_states)):
      orderDb = db_session.query(md.Order).filter(md.Order.order_id == order.order_id).first()
      if (orderDb):
        next_state_id = 0
        
        # Randomize the next state choice when state order is 'submitted'.
        if order.state.state_id == 1:
            # Probabilitty to be approved 0.9 and to be rejected = 0.1
            next_state_id = random.choices([2, 3], weights=[0.9, 0.1])[0]
          
        else:
          for next_state in order.state.next_states:
              if not next_state.user_triggerable:
                 # Select the first state non user triggerable
                 next_state_id = next_state.state_id
        
        # Update order state
        orderDb.state_id = next_state_id
        db_session.commit()
        await update_order_state(db_session, order_id)
       
       


  