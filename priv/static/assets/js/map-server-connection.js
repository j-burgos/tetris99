const MapServer = ws => {
  const join = ws => player => {
    console.log(`Joining map as: ${player}`);
    const message = JSON.stringify({ action: 'join', player });
    ws.send(message);
  };
  const leave = ws => player => {
    console.log('Leaving map')
    const message = JSON.stringify({ action: 'leave', player });
    ws.send(message);
  };
  const move = ws => (player, position) => {
    console.log(`Moving to position ${position}`);
    const message = JSON.stringify({ action: 'move', player, position });
    ws.send(message);
  };

  return {
    join: join(ws),
    leave: leave(ws),
    move: move(ws),
  };
};

const ConnectionBuilder = (url, messageHandler) => {
  const ws = new WebSocket(url);

  ws.onopen = () => console.log('Connection opened');
  ws.onerror = ev => console.error(ev);
  ws.onclose = () => console.log('Connection closed');
  ws.onmessage = ({ data }) => {
    console.log('Message received', data);
    if (messageHandler) messageHandler(ws, data);
  };

  return ws;
};

export {
  MapServer,
  ConnectionBuilder,
};
