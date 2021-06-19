<template>
    <div>
        <div class="row">
            <div class="col col-12 col-sm-9">


            </div>
            <div class="col col-3" v-if="isMediumSizeOrMore">
                <collection-item></collection-item>
            </div>
        </div>
    </div>
</template>

<script>
import { onUnmounted, ref, onMounted } from 'vue'
import CollectionItem from "../components/CollectionItem.vue"
export default {
    components: {
        CollectionItem
    },
    setup(){
        const minWidthFriendsSidebar = 768
        const isMediumSizeOrMore = ref(false)
        let windowWidth = 0

        function handleResize() {
            windowWidth = window.innerWidth;

            isMediumSizeOrMore.value = windowWidth > minWidthFriendsSidebar
        }
        onMounted(() => {
            window.addEventListener('resize', handleResize);
            handleResize();
        })
        onUnmounted(() => {
            window.removeEventListener('resize', handleResize);
        })

        return { isMediumSizeOrMore }
    }
}
</script>

<style>

</style>