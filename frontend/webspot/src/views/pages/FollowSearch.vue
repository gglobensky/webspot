<template>
<div>
    <Toast ref="toastRef" :htmlContent="toastHtmlContent" />
    <div class="row">
    <div class="col col-sm-5 col-md-4 col-lg-3 fixed-top hidden-on-xs mt-4 z-2000">
        <form @submit.prevent="searchPeople">
            <div class="card-panel grey lighten-5 z-depth-1" style="height: 87vh; position: relative; top: 62px;">
                <div class="scrollable" style="height: 90%">
                    <div v-if="searchData.searchBy == 'username' || searchData.searchBy == 'bio'" class="pb-1">
                        <form-field id="'username'" v-model="searchData.searchTerms" :label="$t('search')" />
                    </div>
                    <div v-else-if="searchData.searchBy == 'talents'" class="pb-4" >
                        <form-chips v-model="searchData.searchTerms" :unique_id="'talents'" :placeholder="$t('search')" :initialData="searchData.searchTerms" :autocompleteData="autocompleteTalentTagData.value" />
                    </div>
                    <div v-else-if="searchData.searchBy == 'interests'" class="pb-4">
                        <form-chips v-model="searchData.searchTerms" :unique_id="'interests'" :placeholder="$t('search')" :initialData="searchData.searchTerms" :autocompleteData="autocompleteInterestTagData.value" />
                    </div>
                    
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
        <div class="col col-sm-5 col-md-4 col-lg-3 hidden-on-xs">
            <!-- Spacer for search sidebar since it is fixed, it does not takes space -->
        </div>
        <div class="col col-12 col-sm-7 col-md-8 col-lg-9 nopadding">     
            
            <div v-for="(n, i) in displayedPeopleData.length" :key="i" class="col col-12 col-sm-12 col-md-6 col-lg-4 px-2 pe-sm-3">
                <profile-card :user_id="displayedPeopleData[i].id" @chat="chatButtonCallback(displayedPeopleData[i].id)" :showHideIcon="hideIcon" :showAddIcon="addIcon" @hidePeople="hideButtonCallback(displayedPeopleData[i].id, displayedPeopleData[i].username)" @followPeople="addButtonCallback(displayedPeopleData[i].id, displayedPeopleData[i].username)" >
                    <template #image>
                        <img v-if="displayedPeopleData[i].url" :src="`${API_URL}${displayedPeopleData[i].url}`" :alt="`${displayedPeopleData[i].username}'s profile picture`" class="circle " style="max-height:128px; max-width: 128px" />
                        <img v-else :src="require('@/assets/images/user.png')" :alt="`${displayedPeopleData[i].username}'s profile picture`" class="circle " style="max-height:128px; max-width: 128px" />
                    </template>
                    <template #header>
                        {{displayedPeopleData[i].username}}
                    </template>
                    <template #body>
                        <div v-show="searchData.searchBy == 'interests' || searchData.searchBy == 'talents'">
                            <div class="col col-12 mt-2 d-flex justify-content-start" style="height: 8vh;">
                                <a class="text-center text-overflow-ellipsis-2l black-text tooltipped" data-position="bottom" :data-tooltip="displayedPeopleData[i].interest_tag_list != null ? displayedPeopleData[i].interest_tag_list : $t('none')">
                                   {{$t('interests') + ':'}} {{displayedPeopleData[i].interest_tag_list != null ? displayedPeopleData[i].interest_tag_list : $t('none')}}
                                </a>
                            </div>  
                            <div class="col col-12 d-flex justify-content-start" style="height: 8vh;">
                                <a class="text-center text-overflow-ellipsis-2l black-text tooltipped" data-position="bottom" :data-tooltip="displayedPeopleData[i].talent_tag_list != null ? displayedPeopleData[i].talent_tag_list : $t('none')">
                                    {{$t('talents') + ':'}} {{displayedPeopleData[i].talent_tag_list != null ? displayedPeopleData[i].talent_tag_list : $t('none')}}
                                </a>
                            </div>    
                        </div>
                        <div v-show="searchData.searchBy == 'bio' || searchData.searchBy == 'username'" >
                            <div class="col col-12 mt-2 d-flex justify-content-center" style="height: 16vh;">
                                <a class="text-center text-overflow-ellipsis-5l black-text tooltipped" data-position="bottom" :data-tooltip="displayedPeopleData[i].bio">
                                    {{displayedPeopleData[i].bio}}
                                </a>
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
import router from '../../router'
import { securedAxiosInstance } from '../../backend/axios'
import { getAutoCompleteInterestTags, getAutoCompleteTalentTags } from '../../helper/serverRequests'
import FormChips from '../components/FormChips.vue'
import { API_URL } from '../../helper/serverRequests'
import ProfileCard from '../components/ProfileCard.vue'
import FormField from '../components/FormField.vue'
import Toast from '../components/Toast.vue'
import { onBeforeUnmount, onMounted, ref, reactive, } from 'vue'
import M from 'materialize-css'
import { useI18n } from 'vue-i18n'
export default {
    name:'follow-search',
    components:{
        ProfileCard,
        FormField,
        Toast,
        FormChips
    },
    setup(){
        const autocompleteInterestTagData = reactive({})
        const autocompleteTalentTagData = reactive({})

        const hideIcon = ref(true);
        const addIcon = ref(true);

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
            "interests",
            "talents"
        ]
        const searchData = reactive({
            searchTerms: "",
            searchFor: searchForTerms[0],
            searchBy: searchByTerms[0]
        })
        const displayedPeopleData = ref({
            user: {
                username:""
            },
            url: "",
            profile: {}
        })
        const toastRef = ref()
        const toastHtmlContent = ref("")

        function followPeople(person_id, person_username){
            securedAxiosInstance.post('/following/follow', { followed_id: person_id })
                .then(() => {
                    removeFromDisplayedPeopleData(person_id)
                    toastHtmlContent.value = t("followed_user", { user: person_username})
                    toastRef.value.show()
                })
                ,(error => console.log(error))
        }
        function unfollowPeople(person_id, person_username){
            securedAxiosInstance.post('/following/unfollow', { followed_id: person_id })
                .then(() => {
                    removeFromDisplayedPeopleData(person_id)
                    toastHtmlContent.value = t("unfollowed_user", { user: person_username})
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
        function unhidePeople(person_id, person_username){
            securedAxiosInstance.post('/following/unhide', { hidden_person_id: person_id })
                .then(() => {
                    removeFromDisplayedPeopleData(person_id)
                    toastHtmlContent.value = t("unhidden_user", { user: person_username})
                    toastRef.value.show()
                })
                ,(error => console.log(error))
        }
        function hideButtonCallback(person_id, person_username){
            if (hideIcon.value == false)
                hidePeople(person_id, person_username)
            else
                unhidePeople(person_id, person_username)
        }
        function addButtonCallback(person_id, person_username){
            if (addIcon.value == false)
                unfollowPeople(person_id, person_username)
            else
                followPeople(person_id, person_username)
        }
        function removeFromDisplayedPeopleData(id){

            for (var i = displayedPeopleData.value.length - 1; i >= 0; --i) {

                if (displayedPeopleData.value[i].id == id) {
                    displayedPeopleData.value.splice(i, 1);
                    return
                }
            }
        }
        function searchPeople(){

            if (searchData.searchFor.startsWith("hidden")){
                hideIcon.value = true;
            }
            else{
                hideIcon.value = false;
            }

            if (searchData.searchFor.includes("followed")){
                addIcon.value = false;
            }
            else{
                addIcon.value = true;
            }

            securedAxiosInstance.post('/following/search', { searchBy: searchData.searchBy, searchFor: searchData.searchFor, searchTerms: searchData.searchTerms? searchData.searchTerms.toLowerCase() : "" })
                .then(response => {
                    displayedPeopleData.value = response.data
                })
                ,(error => console.log(error))
        }
        function chatButtonCallback(user_id){
            securedAxiosInstance.post('/conversation/create', { user_id: user_id })
                .then((response) => {
                    console.log(response)
                    router.push({ path: 'chat', query: { t: response.data.conversation } })
                })
                ,(error => console.log(error))

        }
        onMounted(() => {
            window.addEventListener("scroll", onScroll)
            var elems = document.querySelectorAll('select');
            M.FormSelect.init(elems);

            getAutoCompleteInterestTags().then(response => {
                autocompleteInterestTagData.value = response; 

                }), error => console.log(error)

            getAutoCompleteTalentTags().then(response => {
                autocompleteTalentTagData.value = response; 

                }), error => console.log(error)

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

        return { chatButtonCallback, addIcon, hideIcon, autocompleteInterestTagData, autocompleteTalentTagData, API_URL, toastHtmlContent, toastRef, displayedPeopleData, searchByTerms, searchForTerms, addButtonCallback, hideButtonCallback, searchPeople, searchData }
    }

}
</script>

<style>

</style>