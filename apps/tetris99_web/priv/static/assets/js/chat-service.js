const ChatService = ws => {
  const join = ws => player => {
    console.log(`Joining as: ${player}`);
    const message = JSON.stringify({ action: 'join', player });
    ws.send(message);
  };
  const leave = ws => player => {
    console.log('Leaving map');
    const message = JSON.stringify({ action: 'leave', player });
    ws.send(message);
  };
  const sendMessage = ws => messageString => {
    const message = JSON.stringify({
      action: 'broadcast',
      message: messageString,
    });
    ws.send(message);
  };

  return {
    join: join(ws),
    leave: leave(ws),
    sendMessage: sendMessage(ws),
  };
};

const addUserToList = user => {
  const userListElement = document.getElementById('userlist');
  const newListElem = document.createElement('li');
  const content = document.createTextNode(user);
  newListElem.setAttribute('id', user);
  newListElem.appendChild(content);
  userListElement.appendChild(newListElem);
};

const addMessageToList = (user, message) => {
  const messageListElement = document.getElementById('messages');
  const newListElem = document.createElement('div');
  const content = document.createTextNode(`${user}: ${message}`);
  newListElem.appendChild(content);
  messageListElement.appendChild(newListElem);
};

const removeUserFromList = user => {
  const userListElement = document.getElementById('userlist');
  const userElement = document.getElementById(user);
  userListElement.removeChild(userElement);
};

const ConnectionBuilder = (url, messageHandler) => {
  const ws = new WebSocket(url);

  ws.onopen = () => console.log('Connection opened');
  ws.onerror = ev => console.error(ev);
  ws.onclose = () => console.log('Connection closed');
  ws.onmessage = ({ data: json }) => {
    const data = JSON.parse(json);
    console.log('Message received', data);
    const newUser = data['user:connected'];
    const disconnectedUser = data['user:disconnected'];
    const connectedUserList = data['connected_users'];
    const newMessage = data['broadcast:message'];
    if (connectedUserList) {
      connectedUserList.forEach(addUserToList);
    }
    if (newUser) {
      addUserToList(newUser);
    }
    if (disconnectedUser) {
      removeUserFromList(disconnectedUser);
    }
    if (newMessage) {
      const user = data['broadcast:from'];
      addMessageToList(user, newMessage);
    }
    if (messageHandler) messageHandler(ws, data);
  };

  return ws;
};

export { ChatService, ConnectionBuilder };
