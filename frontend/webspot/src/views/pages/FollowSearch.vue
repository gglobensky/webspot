<template>
<div>
    <div class="row">
    <div class="col col-sm-5 col-md-4 col-lg-3 fixed-top hidden-on-xs mt-4 z-2000">
        <form @submit.prevent="searchPeople">
            <div class="card-panel grey lighten-5 z-depth-1" style="height: 87vh; position: relative; top: 62px;">
                <form-field id="'username'" v-model="searchData.searchTerms" label="Search" />
                <div class="input-field mb-5">
                    <select v-model="searchData.searchFor">
                        <option :disabled="group == searchForTerms[0]" :selected="group == searchForTerms[0]" v-for="group in searchForTerms" :key="group" :value="group">{{$t(group)}}</option>
                    </select>
                </div>
                <div class="input-field mb-5">
                    <select v-model="searchData.searchBy">
                        <option :disabled="term == searchByTerms[0]" :selected="term == searchByTerms[0]" v-for="term in searchByTerms" :key="term" :value="term">{{$t(term)}}</option>
                    </select>
                </div>
                <div class="input-field">
                    <button class="waves-effect waves-light btn right">{{$t('search')}}</button>
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
            
            <div v-for="(n, i) in displayedPeopleData.length" :key="i" class="col col-12 col-sm-12 col-md-6 col-lg-4 vh-50 mb-1 pe-3">
                <profile-card @hidePeople="hidePeople(displayedPeopleData[i].id)" @addPeople="addPeople(displayedPeopleData[i].id)" imageSrc="https://randomuser.me/api/portraits/women/28.jpg">
                    <template #image>
                        <img v-if="displayedPeopleData[i].url" :src="`http://localhost:3000/${displayedPeopleData[i].url}`" :alt="`${displayedPeopleData[i].username}'s profile picture`" class="circle " style="max-height:128px; max-width: 128px" />
                        <img v-else :src="require('@/assets/images/user.png')" :alt="`${displayedPeopleData[i].username}'s profile picture`" class="circle " style="max-height:128px; max-width: 128px" />
                    </template>
                    <template #header>
                        {{displayedPeopleData[i].username}}
                    </template>
                    <template #body>
                        {{displayedPeopleData[i].bio}}
                    </template>
                </profile-card>
            </div>
        </div>
    </div>
</div>
</template>

<script>
import { securedAxiosInstance } from '../../backend/axios'
import ProfileCard from '../components/ProfileCard.vue'
import FormField from '../components/FormField.vue'
import { onBeforeUnmount, onMounted, ref, reactive } from 'vue'
import M from 'materialize-css'
export default {
    name:'follow-search',
    components:{
        ProfileCard,
        FormField
    },
    setup(){
        const searchForTerms = [
            "in_group",
            "new_people",
            "hidden_people",
            "hidden_followed",
            "followed"
        ]
        const searchByTerms = [
            "by_term",
            "username",
            "bio"
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
        function addPeople(person_id){
            securedAxiosInstance.post('/following/create', { followed_id: person_id })
                .then(() => {
                    removeFromDisplayedPeopleData(person_id)
                })
                ,(error => console.log(error))
        }
        function hidePeople(person_id){
            securedAxiosInstance.post('/following/hide', { hidden_person_id: person_id })
                .then(() => {
                    removeFromDisplayedPeopleData(person_id)
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
            if (searchData.searchFor == searchForTerms[0])
                searchData.searchFor = searchForTerms[1]

            if (searchData.searchBy == searchByTerms[0])
                searchData.searchBy = searchByTerms[1]

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

        return { displayedPeopleData, searchByTerms, searchForTerms, addPeople, hidePeople, searchPeople, searchData }
    }

}
</script>

<style>

</style>