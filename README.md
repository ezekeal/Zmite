# Zmite

## A site using the Smite API by Hi-Rez Studios

This source is avaliable for helping others and getting help from others.

To get started you will need to:

* get developer credentials from Hi Rez
* create a creds.js file in the `src` folder with your developer creditials
```js
module.exports = {
  devId: '1234',
  authKey: '327R2D2C3POTHX1138FN2187'
}
```

* [install and run mongoDB](https://docs.mongodb.org/manual/installation/)
* [install Node](https://nodejs.org/en/)

* install gulp globally `npm i -g gulp`
* build with gulp `gulp build`
* install packages locally `npm i`
* run the server `node dist/server`
* view the endpoints `http://localhost:5000/api/testsession`
