'use strict';

module.exports = function (app) {
  /*
   * The `app` object provides access to a variety of LoopBack resources such as
   * models (e.g. `app.models.YourModelName`) or data sources (e.g.
   * `app.datasources.YourDataSource`). See
   * http://docs.strongloop.com/display/public/LB/Working+with+LoopBack+objects
   * for more info.
   */
  var User = app.models.Voluntario;
  var Role = app.models.Role;
  var RoleMapping = app.models.RoleMapping;

  var createAdmin = User.findOrCreate({where: {username: 'admin'}},
    {username: 'admin', email: 'admin@hapi.balterbyte.com', password: 'changeme'}
  );

  var createAdminRole = Role.findOrCreate(
    {where: {name : 'admin'}},
    {name: 'admin'}
  );

  Promise.all([createAdmin, createAdminRole])
    .then(function (results) {

      var admin = results[0][0];
      var role = results[1][0];
      return role.principals.create(
        {
          principalType: RoleMapping.USER,
          principalId: admin.id
        });
    }).catch(
    function (err) {
      console.warn("While creating default users and roles\n", err);
    });
};
