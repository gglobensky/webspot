<template>
  <div>
      <div class="row" id="content" style="height: 80vh; overflow: auto">
          <div class="col col-8">
              <div class="col col-12" v-for="message in messages" :key="message">
                <div v-if="currentUsername == message.username" style="float:right;">
                    <div class="chat-box default-pale white-text">
                        {{message.content}}
                    </div>
                    <p style="font-size:0.6rem; float:right;">{{$t('me')}} {{moment(message.updated_at).fromNow()}}</p>
                </div>
                  
                <div v-else style="float:left;">
                    <div class="chat-box grey lighten-2">
                        {{message.content}}
                    </div>
                    <p style="font-size:0.6rem; float:left;">{{message.username}} {{moment(message.updated_at).fromNow()}}</p>
                </div>

              </div>
              <div class="fixed-bottom">
                <div class="col col-8 d-flex align-items-end">
                    <div class="col col-11 px-5 mb-3">
                        <form-area maxHeight="58px" v-model="currentMessage" placeholder="Type here" />
                    </div>
                    <div class="col col-1">
                        <button @click="sendMessage" class="btn waves-effect waves-light mb-5" >Send</button>
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
import $ from 'jquery'
import moment from 'moment'
import store from '../../store'
import { useRoute } from 'vue-router';
import FormArea from '../components/FormArea.vue'
import { ref, onMounted, getCurrentInstance, onUnmounted } from 'vue'
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
        let cable = {}
        
        onMounted(() => {
        const route = useRoute();
        conversation_id = route.query.t;

            const instance = getCurrentInstance();
            cable = instance.ctx.$root.$cable

            cable.subscribe({
                channel: 'ConversationChannel',
                conversation_id: conversation_id,
                room: 'public'
            });

            getMessages()

            //Should improve that
            $('#content').animate({ scrollTop: 999999999999 }, 50);

        })

        onUnmounted(() => {
            unsubscribe()
        })

        function unsubscribe() {
            cable.unsubscribe('ConversationChannel');
        }

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
                    currentMessage.value = ""
                })
                ,(error => console.log(error))
        }

        function receivedMessage(data){
            messages.value.push(data.message)
            console.log("received " + JSON.stringify(messages.value))
            
            //check if chat is scrolled down before
            //if not, it means user is checking his previous messages
            //dont scroll down while he does that. 
            $('#content').animate({ scrollTop: 999999999999 }, 50);
        }
        return { moment, currentUsername, receivedMessage, messages, currentMessage, sendMessage }
    }
}
</script>

<style>

</style>