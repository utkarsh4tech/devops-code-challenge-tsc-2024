from datetime import datetime
from typing import List, Optional, Any

from pydantic.utils import GetterDict
from pydantic import BaseModel

class ReviewPost(BaseModel):
    plate_id: int
    rating: int
    comment: str

class ReviewGet(BaseModel):
    rating: int
    comment: str
    user_short: str

class Review(BaseModel):
    plate_id: int
    rating: int
    comment: str
    user_short: str

class ReviewAllowed(BaseModel):
    is_allowed: bool
class PlateBase(BaseModel):
    plate_name: str
    price: float
    picture: Optional[str] = None

class Plate(PlateBase):
    plate_id: int

    class Config:
        orm_mode = True

class PlateGet(PlateBase):
    plate_id: int
    reviews: List[ReviewGet]


class PlateCount(Plate):
    order_count: int

    class Config:
        orm_mode = True

class PlateOrderBase(BaseModel):
    plate_id: int
    quantity: int

class PlateOrderGetter(GetterDict):
    def get(self, key: str, default: Any = None) -> Any:
        if key in {'plate_name'}:
            return getattr(self._obj.plate, key)
        else:
            return super(PlateOrderGetter, self).get(key, default)

class PlateOrder(PlateOrderBase):
    plate_name: str
    class Config:
        orm_mode = True
        getter_dict = PlateOrderGetter


class OrderBase(BaseModel):
    plates: List[PlateOrderBase]

class StateBase(BaseModel):
    state_id: int
    state_name: str
    user_triggerable: bool

class State(StateBase):
    next_states: List[StateBase]

class NextState(BaseModel):
    state_id: int
    next_state_id: int

class OrderPost(OrderBase):
    order_id: int
    order_time: datetime
    plates: List[PlateOrder]
    user_email: str
    state_id: int
class Order(OrderBase):   
    order_id: int
    order_time: datetime
    plates: List[PlateOrder]
    user_email: str
    state: State

    class Config:
        orm_mode = True

class UserCredentials(BaseModel):
    email: str
    password: str

class UserHashedCredentials(BaseModel):
    email: str
    password_hash: str

class UserBase(BaseModel):
    email: str
    name: str
    firstname: str

class User(UserBase, UserCredentials):
    class Config:
        orm_mode = True

class StoredUser(UserBase, UserHashedCredentials):
    class Config:
        orm_mode = True

class AccessToken(BaseModel):
    access_token: str
    type: str
    expires_in: int

class NextPatch(BaseModel):
    next_state_id: str

class UserWithToken(BaseModel):
    user_info: UserBase
    access_token: AccessToken
