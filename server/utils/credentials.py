from server.utils.jwt import decode
from datetime import datetime
from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def verify_token(token: str = Depends(oauth2_scheme)):
  """Verify if a token is valid

  Args:
      token (str, optional): token to verify

  Returns:
      bool: true if the token is valid, false otherwise
  """
  if token:
    payload = decode(token)

    if payload and payload['sub'] and payload['exp']:
      # Check if token has expired
      now = datetime.now().timestamp()
      if (now < payload['exp']):
        # Valid token
        return payload['sub']
  return None

