import { ConnectionBuilder, ChatService } from './chat-service.js';

const port = window.location.port;
const connection = ConnectionBuilder(`ws://localhost:${port}/game`);
const chatService = ChatService(connection);

const getFormData = formElement => {
  const formData = new FormData(formElement);
  const formEntries = Array.from(formData.entries());
  const keyValues = formEntries.reduce(
    (acc, [k, v]) => ({ ...acc, [k]: v }),
    {},
  );
  return keyValues;
};
const joinFormElementId = 'player-join';
const joinForm = document.getElementById(joinFormElementId);
joinForm.onsubmit = e => {
  e.preventDefault();
  const { username } = getFormData(joinForm);
  chatService.join(username);
  const loginPage = document.getElementById('login-page');
  const chatPage = document.getElementById('chat-page');
  loginPage.classList.add('hidden');
  chatPage.classList.remove('hidden');
};

const sendMessageElementId = 'send-message';
const sendMessageForm = document.getElementById(sendMessageElementId);
sendMessageForm.onsubmit = e => {
  e.preventDefault();
  const { message } = getFormData(sendMessageForm);
  chatService.sendMessage(message);
  document.getElementById('message').value = '';
};
