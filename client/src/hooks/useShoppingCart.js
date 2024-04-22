import { ref } from 'vue'
import { decodeAccessToken } from '@/utils/jwt'

// #region [CONSTANTS]
const NOT_AUTH_USER_KEY = 'NULL' // Key used to store unauthenticated user shopping cart
// #endregion [CONSTANTS]

// #region [GLOBAL STATE]
const shoppingCart = ref(getShoppingCartFromCookie(getEmailAddress()))
// #endregion [GLOBAL STATE]

// #region [UTILS]
/**
 * Get email address from access token
 * @returns email address from sessionStorage
 */
function getEmailAddress() {
  let userEmail = 'NULL'
  const accessToken = sessionStorage.getItem('access_token')
  if (accessToken) {
    const tokenObject = decodeAccessToken(JSON.parse(accessToken).token)
    userEmail = tokenObject.payload.sub
  }
  return userEmail
}

/**
 * Get user shopping cart from cookie
 * @param {*} userEmail user's email address
 * @returns shopping cart linked to this email address
 */
function getShoppingCartFromCookie(userEmail) {
  const cartKey = `shoppingCart_${userEmail}`;
  const cookie = document.cookie.split(';').find(cookie => cookie.trim().startsWith(`${cartKey}=`));
  if (cookie) {
    return JSON.parse(cookie.split('=')[1]);
  }
  return [];
}
// #endregion [UTILS]

function useShoppingCart() {
  // #region [PUBLIC FUNCTIONS]
  /**
   * Update cart ref based on the one stored in the cookie
   * @returns 
   */
  function updateCart() {
    const userEmail = getEmailAddress()
    shoppingCart.value = getShoppingCartFromCookie(userEmail)
    return userEmail
  }

  /**
   * Add a plate to the shopping cart
   * @param {number} plateId 
   * @param {number} quantity 
   */
  function addPlate(plateId, quantity) {
    const userEmail = updateCart()
    // Check if the plate is already in the cart
    const existingPlate = shoppingCart.value.find(item => item.plateId === plateId)

    if (existingPlate) {
      // Just update plate quantity
      existingPlate.quantity = quantity;
    } else {
      shoppingCart.value.push({ plateId, quantity });
    }
    updateCookie(userEmail, shoppingCart.value);
  }

  /**
   * Remove a plate from the shopping cart
   * @param {number} plateId 
   */
  function removePlate(plateId) {
    const userEmail = updateCart()
    const index = shoppingCart.value.findIndex((item) => item.plateId === plateId)
    if (index !== -1) {
      shoppingCart.value.splice(index, 1);
      updateCookie(userEmail, shoppingCart.value);
    }
  }

  /**
   * Update shopping cart cookie
   * @param {string} userEmail user's email address
   * @param {*} cartData shopping cart to store in cookie (plates and their related quantities)
   */
  function updateCookie(userEmail, cartData) {
    // Cookie will be valid for a week
    const expires = new Date();
    expires.setDate(expires.getDate() + 7);

    const cartKey = `shoppingCart_${userEmail}`;
    document.cookie = `${cartKey}=${JSON.stringify(cartData)}; expires=${expires.toUTCString()}; path=/`;
  }

  /**
   * Merge the unauthenticated shopping cart with a user's shopping cart
   */
  function mergeCarts() {
    const userEmail = updateCart();
    const notAuthCart = getShoppingCartFromCookie("NULL");

    if (notAuthCart.length > 0) {
      for (const notAuthPlate of notAuthCart) {
        const existingPlate = shoppingCart.value.find((plate) => plate.plateId === notAuthPlate.plateId);
        if (existingPlate) {
          // Sum quantities
          existingPlate.quantity += notAuthPlate.quantity;
        } else {
          // Add plate to user's shopping cart
          shoppingCart.value.push(notAuthPlate);
        }
      }
      // CLear unauthenticated user's shopping cart
      clearNotAuthCart();
    }
    updateCookie(userEmail, shoppingCart.value);
  }


  /**
   * Remove plates in user's shopping cart
   */
  function clearCurrentCart() {
    const userEmail = getEmailAddress()
    clearCart(userEmail)
  }

  /**
   * Remove plate to the related user's shopping cart
   * @param {string} userEmail user's email address
   */
  function clearCart(userEmail) {
    shoppingCart.value = []
    updateCookie(userEmail, [])
  }
  // #endregion [PUBLIC FUNCTIONS]


  // #region [PRIVATE FUNCTIONS]
  /**
   * Remove plates from the anonymous user's shopping cart
  */
  function clearNotAuthCart() {
    updateCookie('NULL', [])
  }
  // #endregion [PRIVATE FUNCTIONS]

  return {
    shoppingCart,
    addPlate,
    clearCart,
    clearCurrentCart,
    mergeCarts,
    removePlate,
    updateCart
  }
}

export default useShoppingCart
