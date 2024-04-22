<script setup>
import MenuBar from '@/components/MenuBar'
import Toast from 'primevue/toast';

</script>

<template>
  <div class="top-0">
    <MenuBar  v-if="$route.meta.showMenuBar" />
    <router-view />
    <Toast />
  </div>
</template>

<style scoped>
.top-0 {
  width: 100%;
}

</style>
