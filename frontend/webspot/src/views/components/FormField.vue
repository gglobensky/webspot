<template>
    <div class="input-field">
        <input :id="id" :value="modelValue" @input="$emit('update:modelValue', $event.target.value)" :type="inputType" :class="'form-control ' + validationClass" />
        <label :class="'unclickable form-label ' + activeClass" style="color: #d1d1d1; font-size:1.10rem; line-height: 19px;" for="typeText">{{label}}</label>
        <span v-if="hasShowPasswordButton" @click="toggle" class="field-icon toggle-password"><span class="material-icons">{{state}}</span></span>
        <span v-if="validMessage != '' || invalidMessage != ''" class="helper-text" :data-error="invalidMessage" :data-success="validMessage"></span>
    </div>
</template>

<script>
import { onBeforeUpdate, ref, watch} from 'vue'

export default {
    name: 'form-field',
    props: {
        id: String,
        modelValue: String,
        label: String,
        hasShowPasswordButton: {
            type: Boolean, 
            default: false
        },
        validation: {
            type: Boolean, 
            default: false
        },
        validMessage: String,
        invalidMessage: String
    },
    emits: ['update:modelValue'],
    methods: {
        changePageTitle(title) {
            this.$emit('update:modelValue', title) // previously was `this.$emit('input', title)`
        }
    },
    setup(props){
        const state = ref("visibility_off")
        const inputType = ref("password")
        const validationClass = ref("")
        const activeClass = ref("")

        if (props.hasShowPasswordButton == false){
            inputType.value = "text"
        }
        
        onBeforeUpdate(() => {
            if (props.modelValue != "")
                activeClass.value = "active"
            else
                activeClass.value = "inactive"
        })
        function toggle(){
            if (inputType.value == "password"){
                inputType.value = "text"
                state.value = "visibility"
            }
            else{
                inputType.value = "password"
                state.value = "visibility_off"
            }
        }
        function switchValidationClass(){
            if(props.validation) {
                validationClass.value = "valid"
            } else {
                validationClass.value = "invalid"
            }
        }
//If the field just has been validated, switch validation state if needed
        watch(() => props.validation, () => { 
            switchValidationClass()
        })

        return { inputType, toggle, state, validationClass, activeClass}
    }
}
</script>

<style>

</style>