<template>
<form @submit.prevent="signup()">
 <div class="row vh-100-except-xs">
      <div class="col-xs-12 col-sm-4 m4 h-100 nopadding">
        <login-sidebar></login-sidebar>
      </div>
      <div class="d-flex align-items-center col col-12 col-sm-8 h-100 nopadding">
        <div class="vh-50 hidden-on-s hidden-on-md hidden-on-l hidden-on-xl" />
        <div class="container w-100 nopadding">
          <div class="col-sm-9 col-md-8">
            <div class="input-field mx-5">
              <form-field :id="'email'" :hasShowPasswordButton="false" :invalidMessage="errors.email" :validation="errors.email == ''" :label="$t('email')" v-model="state.user.email" />
            </div>
            <div class="mx-5">
              <form-field :id="'password'" :hasShowPasswordButton="true" :invalidMessage="errors.password" :validation="errors.password == ''" :label="$t('password')" v-model="state.user.password" />
            </div>
              <div class="mx-5">
                <form-field :id="'confirmation'" :hasShowPasswordButton="true" :invalidMessage="errors.password_confirmation" :validation="errors.password_confirmation == ''" :label="$t('confirmation')" v-model="state.user.password_confirmation" />
              </div>
          </div>
          <div class="col col-12 ps-5">
            <router-link to="/" class="link" role="button">{{$t('sign_in')}}</router-link>
          </div>

          <div class="col offset-5 offset-sm-4 offset-md-4 ps-5 col-7 col-sm-5 col-md-4 d-flex justify-content-end pe-5">
            <button class="waves-effect waves-light btn">{{$t('login')}}</button>
          </div>
        </div>
      </div>
  </div>
</form>
</template>

<script>
import LoginSidebar from '../components/LoginSidebar.vue'
import FormField from '../components/FormField.vue'
import { reactive } from 'vue';
import router from '../../router'
import store from '../../store'
import { getAvatarUrl } from '../../helper/serverRequests'
import { plainAxiosInstance } from '../../backend/axios'
export default {
  name:'sign-up',
  components: {
    LoginSidebar,
    FormField
  },
  setup(){
    const errors = reactive({
      email:"",
      password:"",
      password_confirmation:""
    })
    const state = reactive({
      user:{
        email:"",
        password:"",
        password_confirmation:""
      }
    })
    function signup () {
      plainAxiosInstance.post('/users', state)
        .then(response => signinSuccessful(response))
    }
    function signinSuccessful (response) {
      if (!response.data.token) {
        signinFailed(response)
        return
      }

      localStorage.csrf = response.data.token
      localStorage.signedIn = true
      store.commit('setIsLoggedIn', true)
      store.commit('setAuthUser', response.data.user)

      getAvatarUrl().then(() => router.push('/Home'))

    }
    function signinFailed (error) {

        let response = JSON.parse(error.data.message)
        errors.email = response.email? response.email[0] : ''
        errors.password_confirmation = response.password_confirmation? response.password_confirmation[0] : ''
        errors.password = response.password? response.password[0] : ''

        console.log(JSON.stringify(errors.email ))
        delete localStorage.csrf
        delete localStorage.signedIn
      
    }

    return { signup, state, errors }
  }
}
</script>

<style>

</style>