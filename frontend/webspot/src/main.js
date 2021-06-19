import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import i18n from './i18n'
import styles from './assets/styles.scss'
import 'materialize-css'
import VueAxios from 'vue-axios'
import { securedAxiosInstance, plainAxiosInstance } from './backend/axios'
import 'material-icons/iconfont/material-icons.css';

const app = createApp(App)
app.use(
VueAxios, {
    secured: securedAxiosInstance,
    plain: plainAxiosInstance
})

app.use(i18n)
app.use(store)
app.use(router)
app.use(styles)
app.mount('#app')
