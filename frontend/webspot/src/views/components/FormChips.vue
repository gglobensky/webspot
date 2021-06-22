<template>
    <div class="chips chips-autocomplete"></div>
</template>

<script>
export default {
    setup(){
        let autocompleteData = {}
        let chipsData = []
        let instances = []

        onMounted(() => {
            function getInterestTags(){
                securedAxiosInstance.get('/tags/interests')
                .then(response => {
                    const tags = response.data.message
                    
                    const len = tags.length
                    for (let i = 0; i < len; i++){
                        autocompleteData[tags[i].name] = null
                    }

                }), error => {
                    console.log(error)
                }
            }
        })

    }
}
</script>

<style>

</style>