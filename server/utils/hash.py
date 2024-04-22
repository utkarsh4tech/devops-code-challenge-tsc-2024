import hashlib

def hash_password(password):
    """Hash a password using sha256 algorithm

    Args:
        password (str): password to hash

    Returns:
        str: hashed password
    """

    # Combine the password and salt and hash them using SHA-256
    password_hash = hashlib.sha256(password.encode()).hexdigest()

    # Return the salt and hashed password as a tuple
    return password_hash

def verify_password(password: str, hash_to_compare: str):
    """Verify an hashed password against a stored hash

    Args:
        password (str): hashed password to verify
        hash_to_compare (str): hash to compare with

    Returns:
        bool: True if the 2 hash are identical, False otherwise.
    """
    hashed_password = hash_password(password)
    print('hased_password = ', hashed_password)
    print('password = ', password)
    return hashed_password == hash_to_compare
