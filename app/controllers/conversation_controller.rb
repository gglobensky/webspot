class ConversationController < ApplicationController
    include JwtProcessToken
    respond_to :json
    before_action :process_token

    def create
        participant = User.find(params[:user_id])

        conversation = Conversation.create
        participant.user_conversations.create({conversation_id: conversation.id})
        current_user.user_conversations.create({conversation_id: conversation.id})

        if (conversation.save)
            render json: {status: "success", conversation: conversation.id }
        end
    end

    def index
        user = current_user
        conversation_id = params[:conversation_id]
        messages = user.conversations.find(conversation_id).messages
        messages = messages.joins(:user).select("username, content, messages.updated_at, messages.created_at").order(created_at: :asc).as_json(only: [:username, :content, :updated_at])
        render json: { messages: messages }
    end

    def add_message
        user = current_user
        conversation_id = params[:conversation_id]
        content = params[:message]
        conversation = user.conversations.find(conversation_id)
        message = conversation.messages.build({ user_id: user.id, content: content })
        
        if (message.save)
            json_message = { content: content, username: user.username }
            ActionCable.server.broadcast("conversation_channel_#{conversation_id}", { message: json_message })

            receivers_user_ids = conversation.users.where.not('users.id = ?', user.id).pluck(:id)

            receivers_user_ids.each do |id|
                ActionCable.server.broadcast("notification_channel_#{id}", { message: json_message })
            end
        end
    end
end