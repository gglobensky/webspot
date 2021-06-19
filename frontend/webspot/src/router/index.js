import { createRouter, createWebHistory } from 'vue-router'
import SignIn from '../views/pages/SignIn.vue'
import SignUp from '../views/pages/SignUp.vue'
import Home from '../views/pages/Home.vue'
import Profile from '../views/pages/Profile.vue'
import FriendSearch from '../views/pages/FriendSearch.vue'
import store from '../store/index'

const routes = [
  { path: '/', name: 'SignIn', component: SignIn },
  { path: '/signup', name: 'SignUp', component: SignUp },
  { path: '/home', name: 'Home', component: Home, meta: { middleware:'auth' } },
  { path: '/profile', name: 'Profile', component: Profile, meta: { middleware:'auth' } },
  { path: '/find_friends', name: 'FriendSearch', component: FriendSearch, meta: { middleware:'auth' } }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

router.beforeEach((to, _, next) => {
  if (to.meta.middleware){
      const middleware = require(`../middleware/${to.meta.middleware}`);
      if (middleware){
          middleware.default(next, store);
      }
      else{
          next();
      }
  }
  else{
      next();
  }
})

export default router
