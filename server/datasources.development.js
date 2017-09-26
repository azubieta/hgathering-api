const mongoHost = process.env.MONGO_HOST || 'localhost';
const mongoPort = process.env.MONGO_PORT || '27017'

module.exports = {
  mlab: {
    host: mongoHost,
    port: mongoPort,
    url: `mongodb://${mongoHost}:${mongoPort}/help_mx`,
    database: "help_mx",
    name: "mlab",
    connector: "mongodb"
  }
}
