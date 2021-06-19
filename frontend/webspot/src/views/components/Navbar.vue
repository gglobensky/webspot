<template>
<div>
  <ul id="dropdown1" class="dropdown-content w-25">
    <li><router-link to="/Profile" class="d-flex justify-content-center w-100"><span class="d-flex align-items-center"><i class="nopadding material-icons">person</i><p class="ps-2 my-auto">{{$t('profile')}}</p></span></router-link></li>
    <li class="divider"></li>
    <li><router-link to="/find_friends" class="d-flex justify-content-center w-100"><span class="d-flex align-items-center"><i class="nopadding material-icons">person</i><p class="ps-2 my-auto">Caca</p></span></router-link></li>
    <li class="divider"></li>
    <li><a @click="openFindFriendsModal" class="link d-flex justify-content-center w-100" role="button"><span class="d-flex align-items-center"><i class="nopadding material-icons">group_add</i><p class="ps-2 my-auto">{{$t('find_friends')}}</p></span></a></li>
    <li class="divider"></li>
    <li><a @click="signout" class="link d-flex justify-content-center w-100" role="button"><span class="d-flex align-items-center"><i class="nopadding material-icons">logout</i><p class="ps-2 my-auto">{{$t('sign_out')}}</p></span></a></li>
  </ul>

  <nav class="fixed-top">
    <div class="nav-wrapper gradient-default z-2000">
      <a class="hidden-on-xs hidden-on-sm hidden-on-md mx-3" />
      <router-link to="/Home" class="brand-logo ms-md-4 ms-lg-0">Webspot</router-link>
      <a href="#" data-target="mobile-demo" class="sidenav-trigger"><i class="material-icons">menu</i></a>
      <ul class="right hide-on-med-and-down">
      <li><router-link to="/Home"><span class="d-flex align-items-center"><i class="material-icons px-3">home</i>{{$t('home')}}</span></router-link></li>
        <li><a class="dropdown-trigger" href="#!" data-target="dropdown1"><span class="d-flex align-items-center"><i class="nopadding material-icons">touch_app</i>{{$t('actions')}}</span></a></li>
      </ul>
    </div>
  </nav>
  <nav />
  <ul class="sidenav z-2500" id="mobile-demo">
    <li><router-link to="/Home" class="d-flex justify-content-center w-100"><span class="d-flex align-items-center"><i class="nopadding material-icons">home</i>{{$t('home')}}</span></router-link></li>
    <li class="divider"></li>
    <li><router-link to="/Profile" class="link d-flex justify-content-center w-100"><span class="d-flex align-items-center"><i class="nopadding material-icons px-3">person</i>{{$t('profile')}}</span></router-link></li>
    <li class="divider"></li>
    <li><a @click="signout" class="link d-flex justify-content-center w-100" role="button"><span class="d-flex align-items-center"><i class="nopadding material-icons">logout</i>{{$t('sign_out')}}</span></a></li>
  </ul>

</div>
</template>

<script>
import M from 'materialize-css'
import store from '../../store'
import router from '../../router'
import { onMounted } from '@vue/runtime-core'
import { securedAxiosInstance } from '../../backend/axios'
export default {
    name: 'navbar',
    components:{
      
    },
    setup(){
      
      onMounted(() => {
          M.AutoInit()
      })

      function signout() {
          securedAxiosInstance.delete(`/users/sign_out`)
          .then(() => {
              signoutSuccessful()
          }, response => {
              console.log(response)
          })
      }
      function signoutSuccessful() {
        store.commit('setIsLoggedIn', false)
        store.commit('setAuthUser', { user: {} });
        sessionStorage.removeItem('vuex')
        delete localStorage.csrf
        router.push('/')
      }

      return { signout }
    }
}
</script>

<style>

</style>