
<template>
  <div class="flex flex-column-reverse">
    <div v-for="(order, i) in orders" :key="order.order_id">
        <div class="order-container card flex justify-content-center w-full">
            <OrderList v-model="order.plates" listStyle="height:auto" dataKey="plate_id" @update:selection="onUpdateSelection">
              <template #header>
                <div class="flex flex-row align-items-center justify-content-between">
                  <div class="flex gap-5">
                      <span># {{ order.order_id }}</span>
                      <span>{{ parseTimeToString(order.order_time) }}</span>
                  </div>
                  <div class="right-s ection flex flex-column align-items-end">
                    <div class="state-section flex flex-column align-items-end gap-1">
                      <span :class="`current-state ${order.state.state_name.toLowerCase()}`">{{ order.state.state_name }}</span>
                      <a @click="() => openStatusDialog(order.order_id)" class="cursor-pointer">Track order status ></a>
                    </div>
                    <span class="mt-2">Total: {{ getOrderTotal(order.order_id) }} €</span>
                  </div>
                </div>
               
              </template>
              <template #item="slotProps" :key="`o-${order.order_id}--p${slotProps.item.plate_id}`">
                  <div :to="`/plate/${slotProps.item.plate_id}`"  class="flex flex-wrap p-2 align-items-center gap-3">
                      <img class="w-4rem shadow-2 flex-shrink-0 border-round" :src="plateImage(slotProps.item.plate_id)" :alt="slotProps.item.name" />
                      <div class="flex-1 flex flex-column gap-2">
                          <span class="font-bold w-10rem">{{ slotProps.item.quantity }} x {{ slotProps.item.plate_name }}</span>
                      </div>
                      <span class="font-bold text-900">{{ platePrice(slotProps.item.plate_id) * slotProps.item.quantity }} €</span>
                  </div>
              </template>
            </OrderList>
        </div>
    </div>
    <StatusTracker :orderId="orderIdForDialog" @on-close="onDialogClose"/>
  </div>
    
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import OrderList from 'primevue/orderlist';
import StatusTracker from '@/components/status-tracker';
import useOrders from '@/hooks/useOrders'
import useApi from "@/hooks/useApi";
import router from '@/router'

// #region [REFS]
const plates = ref()
const orderIdForDialog = ref(null)
// #endregion [REFS]

// #region [HOOKS]
let { orders, updateOrderList } = useOrders()
const { fetchApi } = useApi()
// #endregion [HOOKS]

// #region [LIFE CYCLE HOOKS]
onMounted(async () => {
    // fetch plates from server
    const data = await fetchApi('plates')
    plates.value = data;

    await updateOrderList()
});

onUnmounted(() => {
  // Trick for properly unmounting the component despite the global ref "orders"
  orders = null
})
// #endregion [LIFE CYCLE HOOKS]

// #region [EVENT HANDLERS]
function onDialogClose() {
  orderIdForDialog.value = null
}

/**
 * On update selection (event triggered by order list when an order is clicked), redirect to the related plate page
 * @param {*} plate plate object
 */
function onUpdateSelection(plate) {
  if (plate[0] && plate[0].plate_id) {
    router.push(`plate/${plate[0].plate_id}`)
  }
}
// #endregion [EVENT HANDLERS]

// #region [UTILS]
function platePrice(itemId) {
    if (plates.value) {
      return plates.value.find(plate => plate.plate_id === itemId).price
    } else {
      return 0
    }
}

function plateImage(itemId) {
  if (plates.value) {
    return plates.value.find(plate => plate.plate_id === itemId).picture
  } else {
    return ''
  }
}

function parseTimeToString(timestamp) {
  if (timestamp) {
    const regex = /(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2})/;
    let matches = timestamp.match(regex);
    if (matches) {
        return matches[1] + " " + matches[2];
    }
  }
}

function getOrderTotal(orderId) {
    let total = 0;
    orders.value.find(order => order.order_id === orderId).plates.forEach(plate => {
        total += platePrice(plate.plate_id) * plate.quantity;
    });
    return total.toFixed(2);
}

function openStatusDialog(orderId) {
  orderIdForDialog.value = orderId
}
// #endregion [UTILS]
</script>

<style>
.order-container {
  .p-component {
    width: 100%;
  }
  
  .p-orderlist-controls {
    display: none !important;
  }

  .p-orderlist-list {
    min-height: 0 !important;
  }

  .current-state {
    padding: 10px 20px;
    border-radius: 6px;
    border: 1px solid black;

    &.canceled, &.rejected {
      border: 1px solid red;
      color: red;

    }

    &.delivered {
      border: 1px solid green;
      color: green;
    }
  }
}
</style>