<template>
  <div v-if="shoppingCart.length">
      <DataView :value="shoppingCartWithDetails" :layout="'list'">
          <template #list="slotProps">
              <div class="col-12">
                  <div class="flex flex-column xl:flex-row xl:align-items-start p-4 gap-4">
                      <img class="w-9 sm:w-16rem xl:w-10rem shadow-2 block xl:block mx-auto border-round" :src="slotProps.data.picture" :alt="slotProps.data.name" />
                      <div class="flex flex-column sm:flex-row justify-content-between align-items-center xl:align-items-start flex-1 gap-4">
                          <div class="flex flex-column align-items-center sm:align-items-start gap-3">
                              <div class="text-2xl font-bold text-900">{{ slotProps.data.name }}</div>
                              <router-link :to="`/plate/${slotProps.data.plateId}`" >View the plate</router-link>
                          </div>
                          <div class="flex sm:flex-column align-items-center sm:align-items-end gap-3 sm:gap-2">
                              <span class="text-2xl font-semibold">{{ slotProps.data.price }} € </span>
                              <InputNumber @update:modelValue="(value) => onQuantityChange(slotProps.data.plateId, value )" v-model="slotProps.data.quantity" inputClass="quantity-input" :min="1" showButtons buttonLayout="horizontal" incrementButtonIcon="pi pi-plus" decrementButtonIcon="pi pi-minus"/>
                              <Button icon="pi pi-trash" severity="danger" rounded @click="() => onRemovePlate(slotProps.data.plateId)"></Button>
                          </div>
                      </div>
                  </div>
              </div>
          </template>
      </DataView>
      <div class="total-section flex justify-content-end p-4">
        <span class="text-2xl font-semibold mr-3">Total: </span>
        <span class="text-2xl font-semibold">{{ total }}€</span>
      </div>
  </div>
  <div v-else class="empty-shopping-cart-message">
    Your shopping cart is empty.
  </div>

  <div class="total-section flex justify-content-end p-4" v-if="shoppingCart.length">
    <Button type="button" label="Order" severity="warning"  @click="onOrderButtonClick" />
  </div>
</template>

<script setup>
import { onBeforeMount, ref, watch, computed } from 'vue'
import Button from 'primevue/button';
import DataView from 'primevue/dataview';
import InputNumber from 'primevue/inputnumber';
import { useToast } from 'primevue/usetoast';
import useApi from "@/hooks/useApi";
import useAuthentication from '@/hooks/useAuthentication';
import useShoppingCart from '@/hooks/useShoppingCart'
import router from '@/router';

// #region [REFS]
const shoppingCartWithDetails = ref([]) // contains all plates included in the shopping cart with their details
const plates = ref()
// #endregion [REFS]

// #region [COMPUTED]
// Total price computed
const total = computed(() => {
  return Math.round(shoppingCartWithDetails.value.reduce((total, item) => {
    return total + (item.price * item.quantity)
  }, 0)).toFixed(2)
})
// #endregion [COMPUTED]

// #region [HOOKS]
const { fetchApi } = useApi()
const {isAuthenticated} = useAuthentication()
const { shoppingCart, addPlate, removePlate, updateCart, clearCurrentCart } = useShoppingCart()
const toast = useToast()
// #endregion [HOOKS]

// #region [LIFE CYCLE HOOKS]
onBeforeMount(async () => {
  const data = await fetchApi('plates')
  plates.value = data;
  updateCart()
})
// #endregion [LIFE CYCLE HOOKS]

// #region [EVENT HANDLERS]
/**
 * On quantity change, update shopping cart
 * @param {*} plateId id of the plate
 * @param {*} quantity new quantity
 */
function onQuantityChange(plateId, quantity) {
  addPlate(plateId, quantity)
}

/**
 * Remove a plate from the shopping cart
 * @param {*} plateId id of the plate
 */
function onRemovePlate(plateId) {
  removePlate(plateId)
}

/**
 * On order submitted, send the new order to the server
 */
async function onOrderButtonClick() {
  if (isAuthenticated.value) {
    const plates = shoppingCart.value.map((item) => {return {'plate_id': item.plateId, 'quantity': item.quantity }})
    const body = {
      plates
    }
    const response = await fetchApi('orders', 'POST', true, body, false)
    if (response.ok) {
      clearCurrentCart()
      toast.add({ severity: 'success', summary: 'Order sent', detail: 'Thank you for your order !', life: 5000 })
    } else {
      window.alert('An error occured. Please try again later')
    }

  } else {
    router.push({name: 'Signin'})
    toast.add({ severity: 'warn', summary: 'Authentication required', detail: 'Please, sign in or sign up before continuing.', life: 5000 });
  }
}
// #endregion [EVENT HANDLERS]

// #region [WATCHERS]
// Watch the shopping cart in order to update the shoppingCartWithDetails local ref.
watch(shoppingCart, async () => {
  const newShoppingCartWithDetails = []

  for (const plate of shoppingCart.value) {
    const plateDetails = plates.value.find((item) => item.plate_id === plate.plateId )
    if (plateDetails) {
      newShoppingCartWithDetails.push({
        plateId: plate.plateId,
        name: plateDetails.plate_name,
        price: plateDetails.price,
        quantity: plate.quantity,
        picture: plateDetails.picture
      })
    }
  }
  shoppingCartWithDetails.value = newShoppingCartWithDetails
})
// #endregion [WATCHERS]
</script>

<style>
.quantity-input {
  width: 50px;
  text-align: center;
}

.total-section {
  background: #ffffff;
  color: #495057;
  border-bottom: 1px solid #dee2e6;
}
</style>