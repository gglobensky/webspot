<template>
    <div class="card-panel grey lighten-5 z-depth-1 d-flex" style="margin-bottom: 0px">
        <div class="col col-12">
            <div class="row" style="height: 15vh">
                <div class="col col-12 d-flex justify-content-center h-100">
                    <slot name="image" />
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
                    <a @click="hidePeople()" class="btn-floating waves-effect waves-light me-3 mt-3 default-pale"><i class="material-icons">remove</i></a>
                    <a @click="addPeople()" class="btn-floating waves-effect waves-light mt-3 default-dark"><i class="material-icons">add</i></a>
                </div>
            </div>
        </div>
    </div>
</template>

<script>

export default {
    name: 'profile-card',
    setup(_, { emit }){
        function addPeople(){
            emit("addPeople")
        }
        function hidePeople(){
            emit("hidePeople")
        }

        return { hidePeople, addPeople }
    }

}
</script>

<style>

</style>