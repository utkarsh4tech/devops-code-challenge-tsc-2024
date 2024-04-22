<template>
  <div class="login-wrapper">
    <div class="login-container flex justify-content-center">
      <div class="login-form w-5">
        <h2>Sign up</h2>

        <div class="p-fluid flex flex-column gap-2">
          <div class="p-field flex flex-column align-items-start justify-content-start">
            <label for="email">Email Address</label>
            <InputText id="email" v-model="email" />
          </div>

          <div class="flex justify-content-between gap-3">
            <div class="p-field flex flex-column align-items-start justify-content-start flex-1">
              <label for="name">Name</label>
              <InputText id="name" v-model="name" />
            </div>

            <div class="p-field flex flex-column align-items-start justify-content-start flex-1">
              <label for="firstname">First name</label>
              <InputText id="firstname" v-model="firstname" />
            </div>
          </div>

          <div class="p-field flex flex-column align-items-start justify-content-start">
            <label for="password">Password</label>
            <Password v-model="password" toggleMask />
          </div>

          <div class="form-footer flex flex-column mt-8 gap-2">
            
            <div class="p-field">
              <Button @click="onSignupButtonClick" type="button" label="Sign up" class="p-button p-button-primary" />
            </div>

            <div class="p-field flex align-items-center justify-content-center no-account gap-1">
              <span>Already have an account ?</span>
              <router-link to="/signin">Sign in</router-link>
            </div>

            <div class="p-field">
              <router-link to="/">Go back to menu</router-link>
          </div>
          </div>

          <div v-if="error" class="error">
            <span>{{error}}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onBeforeMount } from 'vue';
import InputText from 'primevue/inputtext';
import Password from 'primevue/password';
import Button from 'primevue/button';
import useAuthentication from '@/hooks/useAuthentication'
import router from '@/router';
import useApi from '@/hooks/useApi';

const { removeCredentials } = useAuthentication()
const { fetchApi } = useApi()


// #region [REFS]
const password = ref('');
const email = ref('');
const error = ref('');
const firstname = ref('');
const name = ref('');
// #endregion [REFS]

// #region [EVENT HANDLERS]
async function onSignupButtonClick() {
  if (!email.value || !password.value || !firstname.value || !name.value) {
    error.value = `Missing fields: ${[!email.value && 'email', !password.value && 'password', !firstname.value && 'firstname', !name.value && 'name'].filter(Boolean).join(', ')}`;
    return;
  }

  const body = {
    email: email.value,
    password: password.value,
    firstname: firstname.value,
    name: name.value
  }

  const response = await fetchApi('users/signup', 'POST', false, body, false)

  if (response.ok) {
    router.push({name: 'Signin'});
    return;
  } else if (response.status === 409) {
    error.value = 'An account with this email already exists.'
    return;
  }
  error.value = 'An error occured. Please try again later.'
}
// #endregion [EVENT HANDLERS]

// #region [LIFE CYCLE HOOKS]
onBeforeMount(() => {
  removeCredentials();
});
// #endregion [LIFE CYCLE HOOKS]
</script>





<style>
.login-form {
  min-width: 250px;
}

.error {
  color: var(--red-500);
}

.no-account {
  margin: 50px 0;
  padding: 20px 0;
  width: 100%;
  border: 2px solid var(--highlight-bg);
}
</style>
