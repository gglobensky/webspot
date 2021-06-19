<template>
    <ul class="collection">
        <li class="collection-item avatar">
            <img v-if="imgUrl != ''" :src="imgUrl" alt="" :class="thumbnailShape">
            <i v-else-if="materialIconName != ''" :class="'material-icons ' + thumbnailShape">{{ materialIconName }}</i>
            <span class="title"><slot name="header"></slot></span>
            <p><slot name="body"></slot></p>
            <a href="#!" class="secondary-content"><slot name="secondary-content"></slot></a>
        </li>
    </ul>
</template>

<script>
export default {    
    name:"collection-item",    
    props:{
        imgUrl:{
            type: String,
            default: ""
        },
        materialIconName: {
            type: String,
            default: ""
        },
        thumbnailShape: {
            type: String,
            default: "circle"
        }
    },
    setup(){

    }
}
</script>

<style>

</style>