const mongoDB   = process.env.MONGO_DB   || 'help_mx'
const mongoHost = process.env.MONGO_HOST || 'ds147034.mlab.com';
const mongoPort = process.env.MONGO_PORT || '47034'
const mongoUser = process.env.MONGO_USER || 'root'
const mongoPass = process.env.MONGO_PASS || 'root'

module.exports = {
  db: {
    name: "db",
    connector: "memory"
  },
  mlab: {
    name: "mlab",
    url: `mongodb://${mongoUser}:${mongoPass}@${mongoHost}:${mongoPort}/${mongoDB}`,
    database: mongoDB,
    host: mongoHost,
    port: mongoPort,
    user: mongoUser,
    password: mongoPass,
    connector: "mongodb"
  }
}
