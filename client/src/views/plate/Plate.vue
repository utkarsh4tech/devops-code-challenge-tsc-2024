<template>
  <div v-if="plate" class="flex flex-column gap-3 mt-3">
      <div class="flex flex-column sm:flex-row p-4 border-1 surface-border surface-card border-round">
          <div class="flex flex-column align-items-center gap-3 py-5">
              <img
                class="w-12 sm:w-9 shadow-2 border-round"
                :src="plate.picture"
                :alt="plate.plate_name"
              />
            </div>
            <div class="flex flex-column align-items-start py-5 gap-2">
              <div class="text-4xl font-bold">{{ plate.plate_name }}</div>
              <Rating
                v-if="ratingAvg"
                :modelValue="ratingAvg"
                readonly
                :cancel="false"
              />
              <span class="text-2xl font-semibold">{{ plate.price }} €</span>
              <CartButton :withLabel="true" :plateId="plate.plate_id" />
          </div>
      </div>

      <div class="flex flex-column p-4 border-1 surface-border surface-card border-round gap-5" >
        <h2>Reviews</h2>
        <div v-if="reviewAllowed" class="my-review">
          <Button
            v-if="!writeReview"
            icon="pi pi-plus"
            label="Add a review"
            outlined
            @click="onWriteReviewButtonClick"
          />
          <div v-else class="write-review-section flex flex-column align-items-start gap-2">
            <div class="user-container flex flex-row align-items-center gap-2">
              <Avatar icon="pi pi-user" class="user-icon" shape="circle" severity="secondary" />
              <span v-if="userInfo">{{ `${userInfo.firstname} ${userInfo.name.at(0)}.` }}</span>
            </div>
            <Rating v-model="newRating" :cancel="false"  />
            <Textarea
              v-model="newComment"
              placeholder="Share your thoughts about this dish..."
              class="w-full"
            />
            <Button
              label="Post"
              class="align-self-end"
              :disabled="!newRating"
              @click="onSubmitReview"
            />
          </div>
        </div>
        <div v-for="review in plate.reviews" class="review flex flex-column align-items-start gap-2">
          <div class="user-container flex flex-row align-items-center gap-2">
            <Avatar
              icon="pi pi-user"
              shape="circle"
              class="user-icon"
              severity="secondary"
            />
            <span>{{ review.user_short }}</span>
          </div>
          <Rating
            :modelValue="review.rating"
            readonly
            :cancel="false"
          />
          <span class="text-left">{{ review.comment }}</span>
        </div>
        <div v-if="!plate.reviews.length">
          <span>{{no_review_message}}</span>
        </div>
      </div>
  </div>
</template>

<script setup>
import { onBeforeMount, ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import Avatar from 'primevue/avatar';
import Button from 'primevue/button';
import Rating from 'primevue/rating';
import Textarea from 'primevue/textarea';
import CartButton from "@/components/cart-button";
import useApi from '@/hooks/useApi';

const userInfo = JSON.parse(sessionStorage.getItem('user_info'))

// #region [CONSTANTS]
const MESSAGE_ALLOWED = 'Be the first to review this dish! Share your thoughts and experiences with the community.'
const MESSAGE_NOT_ALLOWED = 'No reviews available at the moment. Check back later for updates.'
// #endregion [CONSTANTS]

// #region [HOOKS]
const { fetchApi } = useApi()
const route = useRoute()
// #endregion [HOOKS]

// #region [REFS]
const plate = ref()
const reviewAllowed = ref(false)
const writeReview = ref(false)
const newRating = ref(null)
const newComment = ref('')
// #endregion [REFS]

// #region [COMPUTED]
const no_review_message = computed(() => reviewAllowed.value ? MESSAGE_ALLOWED : MESSAGE_NOT_ALLOWED)

const ratingAvg = computed(() => {
  if (plate.value) {
    return plate.value.reviews.reduce((sum, review) => sum + review.rating, 0) / plate.value.reviews.length;
  }
  return 0
})
// #endregion [COMPUTED]

// #region [LIFE CYCLE HOOKS]
onBeforeMount(async () => {
  await loadPlate()
})
// #endregion [LIFE CYCLE HOOKS]

// #region [EVENT HANDLERS]
function onWriteReviewButtonClick() {
  writeReview.value = true
}

/**
 * On submit review, send the new review to the server
 */
async function onSubmitReview() {
  if (newRating.value && plate.value) {
    const body = {
      'plate_id': plate.value.plate_id,
      'rating': newRating.value,
      'comment': newComment.value
    }

    const newReviewResponse = await fetchApi('plates/review', 'POST', true, body, false);
    if (newReviewResponse.ok) {
      loadPlate()
    } else {
      window.alert('An error occured, please try again later')
    }
  }
}
// #endregion [EVENT HANDLERS]

// #region [UTILS]
/**
 * Load plate details from API
 */
async function loadPlate() {
  const plateId = parseInt(route.path.split('/').at(-1))

  if (Number.isInteger(plateId)) {
    const data = await fetchApi(`plates/${plateId}`, 'GET')
    plate.value = {
      ...data,
      reviews: data.reviews.reverse()
    }
  }

  // fetch orders from server
  const response_allowed = await fetchApi(`plates/${plateId}/review/allowed`, 'GET', true, null, false)
  if (response_allowed.ok) {
    const data_allowed = await response_allowed.json()
    reviewAllowed.value = data_allowed.is_allowed
  }
}
// #endregion [UTILS]
</script>

<style scoped>
.user-icon {
  --icon-size: 30px;
  height: var(--icon-size) !important;
  width: var(--icon-size) !important;
}
</style>