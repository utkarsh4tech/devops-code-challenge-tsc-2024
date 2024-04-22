<template lang="">
  <div class="menu-bar flex justify-content-between align-items-center">
    <MenuBar :model="items" class="flex justify-content-between align-items-center w-full">
      <template #end>
        <div class="nav-buttons flex align-items-center gap-2">
          <router-link to="/cart">
            <Button
              class="mr-2 shopping-cart-button"
              aria-label="My shopping cart"
              icon="pi pi-shopping-cart"
              :badge="shoppingCart.length ? shoppingCart.length.toString() : null" 
              outlined
            />
          </router-link>

          <template v-if="!isAuthenticated">
            <Button
              class="authentication-button sign-up-button"
              label="Sign up"
              severity="secondary"
              outlined
              @click="onSignupClick"
            />
            <Button
              class="authentication-button sign-in-button"
              label="Sign in"
              @click="onSigninClick"
            />
          </template>

          <template v-else>
            <Button
              class="authentication-button"
              label="Log out"
              @click="onLogoutClick"
            />
          </template>
        </div>
      </template>
    </MenuBar>
    
  </div>
</template>

<script setup>
import { ref } from 'vue';
import MenuBar from 'primevue/menubar';
import Button from 'primevue/button';
import useAuthentication from '@/hooks/useAuthentication'
import router, { openMenuRoutes, restrictedMenuRoutes } from '@/router'
import useShoppingCart from '@/hooks/useShoppingCart';

// #region [HOOKS]
const { isAuthenticated, removeCredentials } = useAuthentication()
const { shoppingCart } = useShoppingCart()
// #endregion [HOOKS]

// #region [REFS]
const items = ref([
  ...openMenuRoutes.map(route => { return { label: route.name, to: route.path} }),
  ...(isAuthenticated.value ? restrictedMenuRoutes.map(route => { return { label: route.name, to: route.path} }): [])
])
// #endregion [REFS]

// #region [EVENT HANDLERS]
function onSigninClick() {
  router.push({name: 'Signin'})
}

function onSignupClick() {
  router.push({name: 'Signup'})
}

function onLogoutClick() {
  removeCredentials()
  router.push({name: 'Signin'})
}
// #endregion [EVENT HANDLERS]
</script>

<style>
.menu-bar {
  .p-menubar {
    background: none;
    border: none;

    .p-menuitem-content {
      background: none !important;

      .p-menuitem-link {
        border-bottom: 3px solid transparent;

        &.router-link-active {
          border-color: var(--primary-color);
        }
      }
    }
  }
}
.p-button {
  position: relative !important;
  overflow: visible !important;
}
.p-badge {
    color: white !important;
    background: red !important;
    position: absolute !important;
    top: -0.75rem !important;
    right: -0.75rem;
    height: 1.5rem !important;
    width: 1.5rem !important;
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
  }

  
</style>