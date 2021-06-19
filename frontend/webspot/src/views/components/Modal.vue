<template>
  <div>
    <div :id="id" class="modal h-auto">
        <div class="modal-content">
            <h5 class="text-center nopadding"><slot name="header" /></h5>
            <slot class="pt-5" name="body" />
            
        </div>
        <div class="modal-footer">
            <slot name="footer" />
        </div>
    </div>
</div>
</template>

<script>
import M from 'materialize-css'
import { onMounted } from '@vue/runtime-core';

let instance = {}

export default {
    name: "modal",
    props:{
        id: {
            type: String,
            default: 'modal',
            required: true
        },
        width:{
            type: String,
            default: '30vw'
        },
        minWidth:{
            type: String,
            default: '300px'
        },
        opacity: {
            type: Number,
            default: 0.5
        },
        inDuration: {
            type: Number,
            default: 250
        },
        outDuration: {
            type: Number,
            default: 250
        },
        preventScrolling: {
            type: Boolean,
            default: true
        },
        dismissible: {
            type: Boolean,
            default: true
        },
        startingTop: {
            type: String,
            default: '4%'
        },
        endingTop: {
            type: String,
            default: '20%'
        },
        onOpenStart: Function,
        onOpenEnd: Function,
        onCloseStart: Function,
        onCloseEnd: Function
    },
    setup(props){
        onMounted(() => {
            var elems = document.querySelectorAll('.modal');
            M.Modal.init(elems, {
                opacity: props.opacity,
                inDuration: props.inDuration,
                outDuration: props.outDuration,
                preventScrolling: props.preventScrolling,
                dismissible: props.dismissible,
                startingTop: props.startingTop,
                endingTop: props.endingTop, 
                onOpenStart: props.onOpenStart,
                onOpenEnd: props.onOpenEnd,
                onCloseStart: props.onCloseStart,
                onCloseEnd: props.onCloseEnd
            } );

        })
        function open(){

            instance = M.Modal.getInstance(document.getElementById(props.id));

            instance.open()
            
        }
        function close(){

            instance = M.Modal.getInstance(document.getElementById(props.id));

            instance.close()
            
        }
        return { close, open }
    }
}
</script>

<style>

</style>