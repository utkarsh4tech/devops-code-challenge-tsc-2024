<template>
  <div class="login-wrapper">
    <div class="login-container flex justify-content-center">
      <div class="login-form w-5">
        <h2>Sign up</h2>

        <div class="p-fluid flex flex-column gap-2">
          <div class="p-field flex flex-column align-items-start justify-content-start email-input">
            <label for="email">Email Address</label>
            <InputText id="email" v-model="email" :class="`${!isEmailValid ? 'p-invalid' : ''}`"/>
          </div>

          <div class="flex justify-content-between gap-3">
            <div class="p-field flex flex-column align-items-start justify-content-start flex-1 name-input">
              <label for="name">Name</label>
              <InputText id="name" v-model="name" />
            </div>

            <div class="p-field flex flex-column align-items-start justify-content-start flex-1 firstname-input">
              <label for="firstname">First name</label>
              <InputText id="firstname" v-model="firstname" />
            </div>
          </div>

          <div class="p-field flex flex-column align-items-start justify-content-start password-input">
            <label for="password">Password</label>
            <Password v-model="password" toggleMask @keyup.enter="onSignupButtonClick"/>
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
import { useToast } from 'primevue/usetoast'
import useApi from '@/hooks/useApi';
import useAuthentication from '@/hooks/useAuthentication'
import router from '@/router';

// #region [HOOKS]
const { removeCredentials } = useAuthentication()
const { fetchApi } = useApi()
const toast = useToast()
// #endregion [HOOKS]


// #region [REFS]
const password = ref('');
const email = ref('');
const error = ref(''); 
const firstname = ref('');
const name = ref('');
const isEmailValid = ref(true)
// #endregion [REFS]

// #region [EVENT HANDLERS]
/**
 * On signup button clicked, check all inputs and if they are valid, send the request to the server for registering the new account
 */
async function onSignupButtonClick() {
  if (!email.value || !password.value || !firstname.value || !name.value) {
    error.value = `Missing fields: ${[!email.value && 'email', !password.value && 'password', !firstname.value && 'firstname', !name.value && 'name'].filter(Boolean).join(', ')}`;
    return;
  }

  if (!checkEmail()) {
    isEmailValid.value = false
    error.value = `${email.value} is not a valid email address`
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
    router.push({name: 'Signin'})
    toast.add({ severity: 'success', summary: 'Account created', detail: 'Thanks for creating your account! You can naw log in with your credentials.', life: 3000 })
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

// #region [UTILS]
function checkEmail() {
  if (email.value) {
    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
    return emailRegex.test(email.value);
  }
  return false
}
// #region [UTILS]

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
