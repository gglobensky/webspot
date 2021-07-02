import ActionCableVue from 'actioncable-vue';

export const actionCableVueOptions = {
  debug: true,
  debugLevel: 'error',
  connectionUrl: 'ws://localhost:3000/cable',
  connectImmediately: true
};

export const actionCableVue = ActionCableVue
