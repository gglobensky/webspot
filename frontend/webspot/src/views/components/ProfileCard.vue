<template>
    <div class="card-panel grey lighten-5 z-depth-1 d-flex" style="margin-bottom: 0px">
        <div class="col col-12">
            <div class="row" style="height: 15vh">
                <div class="col col-8 offset-2 d-flex justify-content-center h-100">
                    <slot name="image" />
                </div>
                <div class="col-2">
                    <a href='#' data-target='dropdown1' class="profile-card dropdown-trigger waves-effect waves-light me-3"><i class="material-icons" >more_horiz</i></a>
                    <ul id='dropdown1' class='dropdown-content'>
                        <li>
                        <a class="link" @click="chat()">
                            <span class="material-icons-outlined">mode_comment</span>
                            Chat
                        </a>
                        </li>
                        <li><a href="#!"><span class="material-icons-outlined">add_comment</span>Group Chat</a></li>
                    </ul>
                </div>
            </div>
            <div class="row nopadding">
                <div class="col col-12 d-flex justify-content-center">
                    <h1 class="h5">
                        <slot name="header" />
                    </h1>
                </div>
                
                <slot name="body" />

                <div class="col col-12 d-flex justify-content-end nopadding">
                    <a @click="hidePeople()" class="btn-floating waves-effect waves-light me-3 mt-3 default-pale"><i class="material-icons-outlined" >{{hideIcon}}</i></a>
                    <a @click="followPeople()" class="btn-floating waves-effect waves-light mt-3 default-dark"><i class="material-icons">{{addIcon}}</i></a>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { watch, ref } from 'vue'
import M from 'materialize-css'
export default {
    name: 'profile-card',
    props: {
        showHideIcon: {
            type: Boolean,
            default: true
        },
        showAddIcon: {
            type: Boolean,
            default: true
        }
    },
    setup(props, { emit }){
        const hideIcon = ref("visibility")
        const addIcon = ref("add")
        
        function followPeople(){
            emit("followPeople")
        }
        function hidePeople(){
            emit("hidePeople")
        }
        function chat(){
            emit("chat")
        }


        let elems = document.querySelectorAll('.tooltipped');
        M.Tooltip.init(elems, {
            enterDelay: 1000
        });

        elems = document.querySelectorAll('.dropdown-trigger');
        M.Dropdown.init(elems, {
            constrainWidth: false
        });

        toggleHideIconValue()
        toggleAddIconValue()

        function toggleHideIconValue(){
            if (props.showHideIcon)
                hideIcon.value = "visibility"
            else
                hideIcon.value = "visibility_off"
        }
        function toggleAddIconValue(){
            if (props.showAddIcon)
                addIcon.value = "add"
            else
                addIcon.value = "remove"

        }
        watch(() => props.showHideIcon, () => { 
            toggleHideIconValue()
        })

        watch(() => props.showAddIcon, () => { 
            toggleAddIconValue()
        })
        
        return { chat, addIcon, hideIcon, hidePeople, followPeople }
    }

}
</script>

<style>

</style>