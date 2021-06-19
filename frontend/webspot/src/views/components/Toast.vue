<template>
  <div></div>
</template>

<script>
import M from 'materialize-css'
import { onActivated } from '@vue/runtime-core'
export default {
    name: "toast",
    props: {
        htmlContent:String,
        displayLength:{
            type: Number,
            default: 4000
        },
        inDuration: {
            type: Number,
            default: 300
        },
        outDuration: {
            type: Number,
            default: 375
        },
        classes: {
            type: String,
            default: ""
        },
        activationPercent: {
            type: Number,
            default: 0.8
        },
        completeCallback: Function
    },
    setup(props){
        let toastInstance = {}
        onActivated(() => {
            const toastElement = document.querySelector('.toast');
            toastInstance = M.Toast.getInstance(toastElement);
        })
        function show(){
            //Delay is given because if props are set in parent
            //just before show action, they are not updated 
            //quickly enough for the toast to show changes
            setTimeout(() => {
                M.toast({html: props.htmlContent, 
                displayLength: props.displayLength, 
                inDuration: props.inDuration, 
                outDuration: props.outDuration, 
                classes: props.classes, 
                completeCallback: 
                props.completeCallback, 
                activationPercent: props.activationPercent})
            }, 100)
        }
        function dismiss(){
            toastInstance.dismiss()
        }
        function timeRemaining(){
            return toastInstance.timeRemaining;
        }
        return { show, timeRemaining, dismiss }
    }
}
</script>

<style>

</style>