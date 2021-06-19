<template>
<form @submit.prevent="signin()">
  <Toast ref="toastRef" :htmlContent="toastHtmlContent" />
  
 <div class="row vh-100-except-xs">
      <div class="col-xs-12 col-sm-4 m4 h-100 nopadding">
        <login-sidebar></login-sidebar>
      </div>
      <div class="d-flex align-items-center col col-12 col-sm-8 h-100 nopadding">
        <div class="vh-50 hidden-on-s hidden-on-md hidden-on-l hidden-on-xl" />
        <div class="container w-100 nopadding">
          <div class="col-sm-9 col-md-8">
            <div class="input-field mx-5">
              <input v-model="state.user.email" id="email" type="text" class="validate">
              <label for="email">{{$t('email')}}</label>
            </div>
            <div class="input-field mx-5">
              <form-field id="'password'" :hasShowPasswordButton="true" :invalidMessage="errors" :validation="isValid" :label="$t('password')" v-model="state.user.password" />
            </div>
          </div>
          <div class="col col-12 ps-5">
            <router-link to="SignUp" class="link" role="button">{{$t('sign_up')}}</router-link>
          </div>
          <div class="col col-5 ps-5">
            <a @click="recoverPassword" role="button" class="link">{{$t('forgot_password')}}</a>
          </div>
          <div class="col col-7 col-sm-4 col-md-3 d-flex justify-content-end pe-5">
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
import Toast from '../components/Toast.vue'
import { ref, reactive } from 'vue';
import { plainAxiosInstance } from '../../backend/axios'
import router from '../../router'
import store from '../../store'
import { getAvatarUrl } from '../../helper/serverRequests'


export default {
  name:'sign-in',
  components: {
    LoginSidebar,
    FormField,
    Toast
  },
  setup(){
    const toastRef = ref()
    const toastHtmlContent = ref("")
    const errors = ref("")
    const isValid = ref(true)
    const state = reactive({
        user:{
            email:"",
            password:""
        }
    })
    function signin () {
      plainAxiosInstance.post('/users/sign_in', state)
        .then(response => signinSuccessful(response))
        ,(error => signinFailed(error))
    }
    function signinSuccessful (response) {
      
      if (response.data.status == "error") {
        signinFailed(response)
        return
      }

      localStorage.csrf = response.data.token
      store.commit('setIsLoggedIn', true)
      store.commit('setAuthUser', response.data.user)

      getAvatarUrl().then(() => router.push('/Home'))
    }
    function signinFailed (error) {
      isValid.value = false;
      errors.value = error.data.message

      delete localStorage.csrf
      store.commit('setIsLoggedIn', false)
    }
    function recoverPassword () {

        plainAxiosInstance.post(`/users/password`, state )
            .then(response => {
                toastHtmlContent.value = response.data.message

                toastRef.value.show()
            })
        }
    
    return { toastHtmlContent, toastRef, signin, state, isValid, errors, recoverPassword }
  }
}
</script>

<style>

</style>