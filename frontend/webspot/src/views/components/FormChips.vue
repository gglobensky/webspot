<template>
    <div :value="returnValue" class="chips chips-autocomplete"></div>
</template>

<script>
import M from 'materialize-css'
import { onMounted, ref, watch } from 'vue'
export default {
    props: {
        initialData: {
            type: String,
            required: true
        },
        autocompleteData: {},
        placeholder: {
            type: String,
            default: "Placeholder"
        }
    },
    setup(props, {emit}){
        let chipsData = []
        let instances = []
        const returnValue = ref("")
        function init(){
            chipsData = []
            instances = []
            returnValue.value = props.initialData
            addTagListAsChips()
            setupInterestTagList()
        }
        onMounted(() => {
            init()
        })
        function addTagListAsChips(){
            const tags = returnValue.value.split(', ')

            if (tags[0] != ""){
                const len = tags.length
                for (let i = 0; i < len; i++){
                    chipsData.push({ tag: tags[i] })
                }
            }
            else{
                chipsData = []
            }
        }
        function parseChipsIntoString(){
            const len = instances[0].$chips.length;
            returnValue.value = ""

            const lastIndex = len - 1
                
            for (let i = 0; i < len; i++){
                returnValue.value += instances[0].$chips[i].firstChild.data

                if (i != lastIndex){
                    returnValue.value += ', '
                }
            }
            emit('update:modelValue', returnValue.value)
        }
        function setupInterestTagList(){
            const elems = document.querySelectorAll('.chips');
 
            instances = M.Chips.init(elems, {
                placeholder: props.placeholder,
                data: chipsData,
                onChipAdd: parseChipsIntoString,
                onChipDelete: parseChipsIntoString,
                autocompleteOptions: {
                    data: props.autocompleteData,
                    limit: Infinity,
                    minLength: 1
                }
                
            });

        }
        watch(() => props.autocompleteData, () => { 
            init()
        })
        watch(() => props.initialData, () => { 
            init()
        })

        return { returnValue }
    }
}
</script>

<style>

</style>