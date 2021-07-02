<template>
  <div>
      <div class="row" style="height: 80vh; overflow: auto">
          <div class="col col-8">
              <div class="col col-12" v-for="message in messages" :key="message">
                  <div :style="currentUsername == message.username? 'float:right;': 'float:left;'">
                    <div :class="currentUsername == message.username? 'chat-box default-pale white-text' : 'chat-box grey lighten-2'">
                        {{message.content}}
                    </div>
                  <p style="font-size:0.6rem">{{message.username}} at {{moment(message.updated_at).format('MMMM Do YYYY, h:mm a')}}</p>
                  </div>
                  
              </div>
              <div class="fixed-bottom">
                <div class="col col-8 d-flex align-items-center">
                    <div class="col col-11 px-5">
                        <form-area v-model="currentMessage" placeholder="Type here" />
                    </div>
                    <div class="col col-1">
                        <button @click="sendMessage" class="btn waves-effect waves-light">Send</button>
                    </div>
                </div>
              </div>
          </div>
          <div class="col col-4">
              Followed list
          </div>
      </div>
  </div>
</template>

<script>
import moment from 'moment'
import store from '../../store'
import { useRoute } from 'vue-router';
import FormArea from '../components/FormArea.vue'
import { ref, onMounted, getCurrentInstance } from 'vue'
import { securedAxiosInstance } from '../../backend/axios'
export default {
    components: {
        FormArea
    },
    channels: {
        ConversationChannel: {
            connected() {
                console.log("connected")
            },
            rejected() {
                console.log("rejected")
            },
            received(data) {
                this.receivedMessage(data)
            },
            disconnected() {}
        }
    },
    setup(){
        const currentMessage = ref('')
        const messages = ref([{}])
        const currentUsername = store.state.authUser.username
        let conversation_id = 0

        onMounted(() => {
        const route = useRoute();
        conversation_id = route.query.t;

            const instance = getCurrentInstance();
            const cable = instance.ctx.$root.$cable

            cable.subscribe({
                channel: 'ConversationChannel',
                conversation_id: conversation_id,
                room: 'public'
            });

            getMessages()
        })

        function getMessages(){
            securedAxiosInstance.post('/conversation/index', { conversation_id: conversation_id })
                .then((response) => {
                    messages.value = response.data.messages
                })
                ,(error => console.log(error))
        }

        function sendMessage(){
            securedAxiosInstance.post('/conversation/add_message', { conversation_id: conversation_id, message: currentMessage.value })
                .then(() => {

                })
                ,(error => console.log(error))
        }

        function receivedMessage(data){
            messages.value.push(data.message)
            console.log("received " + messages.value)
        }
        return { moment, currentUsername, receivedMessage, messages, currentMessage, sendMessage }
    }
}
</script>

<style>

</style>