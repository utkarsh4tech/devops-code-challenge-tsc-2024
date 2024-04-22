<template>
  <Dialog
    v-if="order"
    class="dialog-wrapper"
    :visible="order !== null"
    modal
    header="Order status"
    :closable="false"
  >
    <template #header>
      <div class="flex flex-row justify-content-between align-items-center w-full">
        <h2>Order status</h2>
        <Button
          class="close-button"
          icon="pi pi-times"
          severity="secondary"
          outlined
          rounded
          @click="onCloseButtonClick"
        />
      </div>
    </template>
    <div class="card flex flex-column align-items-center gap-5 px-0">
      <div class="timeline-wrapper w-full">
        <Timeline :value="STATUS" align="alternate">
              <template #content="slotProps">
                <div class="status-group flex gap-2">
                  <Button
                    v-for="(status, i) in slotProps.item"
                    :class="`state-button ${status.currentName.toLowerCase()} ${status.stateId === order.state.state_id ? 'current' : ''}`"
                    :label="status.stateId <= order.state.state_id ? status.currentName : status.name"
                    :disabled="!order.state.next_states.find((ns) => ns.state_id === status.stateId)"
                    :severity="status.stateId === order.state_id || order.state.next_states.find((ns) => ns.state_id === status.stateId)? 'primary':  'secondary'"
                    :outlined="status.stateId !== order.state_id"
                    @click="(e) => onStateChange(status.stateId)"
                  />
                </div>
              </template>
          </Timeline>
        </div>
          <Button
            :class="`state-button ${CANCEL_STATE.currentName.toLowerCase()} ${CANCEL_STATE.stateId === order.state.state_id ? 'current' : ''}`"
            :label="CANCEL_STATE.stateId === order.state.state_id ? CANCEL_STATE.currentName : CANCEL_STATE.name"
            :disabled="!order.state.next_states.find((ns) => ns.state_id === CANCEL_STATE.stateId)"
            :severity="CANCEL_STATE.stateId === order.state_id || order.state.next_states.find((ns) => ns.state_id === CANCEL_STATE.stateId)? 'primary':  'secondary'"
            :outlined="CANCEL_STATE.stateId !== order.state_id"
            @click="(e) => onStateChange(CANCEL_STATE.stateId)"
          />
    </div>
  </Dialog>
</template>

<script setup>
import { ref, watch, onMounted, onUpdated } from 'vue'
import Timeline from 'primevue/timeline';
import Dialog from 'primevue/dialog';
import Button from 'primevue/button';
import useAuthentication from '@/hooks/useAuthentication'
import useOrders from '@/hooks/useOrders';
import useApi from '@/hooks/useApi';

// #region [CONSTANTS]
const STATUS = ref([
  [
    {
      'stateId': 1,
      'name': 'Submit',
      'currentName': 'Submitted'
    }
  ],
  [ 
    {
      'stateId': 2,
      'name': 'Approve',
      'currentName': 'Approved'
    },
    {
      'stateId': 3,
      'name': 'Reject',
      'currentName': 'Rejected'
    },
  ],
  [
    {
      'stateId': 5,
      'name': 'In preparation',
      'currentName': 'In preparation'
    },
  ],
  [
    {
      'stateId': 6,
      'name': 'In delivery',
      'currentName': 'In delivery'
    }
  ],
  [
    {
      'stateId': 7,
      'name': 'Deliver',
      'currentName': 'Delivered'
    }
  ]
])

const CANCEL_STATE = {
  'stateId': 4,
  'name': 'Cancel',
  'currentName': 'Canceled'
}
// #endregion [CONSTANTS]

// #region [PROPS]
const props = defineProps(['orderId'])
// #endregion [PROPS]

// #region [REFS]
const order = ref(null)
// #endregion [REFS]

// #region [HOOKS]
const { isAuthenticated } = useAuthentication()
const { orders, updateOrderList } = useOrders()
const { fetchApi } = useApi()
// #endregion [HOOKS]

// #region [LIFE CYCLE HOOKS]
onMounted(() => {
  updateOrder()
})

onUpdated(() => {
  updateOrder()
})
// #endregion [LIFE CYCLE HOOKS]

// #region [EVENT HANDLERS]
const emit = defineEmits(['onClose'])

/**
 * On order state change, send request to API to update the order state.
 * @param {number} stateId 
 */
async function onStateChange(stateId) {
  if (isAuthenticated.value) {
    const body = {
      next_state_id: stateId
    }
    const response = await fetchApi(`orders/${order.value.order_id}/next`, 'PATCH', true, body, false)
    if (response.ok) {
      await updateOrderList()
      updateOrder()
    } else {
      window.alert('An error occured. Please try again later')
    }
  } else {
    router.push({name: 'Signin'})
  }
}

function onCloseButtonClick () {
  emit('onClose')
}
// #endregion [EVENT HANDLERS]

// #region [UTILS]

/**
 * Update the local ref order based on the global ref orders.
 */
function updateOrder() {
  if (orders.value) {
    order.value = orders.value.find((order) => order.order_id === props.orderId)
  }
}
// #endregion [UTILS]

</script>

<style>
.dialog-wrapper {
  width: 50vw;
  min-width: 350px;
}

.status-group {
  position: relative;
  top: -25%;
  flex-direction: row;
}
.state-button {
  
  &.canceled, &.rejected {
    background: #FFFFFF !important;
    color: red !important;
    border: 1px solid red !important;

    &:disabled {
      color: var(--text-color-secondary) !important;
      border: 1px solid var(--text-color-secondary) !important;
    }

    &.current {
      color: #FFFFFF !important;
      background: red !important;
      border: 1px solid red !important;
    }
  }

  &.current {
    opacity: 1 !important;
    color: white !important;
    background: var(--primary-color) !important;
    border: 1px solid var(--primary-color) !important;
  }
}

.p-timeline .p-timeline-event {
  &:nth-child(odd) {
    .status-group {
      justify-content: flex-start!important;
    }
  }

  &:nth-child(even) {
    .status-group {
      justify-content: flex-end !important;
    }
  }
}

@media screen and (max-width: 1220px) {
  .status-group {
    flex-direction: column;
  }
  .p-dialog-content {
    padding: 0 !important;
  }
}
</style>