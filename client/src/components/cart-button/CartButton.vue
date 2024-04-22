<template>
  <Button
    :class="`${isInCart ? 'in-cart' : 'not-in-cart'}`"
    :icon="`pi ${isInCart ? 'pi-trash' : 'pi-shopping-cart'}`"
    :label="props.withLabel ? (isInCart ? 'Delete' : 'Add to cart') : null"
    :severity="isInCart ? 'secondary' : ''"
    rounded
    @click="(e) => onCartButtonClick(e, plateId)"
  />
</template>

<script setup>
import { computed } from 'vue'
import useShoppingCart from '@/hooks/useShoppingCart';
import Button from 'primevue/button';

// #region [PROPS]
const props = defineProps(['withLabel', 'plateId'])
// #endregion [PROPS]

// #region [HOOKS]
const { addPlate, removePlate, shoppingCart } = useShoppingCart()
// #endregion [HOOKS]

// #region [COMPUTED]
const isInCart = computed(() => shoppingCart.value.find(item => item.plateId === props.plateId))
// #endregion [COMPUTED]

// #region [EVENT HANDLERS]

/**
 * On cart button click, add or remove plate from shopping cart
 * @param {Event} e 
 * @param {number} plateId 
 */
function onCartButtonClick(e, plateId) {
  e.preventDefault();
  if (isInCart.value) {
    removePlate(plateId)
  } else {
    addPlate(plateId, 1)
  }
}
// #endregion [EVENTHANDLERS]
</script>

<style>

</style>