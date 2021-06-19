<template>
<div>
    <div class="row">
    <div class="col col-sm-5 col-md-4 col-lg-3 fixed-top hidden-on-xs mt-4">
        <form @submit.prevent="searchPeople">
            <div class="card-panel grey lighten-5 z-depth-1" style="height: 87vh; position: relative; top: 62px;">
                <form-field id="'username'" v-model="searchData.searchTerms" :invalidMessage="'shitdemarde'" :validation="'shitdemarde' == ''" label="Search" />
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
            
            <div v-for="(n, i) in peopleData.length" :key="i" class="col col-12 col-sm-12 col-md-6 col-lg-4 vh-50 mb-1 pe-3">
                <profile-card @addPeople="addPeople(peopleData[i])" imageSrc="https://randomuser.me/api/portraits/women/28.jpg">
                    <template #image>
                        <img v-if="peopleData[i].url" :src="`http://localhost:3000/${peopleData[i].url}`" :alt="`${peopleData[i].user.username}'s profile picture`" class="circle " style="max-height:128px; max-width: 128px" />
                        <img v-else :src="require('@/assets/images/user.png')" :alt="`${peopleData[i].user.username}'s profile picture`" class="circle " style="max-height:128px; max-width: 128px" />
                    </template>
                    <template #header>
                        {{peopleData[i].user.email}}
                    </template>
                    <template #body>
                        {{peopleData[i].profile.bio}}
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
            "username"
        ]
        const searchData = reactive({
            searchTerms: "",
            searchFor: searchForTerms[0],
            searchBy: searchByTerms[0]
        })
        const peopleData = ref({
            user: {
                username:""
            },
            url: "",
            profile: {}
        })
        function addPeople(person){
            console.log("id " + JSON.stringify(person.user.id))
            securedAxiosInstance.post('/following/create', { followed_id: person.user.id })
                .then(() => {
                    console.log("okay")
                })
                ,(error => console.log(error))
        }
        function hidePeople(){

        }
        function searchPeople(){
            //0 is the placeholder, a disabled option
            if (searchData.searchFor == searchForTerms[0])
                searchData.searchFor = searchForTerms[1]

            if (searchData.searchBy == searchByTerms[0])
                searchData.searchBy = searchByTerms[1]
                
            securedAxiosInstance.post('/following/search', searchData)
                .then(response => {
                    peopleData.value = response.data
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

        return { peopleData, searchByTerms, searchForTerms, addPeople, hidePeople, searchPeople, searchData }
    }

}
</script>

<style>

</style>