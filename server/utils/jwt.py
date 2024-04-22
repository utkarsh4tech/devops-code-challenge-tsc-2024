import base64
import hmac
import json
from datetime import datetime, timedelta

# TO DO move in .env file
SECRET_KEY = "MIICXAIBAAKBgQCI7C7JVxC3ZI6fEkjmB/ZulI4AdCjO0eoQOy9g07gCTWJ"

def encode(sub: str, exp: int):
  """Encode a subject in a JWT token

  Args:
      sub (str): subject to encode
      exp (int): the lifetime in seconds of the access token
  Returns:
      str: JWT token
  """
  payload = {
    "sub": sub,
    "exp": (datetime.now() + timedelta(seconds=exp)).timestamp()
  }

  # Encode the header and payload as base64
  header = base64.b64encode(json.dumps({"alg": "HS256", "typ": "JWT"}).encode("utf-8")).decode("utf-8")
  payload = base64.b64encode(json.dumps(payload).encode("utf-8")).decode("utf-8")

  # Combine the header, payload, and secret key and calculate the HMAC
  signature = base64.b64encode(hmac.new(SECRET_KEY.encode("utf-8"), f"{header}.{payload}".encode("utf-8"), "sha256").digest()).decode("utf-8")

  # Combine all parts to create the JWT token
  jwt_token = f"{header}.{payload}.{signature}"

  return jwt_token

def decode(jwt_token: str):
  """Decode a JWT token

  Args:
      jwt_token (str): jwt token to decode

  Returns:
      None | Any: Payload of the token
  """
  # Split the token into parts
  header, payload, received_signature = jwt_token.split(".")

  # Calculate the expected HMAC signature
  expected_signature = base64.b64encode(hmac.new(SECRET_KEY.encode("utf-8"), f"{header}.{payload}".encode("utf-8"), "sha256").digest()).decode("utf-8")

  # Compare the expected and received signatures
  if received_signature == expected_signature:
      decoded_payload = json.loads(base64.b64decode(payload.encode("utf-8")).decode("utf-8"))
      return decoded_payload
  else:
      return None
