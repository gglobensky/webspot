import { securedAxiosInstance } from '../backend/axios'
import store from '../store'

export const API_URL = 'http://localhost:3000'

export function getAvatarUrl(){
    return new Promise(resolve => {

    let user = store.state.authUser
        securedAxiosInstance.get(`/users/${user.id}/avatar`)
        .then(response => {
            if (response.data.url == null)
                resolve("")
            else
                resolve(API_URL + response.data.url)
        });
    })
}