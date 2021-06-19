import { createStore } from 'vuex'
import createPersistedState from 'vuex-persistedstate'

// Create a new store instance.
export default createStore({
  plugins: [createPersistedState({
    storage: window.sessionStorage,
  })],
  state () {
    return {
        isLoggedIn: false,
        authUser:{}
    }
  },
  mutations: {
    setIsLoggedIn(state, payload){
        state.isLoggedIn = payload;
    },
    setAuthUser(state, payload){
        state.authUser = payload;
    },
    setLoginModal(state, payload){
        state.isLoginOpen = payload;
    }
  }
})