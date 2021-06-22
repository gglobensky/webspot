<template>
<div>
    <Toast ref="toastRef" :htmlContent="toastHtmlContent" />
    <Modal id="passwordChangeModal" ref="passwordChangeModalRef" :onCloseEnd="clearPasswordFields">
        <template #header>{{$t('change_password')}}</template>
        <template #body>
            <form-field :hasShowPasswordButton="true" id="'password'" :invalidMessage="errors.password" :validation="errors.password == ''" :label="$t('password')" v-model="state.user.password" />
            <form-field :hasShowPasswordButton="true" id="'confirmation'" :invalidMessage="errors.password_confirmation" :validation="errors.password_confirmation == ''" :label="$t('confirmation')" v-model="state.user.password_confirmation" />
            <form-field :hasShowPasswordButton="true" id="'current_password'" :invalidMessage="errors.current_password" :validation="errors.current_password == ''" :label="$t('current_password')" v-model="state.user.current_password" />
        </template>
        <template #footer><button @click="updatePassword()" class="waves-effect waves-light btn">{{$t('update')}}</button></template>
    </Modal>

    <form @submit.prevent="updateProfile()">
        <div class="row d-flex justify-content-center justify-content-sm-start align-items-start">
            <div class="col pt-5 ps-0 ps-sm-5 col-6 col-sm-4 col-md-4 col-lg-3 d-flex justify-content-center">
                <label for="file-input">
                    <img :src="avatarUrl" id="output" class="nopadding w-100 ms-4 mt-4 border border-secondary rounded-circle" alt="avatar" style="min-height: 250px; min-width: 250px; max-height:250px; max-width: 250px" role='button'>
                </label>
                <input type="file" accept=".jpg,.jpeg,.png" style="display:none" @change="onFileChange" id="file-input" >
            </div>
            <div class="col col-8 col-sm-6 offset-sm-1 col-md-5 offset-md-2 mt-5">
                <form-field id="'username'" :invalidMessage="errors.username" :validation="errors.username == ''" :label="$t('username')" v-model="state.user.username" />
                <form-field id="'email'" :invalidMessage="errors.email" :validation="errors.email == ''" :label="$t('email')" v-model="state.user.email" />
                <div class="chips chips-autocomplete"></div>
                <div class="vh-30">
                    <form-area id="bio" :characterLimit="characterLimit" :invalidMessage="$t('too_many_chars')" :validation="state.user.profile_attributes.bio.length <= characterLimit" :label="$t('about_me')" v-model="state.user.profile_attributes.bio" />
                </div>
            </div>
            <div class="row">
                <div class="col ps-sm-5 col-4 col-sm-4 d-flex justify-content-start">
                    <a class="link modal-trigger" @click="openPasswordModal()" role="button" >{{$t('change_password')}}</a>
                </div>
                <div class="col col-8 col-sm-7 col-md-7 col-lg-6 d-flex justify-content-end">
                    <button class="waves-effect waves-light btn">{{$t('update')}}</button>
                </div>
            </div>
        
        </div>
     </form>
</div>

</template>

