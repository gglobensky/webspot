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
        //This is optional data (seen in user's profile)
        //If it is not set even before loading page
        //Console will show up error even though bio
        //is loaded because it won't be for a split second
        //before getting requests response from server
        state.authUser['profile_attributes'] = {"bio": ""}
        state.authUser['interest_tag_list'] = ""
    },
    setLoginModal(state, payload){
        state.isLoginOpen = payload;
    }
  }
})