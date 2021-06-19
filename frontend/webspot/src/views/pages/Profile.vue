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
                    <img :src="avatarUrl" id="output" class="nopadding w-100 ms-4 mt-4 border border-secondary rounded-circle" alt="avatar" max-width max-height="250px" width="250px" role='button'>
                </label>
                <input type="file" accept=".jpg,.jpeg,.png" style="display:none" @change="onFileChange" id="file-input" >
            </div>
            <div class="col col-8 col-sm-6 offset-sm-1 col-md-5 offset-md-2 mt-5">
                <form-field id="'username'" :invalidMessage="errors.username" :validation="errors.username == ''" :label="$t('username')" v-model="state.user.username" />
                <form-field id="'email'" :invalidMessage="errors.email" :validation="errors.email == ''" :label="$t('email')" v-model="state.user.email" />
                <div class="vh-30">
                    <form-area id="bio" :characterLimit="characterLimit" :invalidMessage="$t('too_many_chars')" :validation="profile.profile_attributes.bio.length <= characterLimit" :label="$t('bio')" v-model="profile.profile_attributes.bio" />
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
import { getAvatarUrl } from '../../helper/serverRequests'
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
        const user = store.state.authUser
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
                current_password:""
            }
        })
        const profile = reactive({
            profile_attributes:{
                bio:""
            }
        }) 
        const passwordChangeModalRef = ref()
        const toastRef = ref()
        const toastHtmlContent = ref("")

        onMounted(() => {
        profile.profile_attributes.bio = ""
            M.CharacterCounter.init(document.querySelectorAll('.has-character-counter'));

            getAvatarUrl().then(response => {
                avatarUrl.value = response
                if (!avatarUrl.value){
                    avatarUrl.value = require('@/assets/images/user.png')
                }
            })

            state.user = user
            

            securedAxiosInstance.get(`/users/${user.id}/profile`, state)
                .then(response => {
                    profile.profile_attributes = response.data.message
                }), error => {console.log(error)}
              
        })
        function updatePassword(){
            //Since passwords are updated via a popup over the rest
            //of the profile, we need to ignore the rest of the fields

            /*if (!this.validateNewPassword())
                return*/

            let patchedUser = {}

            patchedUser.password = user.password
            patchedUser.password_confirmation = user.password_confirmation
            patchedUser.current_password = user.current_password

            securedAxiosInstance.put(`/users`, { user: patchedUser })
            .then(response => {
                if (response.data.status == 'error'){
                        
                    const current_errors = JSON.parse(response.data.message)
                    errors.password = current_errors.password[0]
                    errors.password_confirmation = current_errors.password_confirmation[0]
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

          user.profile_attributes = profile.profile_attributes
            /*if (!this.validateEmail(this.current_user.email)){
                this.errors.email = "Invalid email"

                return
            }*/
            if (updatedAvatar){
                const url = 'http://localhost:3000/rails/active_storage/direct_uploads'


                const upload = new DirectUpload(avatar, url,  {
                    directUploadWillCreateBlobWithXHR: (xhr) => {
                        xhr.setRequestHeader("Authorization", localStorage.csrf)
                    }})

                upload.create((error, blob) => {

                    if (error){
                        console.log(error)
                    }
                    else {
                        user.avatar = blob.signed_id
                        securedAxiosInstance.put(`/users`, { user: user })
                        .then(() => {
                            store.commit('setAuthUser', user)
                            router.push('/Home')
                        }), error => {console.log(error)}
                    }
                    
                })
            } else {
                securedAxiosInstance.put(`/users`, { user: user })
                .then(() => {
                    store.commit('setAuthUser', user)
                  router.push('/Home')
                }), error => {console.log(error)}
            }

        }

        function openPasswordModal(){
            passwordChangeModalRef.value.open()
        }

        return { toastRef, toastHtmlContent, passwordChangeModalRef, openPasswordModal, clearPasswordFields, updatePassword, characterLimit, state, profile, errors, avatarUrl, onFileChange, updateProfile }
    }
}
</script>

<style>

</style>