<script>
import store from '../../store'
import { ref, reactive, onMounted } from '@vue/runtime-core'
import { securedAxiosInstance } from '../../backend/axios'
import FormField from '../components/FormField.vue'
import FormArea from '../components/FormArea.vue'
import Modal from '../components/Modal.vue'
import Toast from '../components/Toast.vue'
import M from 'materialize-css'
import router from '../../router'
import { DirectUpload } from "@rails/activestorage"
import { API_URL } from '../../helper/serverRequests'
import { capitalizeFirstLetter } from '../../helper/helperMethods'
import { useI18n } from 'vue-i18n'
export default {
    components:{
        FormField,
        FormArea,
        Modal,
        Toast
    },
    setup(){
        const { t } = useI18n()
        let updatedAvatar = false
        let avatar = {}
        const characterLimit = 120
        const avatarUrl = ref("")
        const errors =  reactive({
            username:"",
            email:"",
            bio:"",
            password:"",
            password_confirmation:"",
            current_password:""
        })
        const state = reactive({
            user:{
                username:"",
                email:"",
                password:"",
                password_confirmation:"",
                current_password:"",
                interest_tag_list:"",
                profile_attributes:{
                    bio:""
                }
            }
        })
        const passwordChangeModalRef = ref()
        const toastRef = ref()
        const toastHtmlContent = ref("")
        let autocompleteData = {}
        let chipsData = []
        let instances = []
        onMounted(() => {
            M.CharacterCounter.init(document.querySelectorAll('.has-character-counter'));//is it useless?

            getInterestTags()
            state.user = store.state.authUser
            
            securedAxiosInstance.get(`/users/${state.user.id}/profile`)
                .then(response => {
                    state.user.profile_attributes = response.data.profile
                    avatarUrl.value = API_URL + response.data.avatar
                    state.user.interest_tag_list = response.data.interest_tag_list
                    setupInterestTagList()

                    if (!avatarUrl.value){
                        avatarUrl.value = require('@/assets/images/user.png')
                    }
                }), error => {console.log(error)}
              
        })
        function updatePassword(){
            //Since passwords are updated via a popup over the rest
            //of the profile, we need to ignore the rest of the fields

            /*if (!this.validateNewPassword())
                return*/

            let patchedUser = {}

            patchedUser.password = state.user.password
            patchedUser.password_confirmation = state.user.password_confirmation
            patchedUser.current_password = state.user.current_password

            securedAxiosInstance.put(`/users`, { user: patchedUser })
            .then(response => {
                if (response.data.status == 'error'){
                        
                    const current_errors = JSON.parse(response.data.message)
                    errors.password = current_errors.password[0]
                    errors.password_confirgetTagsmation = current_errors.password_confirmation[0]
                    errors.current_password = capitalizeFirstLetter(current_errors.current_password[0])

                    return
                }
                passwordChangeModalRef.value.close()
                clearPasswordFields()

                toastHtmlContent.value = t("updated_password")
                toastRef.value.show()
            }), error => {
                console.log(error)
                toastHtmlContent.value = t("update_password_failed")
                toastRef.value.show()
            }

        }
        function getInterestTags(){
            securedAxiosInstance.get('/tags/interests')
            .then(response => {
                const tags = response.data.message
                
                const len = tags.length
                for (let i = 0; i < len; i++){
                    autocompleteData[tags[i].name] = null
                }

            }), error => {
                console.log(error)
            }
        }
        function addInterestTagListToUser(){
            const len = instances[0].$chips.length;
            state.user['interest_tag_list'] = ""

            const lastIndex = len - 1
            state.user.interest_tag_list = ""
                
            for (let i = 0; i < len; i++){
                state.user.interest_tag_list += instances[0].$chips[i].firstChild.data

                if (i != lastIndex){
                    state.user.interest_tag_list += ', '
                }
            }

        }
        function setupInterestTagList(){
            addInterestTagListAsChips()
            const elems = document.querySelectorAll('.chips');
 
            instances = M.Chips.init(elems, {
                placeholder: "Interests",
                data: chipsData,
                autocompleteOptions: {
                    data: autocompleteData,
                    limit: Infinity,
                    minLength: 1
                }
            });
        }
        function addInterestTagListAsChips(){
            const userInterests = state.user.interest_tag_list.split(', ')
            
            if (userInterests[0] != ""){
                const len = userInterests.length
                for (let i = 0; i < len; i++){
                    chipsData.push({ tag: userInterests[i]})
                }
            }
            else{
                chipsData = []
            }
        }
        function clearPasswordFields(){
            state.user.password = ""
            state.user.password_confirmation = ""
            state.user.current_password = ""
            errors.password = ""
            errors.password_confirmation = ""
            errors.current_password = ""
        }
        function onFileChange(e) {
            var files = e.target.files || e.dataTransfer.files;
            if (!files.length)
                return;
            avatar = files[0]

            updatedAvatar = true
            avatarUrl.value = URL.createObjectURL(avatar)
        }
        function updateProfile(){

          addInterestTagListToUser()
            /*if (!this.validateEmail(this.current_user.email)){
                this.errors.email = "Invalid email"

                return
            }*/
            if (updatedAvatar){
                const url = `${API_URL}/rails/active_storage/direct_uploads`

                const upload = new DirectUpload(avatar, url,  {
                    directUploadWillCreateBlobWithXHR: (xhr) => {
                        xhr.setRequestHeader("Authorization", localStorage.csrf)
                    }})

                upload.create((error, blob) => {
                    if (error){
                        console.log(error)
                    }
                    else {
                        state.user.avatar = blob.signed_id
                        putProfileDataToServer()
                            .then(() => router.push('/Home'))
                            , error => console.log(error)
                    }   
                })
            } else {
                putProfileDataToServer()
                    .then(() => router.push('/Home'))
                    , error => console.log(error)
            }

        }
        function putProfileDataToServer(){
            return new Promise(resolve => {
            securedAxiosInstance.put(`/users`, state)
                .then(() => {
                    store.commit('setAuthUser', state.user)
                  resolve()
                }), error => {resolve(error)}
            })
        }
        function openPasswordModal(){
            passwordChangeModalRef.value.open()
        }

        return { toastRef, toastHtmlContent, passwordChangeModalRef, openPasswordModal, clearPasswordFields, updatePassword, characterLimit, state, errors, avatarUrl, onFileChange, updateProfile }
    }
}
</script>