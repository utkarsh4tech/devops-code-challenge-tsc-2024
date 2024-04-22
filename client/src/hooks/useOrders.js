import { ref } from 'vue'
import useApi from './useApi';

// #region [HOOKS]
const { fetchApi } = useApi()
// #endregion [HOOKS]

// #region [GLOBAL STATE]
const orders = ref(null);
// #endregion [GLOBAL STATE]

function useOrders()  {
  // #region [PUBLIC FUNCTIONS]
  /**
   * Fetch API to update the list of orders
  */
 async function updateOrderList() {
   const response = await fetchApi('orders', 'GET', true, null, false)
   if(response.ok) {
     const dataOrders = await response.json()
     orders.value = dataOrders
    } else {
      orders.value = []
    }
  }
  // #endregion [PUBLIC FUNCTIONS]

  return { orders, updateOrderList }
}

export default useOrders
