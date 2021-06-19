<template>
  <div class="card-panel grey lighten-5 z-depth-1 h-100">
    <div class="col col-12">
        <div class="row">
            <div class="col col-12 d-flex justify-content-center" style="height: 128px;">
                <slot name="image" />
            </div>
        </div>
        <div class="row nopadding">
            <div class="col col-12 d-flex justify-content-center">
                <h1 class="h5">
                    <slot name="header" />
                </h1>
            </div>

                <div class="col col-12 mt-3 d-flex justify-content-center" style="height: 16vh;">
                    <p class="text-center text-overflow-ellipsis">
                        <slot name="body" />
                    </p>
                </div>

            <div class="col col-12 d-flex justify-content-end nopadding">
                <a @click="hideFriend()" class="btn-floating waves-effect waves-light me-3 mb-3 default-pale"><i class="material-icons">remove</i></a>
                <a @click="addFriend()" class="btn-floating waves-effect waves-light default-dark"><i class="material-icons">add</i></a>
            </div>
        </div>
    </div>
</div>
</template>

<script>

export default {
    name: 'friend-card',
    setup(_, { emit }){
        function addFriend(){
            emit("addFriend")
        }
        function hideFriend(){
            emit("hideFriend")
        }

        return { hideFriend, addFriend }
    }

}
</script>

<style>

</style>