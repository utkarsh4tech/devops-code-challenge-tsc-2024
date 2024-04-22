import { ref } from 'vue';
import useShoppingCart from './useShoppingCart';

const { mergeCarts, updateCart } = useShoppingCart()

// #region [GLOBAL STATE]
const isAuthenticated = ref(sessionStorage.getItem('access_token') !== null)
// #endregion [GLOBAL STATE]

function useAuthentication() {
  // #region [PUBLIC FUNCTIONS]
  /**
   * Store token in session storage
   * @param {*} tokenObj access token object containing the token, its type and the expiration date.
   */
  const setCredentials = (tokenObj) => {
    const { access_token, type, expires_in } = tokenObj
    if (access_token && type && expires_in) {
      const token = {
        token: access_token,
        type,
        expires_in
      }
      sessionStorage.setItem('access_token', JSON.stringify(token))
      isAuthenticated.value = true
  
      // Merge the "no auth" cart with the user's cart
      mergeCarts()
    }
  }

  /**
   * Store user info in session storage (email, name and firstname)
   * @param {*} infoObj 
   */
  const setUserInfo = (infoObj) => {
    const {email, name, firstname} = infoObj
    if (email && name && firstname) {
      sessionStorage.setItem('user_info', JSON.stringify(infoObj))
    }
  }

  /**
   * Remove credentials from session storage
   */
  const removeCredentials = () => {
    sessionStorage.removeItem('access_token')
    sessionStorage.removeItem('user_info')
    isAuthenticated.value = false
    updateCart()

  }
  // #endregion [PUBLIC FUNCTIONS]

  return {
    isAuthenticated,
    removeCredentials,
    setCredentials,
    setUserInfo
  }
}

export default useAuthentication
