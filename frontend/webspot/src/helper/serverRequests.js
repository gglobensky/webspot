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

export function getAutoCompleteInterestTags(){
    return new Promise(resolve => {

    securedAxiosInstance.get('/tags/interests')
    .then(response => {
        let autocompleteInterestTagData = []
        const tags = response.data.message

        const len = tags.length
        for (let i = 0; i < len; i++){
            autocompleteInterestTagData[tags[i].name] = null
        }
        resolve(autocompleteInterestTagData)
    }), error => {
        console.log(resolve(error))
    }

    })
}


export function getAutoCompleteTalentTags(){
    return new Promise(resolve => {

        securedAxiosInstance.get('/tags/talents')
        .then(response => {
            let autocompleteTalentTagData = []
            const tags = response.data.message
        
            const len = tags.length
            for (let i = 0; i < len; i++){
                autocompleteTalentTagData[tags[i].name] = null
            }
            resolve(autocompleteTalentTagData)
        }), error => {
            console.log(resolve(error))
        }

    })
}






