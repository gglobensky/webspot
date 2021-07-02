<template>
<div>
  <ul id="dropdown-nav" class="dropdown-content w-25">
    <li><router-link to="/Profile" class="d-flex justify-content-center w-100"><span class="d-flex align-items-center"><i class="nopadding material-icons">person</i><p class="ps-2 my-auto">{{$t('profile')}}</p></span></router-link></li>
    <li class="divider"></li>
    <li><router-link to="/find_friends" class="link d-flex justify-content-center w-100" role="button"><span class="d-flex align-items-center"><i class="nopadding material-icons">group_add</i><p class="ps-2 my-auto">{{$t('find_people')}}</p></span></router-link></li>
    <li class="divider"></li>
    <li><a @click="signout" class="link d-flex justify-content-center w-100" role="button"><span class="d-flex align-items-center"><i class="nopadding material-icons">logout</i><p class="ps-2 my-auto">{{$t('sign_out')}}</p></span></a></li>
  </ul>

  <nav class="fixed-top z-2500">
    <div class="nav-wrapper gradient-default">
      <a class="hidden-on-xs hidden-on-sm hidden-on-md mx-3" />
      <router-link to="/Home" class="brand-logo ms-md-4 ms-lg-0">Webspot</router-link>
      <a href="#" data-target="mobile-demo" class="sidenav-trigger"><i class="material-icons">menu</i></a>
      <ul class="right hide-on-med-and-down">
        <li><router-link to="/Home"><span class="d-flex align-items-center"><i class="nopadding material-icons px-3">home</i>{{$t('home')}}</span></router-link></li>
        <li><router-link to="/Conversations"><span class="d-flex align-items-center"><i class="relative nopadding material-icons px-3"><div :class="alertDot"></div> notifications</i>{{$t('alerts')}}</span></router-link></li>
        <li><a class="dropdown-trigger" href="#!" data-target="dropdown-nav"><span class="d-flex align-items-center"><i class="nopadding material-icons">touch_app</i>{{$t('actions')}}</span></a></li> 
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
import { onMounted, ref, getCurrentInstance, onUnmounted } from '@vue/runtime-core'
import { securedAxiosInstance } from '../../backend/axios'
export default {
    name: 'navbar',
    channels: {
        NotificationChannel: {
            connected() {
                console.log("connected to notifications")
            },
            rejected() {
                console.log("rejected from notifications")
            },
            received(data) {
                this.receivedNotification(data)
            },
            disconnected() {}
        }
    },
    setup(){
      const alertDot = ref("")
      const user_id = store.state.authUser.id
      let cable = {}
      
      onMounted(() => {
        const elems = document.querySelector('.dropdown-trigger');
        M.Dropdown.init(elems, {
            constrainWidth: false
        });

        const instance = getCurrentInstance();
        cable = instance.ctx.$root.$cable

          cable.subscribe({
              channel: 'NotificationChannel',
              user_id: user_id,
              room: 'public'
          });

      })

      onUnmounted(() => {
          unsubscribe()
      })

      function unsubscribe() {
          cable.unsubscribe('NotificationChannel');
      }
        
    
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
      function showNotification(){
        alertDot.value = "alert-dot"
      }
      /*function hideNotification(){
        alertDot.value = ""
      }*/
      function receivedNotification(data){
        showNotification()
        console.log("notification data: " + data)
      }

      return { receivedNotification, signout, alertDot }
    }
}
</script>

<style>

</style>