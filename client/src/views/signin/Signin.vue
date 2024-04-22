<template>
  <div class="login-wrapper">
    <div class="login-container flex justify-content-center">
      <div class="login-form w-5">
        <h2>Sign In</h2>

        <div class="p-fluid flex flex-column gap-2">
          <div class="p-field flex flex-column align-items-start justify-content-start email-input">
            <label for="email">Email Address</label>
            <InputText id="email" v-model="email" />
          </div>

          <div class="p-field flex flex-column align-items-start justify-content-start password-input">
            <label for="password">Password</label>
            <Password v-model="password" toggleMask :feedback="false" @keyup.enter="onSignInButtonClick"/>
          </div>

          <div class="form-footer flex flex-column mt-3 gap-2">
            <div class="p-field">
              <Button @click="onSignInButtonClick" type="button" label="Sign In" class="p-button p-button-primary sign-in-button" />
            </div>

            <div class="p-field flex align-items-center justify-content-center no-account gap-1">
              <span>No account yet ?</span>
              <router-link to="/signup">Create an account</router-link>
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
import useApi from '@/hooks/useApi';
import useAuthentication from '@/hooks/useAuthentication'
import router from '@/router';

// #region [REFS]
const password = ref('');
const email = ref('');
const error = ref('');
// #endregion [REFS]

// #region [HOOKS]
const { removeCredentials, setCredentials, setUserInfo } = useAuthentication()
const { fetchApi } = useApi()
// #endregion [HOOKS]

// #region [EVENT HANDLERS]
/**
 * Check fields in form and send given credentials to the server
 * If authentication is successful, the access token returned by the API will be stored in the session storage
 *  and user will be redirected to Menu page
 */
async function onSignInButtonClick() {
  const body = {
    email: email.value,
    password: password.value
  }
  const response = await fetchApi('users/signin', 'POST', false, body, false)
  if (response.ok) {
    const json = await response.json()
    const userInfo = json.user_info
    const accessTokenObject = json.access_token
    if (accessTokenObject) {
      setCredentials(accessTokenObject);
      setUserInfo(userInfo)
      router.push({name: 'Menu'});
      return;
    }
  } else if (response.status === 401) {
    error.value = 'Incorrect email address or password.'
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

.info-panel {
  background: var(--green-100);
  color: var(--green-800);
  border-radius: 6px;
  padding: 20px;
}
</style>
