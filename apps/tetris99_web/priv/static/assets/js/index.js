import { ConnectionBuilder, MapServer } from './map-server-connection.js';

const connection = ConnectionBuilder('ws://localhost:5000/game');
const mapServer = MapServer(connection);

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
  mapServer.join(username);
};
