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
        //The user object is incomplete
        //If I query for the data below,
        //and have v-model set to those
        //I will get undefined for a few
        //ms if I don't already have fields


        //Should probably have server return all of the info
        //below instead, caching for better perf
        state.authUser['profile_attributes'] = {"bio": ""}
    },
    setInterestTags(state, payload){
      state.authUser['interest_tag_list'] = payload
    },
    setTalentTags(state, payload){
      state.authUser['talent_tag_list'] = payload
    },
    setLoginModal(state, payload){
        state.isLoginOpen = payload;
    }
  }
})