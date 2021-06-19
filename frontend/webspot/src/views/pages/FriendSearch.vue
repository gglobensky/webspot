<template>
<div>
    <div class="row">
    <div class="col col-sm-5 col-md-4 col-lg-3 fixed-top hidden-on-xs mt-4">
        <form @submit.prevent="searchFriends">
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
            
            <div v-for="(n, i) in friendsData.length" :key="i" class="col col-12 col-sm-12 col-md-6 col-lg-4 vh-50 mb-1 pe-3">
                <friend-card @addFriend="addFriend()" imageSrc="https://randomuser.me/api/portraits/women/28.jpg">
                    <template #image>
                        <img v-if="friendsData[i].url" :src="`http://localhost:3000/${friendsData[i].url}`" :alt="`${friendsData[i].user.username}'s profile picture`" class="circle " style="max-height:128px; max-width: 128px" />
                        <img v-else :src="require('@/assets/images/user.png')" :alt="`${friendsData[i].user.username}'s profile picture`" class="circle " style="max-height:128px; max-width: 128px" />
                    </template>
                    <template #header>
                        {{friendsData[i].user.email}}
                    </template>
                    <template #body>
                        {{friendsData[i].profile.bio}}
                    </template>
                </friend-card>
            </div>
        </div>
    </div>
</div>
</template>

<script>
import { securedAxiosInstance } from '../../backend/axios'
import FriendCard from '../components/FriendCard.vue'
import FormField from '../components/FormField.vue'
import { onBeforeUnmount, onMounted, ref, reactive } from 'vue'
import M from 'materialize-css'
export default {
    components:{
        FriendCard,
        FormField
    },
    setup(){
        const searchForTerms = [
            "in_group",
            "new_friends",
            "hidden_friends",
            "current_friends"
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
        const friendsData = ref({
            user: {
                username:""
            },
            url: "",
            profile: {}
        })
        function addFriend(){

            for (let i = 0; i < friendsData.value.length; i++){
                console.log(JSON.stringify(friendsData.value[i].user))
            }
        }
        function hideFriend(){

        }
        function searchFriends(){
            //0 is the placeholder, a disabled option
            if (searchData.searchFor == searchForTerms[0])
                searchData.searchFor = searchForTerms[1]

            if (searchData.searchBy == searchByTerms[0])
                searchData.searchBy = searchByTerms[1]
                
            securedAxiosInstance.post('/friendship/search', searchData)
                .then(response => {
                    friendsData.value = response.data
                })
                ,(error => console.log(error))
        }
        onMounted(() => {
            window.addEventListener("scroll", onScroll)
            var elems = document.querySelectorAll('select');
            M.FormSelect.init(elems);

            searchFriends()
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

        return { friendsData, searchByTerms, searchForTerms, addFriend, hideFriend, searchFriends, searchData }
    }

}
</script>

<style>

</style>