<template>
<div>
  <navbar v-if="isLoggedIn" />
  <router-view />
</div>
</template>

<script>
import store from './store'
import Navbar from './views/components/Navbar.vue'
export default {
  name: 'App',
  computed: {
    isLoggedIn () {
      return store.state.isLoggedIn
    }
  },
  components:{
    Navbar
  }
}
</script>

<style>

</style>
