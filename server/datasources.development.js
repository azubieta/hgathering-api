const mongoDB   = process.env.MONGO_DB   || 'help_mx'
const mongoHost = process.env.MONGO_HOST || 'localhost';
const mongoPort = process.env.MONGO_PORT || '27017'

module.exports = {
  mlab: {
    name: "mlab",
    url: `mongodb://${mongoHost}:${mongoPort}/${mongoDB}`,
    database: mongoDB,
    host: mongoHost,
    port: mongoPort,
    connector: "mongodb"
  }
}
