// #region [CONSTANTS]
const API_URL = import.meta.env.VITE_BACKEND_URL
// #endregion [CONSTANTS]

function useApi () {
  /**
   * Fetch wrapper toward application API
   * @param {*} path
   * @param {*} method 
   * @param {*} authRequired true if authentication required
   * @param {*} body 
   * @param {*} json true if this function should directly parse response in JSON format
   * @returns the fetch response (raw response or JSON data)
   */
  async function fetchApi(path, method = 'GET', authRequired = false,  body = null, json = true) {
    const headers = {
      'Content-Type': 'application/json'
    }
    if (authRequired) {
      // Include access token in Authorization headers
      const accessToken = JSON.parse(sessionStorage.getItem('access_token'))
      if (accessToken && accessToken.type && accessToken.token) {
        headers.Authorization =  `${accessToken.type} ${accessToken.token}`
      } 
    }

    const requestOptions = {
      method,
      headers
    }

    if (body) {
      requestOptions.body = JSON.stringify(body)
    }

    const response = await fetch(`${API_URL}${path}`, requestOptions)

    if (!json) {
      return response
    } else {
      const data = await response.json()
      return data
    }
  }

  return { fetchApi }
}

export default useApi
