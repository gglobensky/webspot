<template>
<div>
    <Toast ref="toastRef" :htmlContent="toastHtmlContent" />
    <div class="row">
    <div class="col col-sm-5 col-md-4 col-lg-3 fixed-top hidden-on-xs mt-4 z-2000">
        <form @submit.prevent="searchPeople">
            <div class="card-panel grey lighten-5 z-depth-1" style="height: 87vh; position: relative; top: 62px;">
                <div class="scrollable" style="height: 90%">
                <form-field id="'username'" v-model="searchData.searchTerms" label="Search"/>
                <h6>{{$t('in_group')}}</h6>
                <div class="input-field mb-5">
                    <div style="height: 15vh">
                        <label v-for="group in searchForTerms" :key="group" :value="group" class="col col-12">
                            <input name="group" type="radio" v-model="searchData.searchFor" :value="group">
                            <span>{{$t(group)}}</span>
                        </label>
                    </div>
                </div>
                <div class="mt-5">
                <h6>{{$t('by_term')}}</h6>
                </div>
                <div class="input-field mb-5">
                    <p>
                        <label v-for="term in searchByTerms" :key="term" :value="term" class="col col-12">
                            <input name="term" type="radio" v-model="searchData.searchBy" :value="term">
                            <span>{{$t(term)}}</span>
                        </label>
                    </p>
                </div>
                <div class="input-field">
                    <button class="waves-effect waves-light btn right mt-5">{{$t('search')}}</button>
                </div>
                </div>
            </div>
        </form>
    </div>
    </div>
    <div class="row mt-3">
        <div class="col col-0 col-sm-5 col-md-4 col-lg-3 ">
            <!-- Spacer for search sidebar since it is fixed, it does not takes space -->
        </div>
        <div class="col col-12 col-sm-7 col-md-8 col-lg-9 nopadding">     
            
            <div v-for="(n, i) in displayedPeopleData.length" :key="i" class="col col-12 col-sm-12 col-md-6 col-lg-4 pe-3">
                <profile-card @hidePeople="hidePeople(displayedPeopleData[i].id, displayedPeopleData[i].username)" @addPeople="addPeople(displayedPeopleData[i].id, displayedPeopleData[i].username)" >
                    <template #image>
                        <img v-if="displayedPeopleData[i].url" :src="`${API_URL}${displayedPeopleData[i].url}`" :alt="`${displayedPeopleData[i].username}'s profile picture`" class="circle " style="max-height:128px; max-width: 128px" />
                        <img v-else :src="require('@/assets/images/user.png')" :alt="`${displayedPeopleData[i].username}'s profile picture`" class="circle " style="max-height:128px; max-width: 128px" />
                    </template>
                    <template #header>
                        {{displayedPeopleData[i].username}}
                    </template>
                    <template #body>
                        <div v-if="searchData.searchBy != 'interests'">
                            <div class="col col-12 mt-2 d-flex justify-content-center" style="height: 16vh;">
                                <p class="text-center text-overflow-ellipsis-5l">
                                    {{displayedPeopleData[i].bio}}
                                </p>
                            </div>
                        </div>
                        <div v-else>
                            <div class="col col-12 mt-2 d-flex justify-content-start" style="height: 8vh;">
                                <p class="text-center text-overflow-ellipsis-2l">
                                    Interests: {{displayedPeopleData[i].interest_tag_list}}
                                </p>
                            </div>               
                            <div class="col col-12 d-flex justify-content-start" style="height: 8vh;">
                                <p class="text-center text-overflow-ellipsis-2l">
                                    Talents: placeholder placeholder placeholder placeholder placeholder placeholder placeholder placeholder
                                </p>
                            </div>    
                        </div>        
                    </template>
                </profile-card>
            </div>
        </div>
    </div>
</div>
</template>

<script>
import { securedAxiosInstance } from '../../backend/axios'
import { API_URL } from '../../helper/serverRequests'
import ProfileCard from '../components/ProfileCard.vue'
import FormField from '../components/FormField.vue'
import Toast from '../components/Toast.vue'
import { onBeforeUnmount, onMounted, ref, reactive } from 'vue'
import M from 'materialize-css'
import { useI18n } from 'vue-i18n'
export default {
    name:'follow-search',
    components:{
        ProfileCard,
        FormField,
        Toast
    },
    setup(){
        const { t } = useI18n()
        const searchForTerms = [
            "new_people",
            "hidden_people",
            "hidden_followed",
            "followed"
        ]
        const searchByTerms = [
            "username",
            "bio",
            "interests"
        ]
        const searchData = reactive({
            searchTerms: "",
            searchFor: searchForTerms[0],
            searchBy: searchByTerms[0]
        })
        //reactive?
        const displayedPeopleData = ref({
            user: {
                username:""
            },
            url: "",
            profile: {}
        })
        const toastRef = ref()
        const toastHtmlContent = ref("")
        function addPeople(person_id, person_username){
            securedAxiosInstance.post('/following/create', { followed_id: person_id })
                .then(() => {
                    removeFromDisplayedPeopleData(person_id)
                    toastHtmlContent.value = t("followed_user", { user: person_username})
                    toastRef.value.show()
                })
                ,(error => console.log(error))
        }
        function hidePeople(person_id, person_username){
            securedAxiosInstance.post('/following/hide', { hidden_person_id: person_id })
                .then(() => {
                    removeFromDisplayedPeopleData(person_id)
                    toastHtmlContent.value = t("hidden_user", { user: person_username})
                    toastRef.value.show()
                })
                ,(error => console.log(error))
        }
        function removeFromDisplayedPeopleData(id){

            for (var i = displayedPeopleData.value.length - 1; i >= 0; --i) {
                console.log(JSON.stringify(displayedPeopleData.value))
                if (displayedPeopleData.value[i].id == id) {
                    displayedPeopleData.value.splice(i, 1);
                    return
                }
            }
        }
        function searchPeople(){
            //0 is the placeholder, a disabled option
            securedAxiosInstance.post('/following/search', { searchBy: searchData.searchBy, searchFor: searchData.searchFor, searchTerms: searchData.searchTerms? searchData.searchTerms.toLowerCase() : "" })
                .then(response => {
                    displayedPeopleData.value = response.data
                })
                ,(error => console.log(error))
        }
        onMounted(() => {
            window.addEventListener("scroll", onScroll)
            var elems = document.querySelectorAll('select');
            M.FormSelect.init(elems);

            searchPeople()

        })
        onBeforeUnmount(() => {
            window.removeEventListener("scroll", onScroll)
        })
        function onScroll(e) {

            manageSearchBarPosition(e)

        }
        function manageSearchBarPosition(e){
            console.log("Dont forget infinite scroll " + e)
        }

        return { API_URL, toastHtmlContent, toastRef, displayedPeopleData, searchByTerms, searchForTerms, addPeople, hidePeople, searchPeople, searchData }
    }

}
</script>

<style>

</style>