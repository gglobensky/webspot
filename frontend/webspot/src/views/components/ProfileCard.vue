<template>
    <div class="card-panel grey lighten-5 z-depth-1 d-flex" style="margin-bottom: 0px">
        <div class="col col-12">
            <div class="row" style="height: 15vh">
                <div class="col col-8 offset-2 d-flex justify-content-center h-100">
                    <slot name="image" />
                </div>
                <div class="col-2">
                    <a class="link" role="button" @click="chat()" ><i class="material-icons-outlined" >email</i></a>
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
import { watch, ref, onMounted } from 'vue'
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
        },
        user_id: {
            type: Number,
            required: true
        }
    },
    setup(props, { emit }){
        const hideIcon = ref("visibility")
        const addIcon = ref("add")

        onMounted(() => {
            let elems = document.querySelectorAll('.tooltipped');
            M.Tooltip.init(elems, {
                enterDelay: 1000
            });

            elems = document.querySelectorAll('.dropdown-trigger');
            M.Dropdown.init(elems, {
                constrainWidth: false
            });
        })

        function followPeople(){
            emit("followPeople")
        }
        function hidePeople(){
            emit("hidePeople")
        }
        function chat(){
            emit("chat")
        }
        
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