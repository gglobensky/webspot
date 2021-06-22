<template>
    <div class="input-field">
        <textarea :id="id" v-on:change="check()" :value="modelValue" @input="$emit('update:modelValue', $event.target.value)" :class="'materialize-textarea ' + hasCharacterCounterClass + validationClass" :data-length="characterLimit"></textarea>
        <label :class="activeClass" :for="id">{{label}}</label>
        <span class="helper-text" :data-error="invalidMessage" :data-success="validMessage"></span>

    </div> 
</template>

<script>
import { onBeforeUpdate, ref, watch} from 'vue'
import M from 'materialize-css'
import jQuery from "jquery";
export default {
    name: 'form-area',
    props: {
        id: {
            type: String,
            default: 'textarea'
        },
        modelValue: String,
        label: String,
        validation: Boolean,
        validMessage: String,
        invalidMessage: String,
        characterLimit: Number
    },
    emits: ['update:modelValue'],
    methods: {
        //useless?
        changePageTitle(title) {
            this.$emit('update:modelValue', title) // previously was `this.$emit('input', title)`
        }
    },
    setup(props){
        const $ = jQuery;
        window.$ = $;
        const validationClass = ref("")
        const activeClass = ref("")
        const hasCharacterCounterClass = ref("")

        if (props.characterLimit > 0)
            hasCharacterCounterClass.value = "has-character-counter "

        onBeforeUpdate(() => {
            if (props.modelValue != ""){
                $(`#${props.id}`).val(props.modelValue);
                M.textareaAutoResize($(`#${props.id}`));
                activeClass.value = "active"
            }

        })
        function clearValidationClass(){
            if (props.modelValue == ""){
                validationClass.value = ""
                return true
            }
            return false
        }
        function switchValidationClass(){
            
            if(props.validation) {
                validationClass.value = "valid"
            } else {
                validationClass.value = "invalid"
            }
        }
        function check() {

            if (clearValidationClass())
                return

            switchValidationClass()

        }

//If the field just has been validated, switch validation state if needed
        watch(() => props.validation, () => { 
            switchValidationClass()
        })


        return { validationClass, activeClass, check, hasCharacterCounterClass }
    }
}
</script>

<style>

</style>