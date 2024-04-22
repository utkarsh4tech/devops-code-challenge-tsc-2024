
<template>
    <div class="card pt-0">
      <div v-if="userInfo" class="card hi-user text-5xl bold text-left ">
        Hi <span class="user-name">{{ userInfo.firstname }} {{ userInfo.name }}</span>,<br> Hungry for another delicious experience ? 🍕
      </div>
      <DataView :value="plates" :layout="layout">
        <template #header>
          <div class="flex justify-content-end">
            <DataViewLayoutOptions v-model="layout" />
          </div>
        </template>
        
        <template #list="slotProps">
            <router-link :to="`/plate/${slotProps.data.plate_id}`" class="col-12">
                <div class="flex flex-column sm:flex-row xl:align-items-start p-4 gap-4 w-full">
                    <img class="w-9 sm:w-16rem xl:w-10rem shadow-2 block xl:block mx-auto border-round" :src="slotProps.data.picture" :alt="slotProps.data.plate_name" />
                    <div class="flex flex-column sm:flex-row justify-content-between align-items-center flex-1 gap-4">
                        <div class="flex flex-column align-items-center sm:align-items-start gap-1">
                            <div class="text-2xl font-bold text-900">{{ slotProps.data.plate_name }}</div>
                            <Rating v-if="getAvgRating(slotProps.data)" :modelValue="getAvgRating(slotProps.data)" :cancel="false" />
                            <span class="text-2xl font-semibold">{{ slotProps.data.price }} € </span>
                        </div>
                        <div class="flex sm:flex-column align-items-center sm:align-items-end gap-3 sm:gap-2">
                          <CartButton :withLabel="true" :plateId="slotProps.data.plate_id" />
                        </div>
                    </div>
                </div>
              </router-link>
            </template>

            <template #grid="slotProps">
              <div class="col-12 sm:col-6 lg:col-4 xl:col-4 p-2">
                  <router-link :to="`/plate/${slotProps.data.plate_id}`" class="h-full block">
                    <div class="p-4 border-1 surface-border surface-card border-round flex flex-column justify-content-between h-full">
                        <div class="flex flex-column align-items-center gap-3 py-5">
                          <div class="img-wrapper flex align-items-center justify-content-center">
                            <img class="max-h-full max-w-full  shadow-2 border-round" :src="slotProps.data.picture" :alt="slotProps.data.plate_name" />
                          </div>
                            <div class="text-2xl font-bold">{{ slotProps.data.plate_name }}</div>
                        </div>
                        <div class="flex align-items-center justify-content-between align-items-center">
                            <div class="flex flex-column align-items-start">
                              <Rating v-if="getAvgRating(slotProps.data)" :modelValue="getAvgRating(slotProps.data)" :cancel="false" />
                              <span class="text-2xl font-semibold">{{ slotProps.data.price }} €</span>
                            </div>
                            <CartButton :withLabel="false" :plateId="slotProps.data.plate_id" />
                        </div>
                    </div>
                  </router-link>
                </div>
            </template>
        </DataView>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue";
import Rating from 'primevue/rating';
import DataView from 'primevue/dataview';
import DataViewLayoutOptions from 'primevue/dataviewlayoutoptions'
import CartButton from "@/components/cart-button";
import useApi from "@/hooks/useApi";
const userInfo = JSON.parse(sessionStorage.getItem('user_info'))

// #region [REFS]
const plates = ref();
const layout = ref('grid');
// #endregion [REFS]

// #region [HOOKS]
const { fetchApi } = useApi()
// #endregion [HOOKS]

// #region [LIFE CYCLE HOOKS]
onMounted(async () => {
  // fetch plates from server
  const data = await fetchApi('plates')
  plates.value = data;
});
// #endregion [LIFE CYCLE HOOKS]

// #region [UTILS]
function getAvgRating(plate) {
  return plate.reviews.reduce((sum, review) => sum + review.rating, 0) / plate.reviews.length
}
// #endregion [UTILS]
</script>

<style scoped>
.card {
  padding: 2em 0;
}

.img-wrapper {
  height: 165px !important;
}

.user-name {
  color: var(--primary-color);
}
</style>
